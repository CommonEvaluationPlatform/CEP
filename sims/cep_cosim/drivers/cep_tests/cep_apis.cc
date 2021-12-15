//--------------------------------------------------------------------------------------
// Copyright 2021 Massachusetts Institute of Technology
// SPDX License Identifier: BSD-2-Clause
//
// File Name:      cep_apis.cc
// Program:        Common Evaluation Platform (CEP)
// Description:    
// Notes:          
//
//--------------------------------------------------------------------------------------

#include "v2c_cmds.h"
#include "portable_io.h"

#ifdef SIM_ENV_ONLY
  #include "simPio.h"
#else
  #include <stdint.h>
#endif

#include "cep_adrMap.h"
#include "cep_apis.h"

#ifdef BARE_MODE
#include "encoding.h"
#endif

// Private bare-metal printf pointer
int __prIdx[MAX_CORES] = {0, 0, 0, 0};

int is_program_loaded(int maxTimeOut) {
  int errCnt = 0;
  int loaded = 0;
#ifdef SIM_ENV_ONLY
  int to = 0;  
  while (!loaded && (to < maxTimeOut)) {
    loaded = DUT_READ_DVT(DVTF_GET_PROGRAM_LOADED, DVTF_GET_PROGRAM_LOADED);
    DUT_RUNCLK(1000);
    to++;
  }
  if (!loaded) {
    LOGE("ERROR: Program loading timeout\n");
    errCnt++;
  } else {
    LOGI("OK: Program loading is completed\n");    
  }
#endif
  return errCnt;
}

void dump_wave(int cycle2start, int cycle2capture, int enable)
{
#ifdef SIM_ENV_ONLY
  //
  // When to start
  //
  DUT_WRITE_DVT(DVTF_PAT_HI, DVTF_PAT_LO, cycle2start); // at cycle 10
  DUT_WRITE_DVT(DVTF_WAVE_START_CYCLE, DVTF_WAVE_START_CYCLE, 1);
  
  // how many cycles: comment out if until end
  if (cycle2capture != -1) {
    DUT_WRITE_DVT(DVTF_PAT_HI, DVTF_PAT_LO, cycle2capture); // 
    DUT_WRITE_DVT(DVTF_WAVE_CYCLE2DUMP, DVTF_WAVE_CYCLE2DUMP, 1);
  }
  //
  // un-comment to turn on the wave
  if (enable) {
    DUT_WRITE_DVT(DVTF_WAVE_ON , DVTF_WAVE_ON, enable);
  }
#endif
}

// Clear the memory being used for printf "overloading"
int clear_printf_memory(int coreId) {
  int errCnt = 0;

  #ifdef SIM_ENV_ONLY
    LOGI("%s: coreid = %d\n",__FUNCTION__,coreId);

    for (int i = 0; i < cep_printf_max_lines; i++) {
      for (int j=0; j < 16; j++) {
        
        DUT_WRITE32_64(cep_printf_mem + (coreId * cep_printf_core_size) + (i * cep_printf_str_max) + (j*8), 0);
      }
    }
  #endif // #ifdef SIM_ENV_ONLY
  
  return errCnt;
}

// Load the image into main memory
int read_binFile(char *imageF, uint64_t *buf, int wordCnt) {
#ifdef SIM_ENV_ONLY  
  FILE *fd=NULL;
  int i = 0;
  fd=fopen(imageF,"rb");
  while (!feof(fd) && (i < wordCnt)) {
    fread(&(buf[i]),sizeof(uint64_t),1,fd);
    LOGI("fread i=%d 0x%016lx\n",i,buf[i]);
    i++;
  }
  fclose(fd);
#endif
  return 0;
}

// Load a file into Main Memory (must be called from the system thread)
int load_mainMemory(char *imageF, uint32_t mem_base, int srcOffset, int destOffset, int verify, int maxByteCnt) {
  int errCnt = 0;

  #ifdef SIM_ENV_ONLY  
    FILE      *fd   = NULL;
    uint64_t  d64;
    uint64_t  rd64;
    int       s     = 0;
    int       d     = 0;
    int       bCnt  = 0;  
    
    // Open binary file
    fd = fopen(imageF, "rb");
  
    LOGI("%s: Loading file %s to memory base = 0x%08x\n",__FUNCTION__, imageF, mem_base);

    if (fd == NULL) {
      printf("Can't open file %s\n",imageF);
      return 1;
    }

    // Read from the file and load into the memory (via backdoor if enabled)
    while (!feof(fd)) {
      fread(&d64, sizeof(uint64_t), 1, fd);
      if ((s * 8) >= srcOffset) {
        DUT_WRITE32_64(mem_base + destOffset + d * 8, d64);
        d++;
      }
      s++;
    } // end while
    
    // Calculate the number of bytes loaded
    bCnt=(s + 1) * 8;
    
    // If we are loading memory using the backdoor, ensure we fill out the cache line
    if ((s & 0x7) != 0) {
      d64 = 0xDEADDEADDEADDEADLL;      
      LOGI("%s: flushing to cache line s = %d ====\n",__FUNCTION__, s);
      while ((s & 0x7) != 0) {
        DUT_WRITE32_64(mem_base + d*8,d64);
        d++;
        s++;
      }
    } // end if backdoor_on

    LOGI("%s: DONE backdoor loading file %s to main memory.  Size = %d bytes\n",__FUNCTION__, imageF, bCnt);
    
    // Did the loaded program exceed the maximum byte count?
    if (bCnt >= maxByteCnt) {
      errCnt++;
    // Verify if enabled
    } else if (verify) {
      rewind(fd);
      s = 0;
      d = 0;

      while (!feof(fd)) {
        fread(&d64, sizeof(uint64_t), 1 ,fd);
        if ((s * 8) >= srcOffset) {
          DUT_READ32_64(mem_base + destOffset + d*8, rd64);
          if (d64 != rd64) {
            LOGE("%s: Miscompare addr=0x%08x act=0x%016llx exp=0x%016llx\n",__FUNCTION__,mem_base + d*8, rd64, d64);
            errCnt++;
            break;
          } // end if (d64 != rd64)
          d++;
        } // end if ((s*8) >= srcOffset)
        s++;
      } // end while (!feof(fd))

      // Report comparison status
      if (!errCnt) {
        LOGI("%s: File %s preload and read-back OK\n",__FUNCTION__,imageF);
      } else {
        LOGE("%s: File %s preload and read-back ERROR\n",__FUNCTION__,imageF); 
      } // end if (!errCnt)

    } // if (verify)

    // Close the file descriptor
    fclose(fd);

    // Initialize printf memory for all cores
    for (int i = 0; i < MAX_CORES; i++)
      clear_printf_memory(i);
  
    // Indicate that a program has been loaded (assuming there was no error)
    if (!errCnt) {
      LOGI("%s: Setting program loaded flag\n", __FUNCTION__);
      DUT_WRITE_DVT(DVTF_PAT_HI, DVTF_PAT_LO, 1);
      DUT_WRITE_DVT(DVTF_SET_PROGRAM_LOADED, DVTF_SET_PROGRAM_LOADED, 1);
    }

  #endif // #ifdef SIM_ENV_ONLY

  return errCnt;
} // load_mainMemory

// Check PassFail
int check_PassFail_status(int coreId,int maxTimeOut) {
  int errCnt = 0;
#ifdef SIM_ENV_ONLY  
  int passMask = 0;
  int failMask = 0;
  int inReset;
  uint64_t d64;
  int wait4reset = 1000;
  //
  while (wait4reset > 0) {
    DUT_WRITE_DVT(DVTF_GET_CORE_RESET_STATUS, DVTF_GET_CORE_RESET_STATUS, 1);
    inReset = DUT_READ_DVT(DVTF_PAT_LO, DVTF_PAT_LO);
    if (inReset == 0) break;
    // may be the test already pass
    DUT_WRITE_DVT(DVTF_GET_PASS_FAIL_STATUS, DVTF_GET_PASS_FAIL_STATUS, 1);
    d64 = DUT_READ_DVT(DVTF_PAT_HI, DVTF_PAT_LO);
    passMask = (d64 & 0x1); 
    failMask = ((d64>>1) & 0x1); 
    LOGI("Current Pass=0x%x Fail=0x%x maxTimeOut=%d\n",passMask,failMask,maxTimeOut);
    if (passMask | failMask) break;    
    //
    wait4reset--;
    if (wait4reset <= 0) {
      LOGE("Timeout while waiting to be active\n");
      errCnt++;
      break;
    }
    DUT_RUNCLK(1000);    
  }
  while ((errCnt == 0) && (maxTimeOut > 0)) {
    // only if I am out of reset
    DUT_WRITE_DVT(DVTF_GET_PASS_FAIL_STATUS, DVTF_GET_PASS_FAIL_STATUS, 1);
    d64 = DUT_READ_DVT(DVTF_PAT_HI, DVTF_PAT_LO);
    passMask = (d64 & 0x1); 
    failMask = ((d64>>1) & 0x1); 
    LOGI("Current Pass=0x%x Fail=0x%x maxTimeOut=%d\n",passMask,failMask,maxTimeOut);
    if (passMask | failMask) break;
    maxTimeOut--;    
    if (maxTimeOut <= 0) {
      LOGE("Time out while waiting for Pass/Fail\n");
      errCnt++;
    }
    DUT_RUNCLK(1000);        
  }
  errCnt += failMask != 0;
  if (errCnt) {
    DUT_WRITE_DVT(DVTF_SET_PASS_FAIL_STATUS, DVTF_SET_PASS_FAIL_STATUS, 1);
  }
#endif
  return errCnt;
}

// A task to be called from the system thread to scan the specified cpuId's printf buffer for activity
int check_printf_memory(int cpuId) {

  int 		  errCnt = 0;
  uint64_t 	d64;

  // Read from printf memory (only applicable in simulation)
  #ifdef SIM_ENV_ONLY
    uint32_t p_adr = cep_printf_mem + (cpuId * cep_printf_core_size) + (cep_printf_str_max*__prIdx[cpuId]);
    DUT_READ32_64(p_adr, d64);

    // If a non-zero value is detected, convey that a printf has occured to the testbench and increment the pointer
    if (d64 != 0) {
      DUT_WRITE_DVT(DVTF_PAT_HI, DVTF_PAT_LO, (p_adr & ~0x3) | (cpuId & 0x3));
      DUT_WRITE_DVT(DVTF_PRINTF_CMD,DVTF_PRINTF_CMD,1 );
      __prIdx[cpuId] = (__prIdx[cpuId] + 1) % cep_printf_max_lines;
    } // end (d64 != 0)
  #endif

 return errCnt;
} // check_printf_memory


// Monitor the "bare" status of the specified core
int check_bare_status(int cpuId, int maxTimeOut) {

  int errCnt = 0;

  // This function is only relevant in simulation mode
  #ifdef SIM_ENV_ONLY
    uint64_t  d64;
    uint64_t  offS;
    uint32_t  d32;
    uint32_t  testId;
    int       i       = 0;
    int       done    = 0;
  
    LOGI("%s: cpuId = %0d, maxTimeOut = %0d\n", __FUNCTION__, cpuId, maxTimeOut);  
  
    // Loop until a done or timeout is detected
    while (!done && (i < maxTimeOut)) {
    
      // Read the core status (from the core status register)
      DUT_WRITE_DVT(DVTF_PAT_HI, DVTF_PAT_LO, cpuId);
      DUT_WRITE_DVT(DVTF_GET_CORE_STATUS, DVTF_GET_CORE_STATUS, 1);
      d64 = DUT_READ_DVT(DVTF_PAT_HI, DVTF_PAT_LO);
      testId = d64 >> 32;
      d32 = d64 & 0xFFFFFFFF;

      // Check status
      if (d32 == CEP_GOOD_STATUS) {
        LOGI("%s: GOOD Status: cpuId = %0d, i = %0d\n",__FUNCTION__, cpuId, i);
        done = 1;
      } else if (d32 == CEP_BAD_STATUS) {
        LOGI("%s: BAD Status: cpuId = %0d, i = %0d\n",__FUNCTION__, cpuId, i);
        done = 1;
        errCnt++;
      } // end if (d32 == CEP_GOOD_STATUS)
    
      // Increment the timeout counter
      i++;

      if (!done) {
        LOGI("%s: NOT DONE Status: cpuId = %0d, i = %0d\n",__FUNCTION__, cpuId, i);
        DUT_RUNCLK(1000);
      } // end if (!done)

  } // while (!done && (i < maxTimeOut))
  
  // Has a timeout occurred?
  if (i >= maxTimeOut) {
      LOGI("%s: TIMEOUT: cpuId = %0d, i = %0d\n",__FUNCTION__, cpuId, i);
      errCnt++;    
  }
  
  // Put the core in reset to stop the program counter
  DUT_RUNCLK(100);
  LOGI("%s: Putting core in reset to stop the PC...\n",__FUNCTION__);
  DUT_WRITE_DVT(DVTF_PAT_HI, DVTF_PAT_LO, cpuId);
  DUT_WRITE_DVT(DVTF_PUT_CORE_IN_RESET, DVTF_PUT_CORE_IN_RESET, 1);

#endif
  return errCnt;
}
    
//
// BARE Metal ONLY
//
void set_cur_status(int status) {
#ifdef BARE_MODE  
  int coreId;
  uint64_t d64, offS;
  
  // which core???
  coreId = read_csr(mhartid);
  d64 = ((u_int64_t)coreId << 32) | (u_int64_t)status;
  offS = reg_base_addr + cep_core0_status + (coreId * 8);
  *(volatile uint64_t *)(offS) = d64;
#endif
}


// for single core 0 ONLY
void set_pass(void) {
#ifdef BARE_MODE    
  uint64_t d64, offS;
  d64 = CEP_GOOD_STATUS;
  offS = reg_base_addr + cep_core0_status;
  *(volatile uint64_t *)(offS) = d64;
#endif
}

void set_fail(void) {
#ifdef BARE_MODE    
  uint64_t d64, offS;
  d64 = CEP_BAD_STATUS;
  offS = reg_base_addr + cep_core0_status;
  *(volatile uint64_t *)(offS) = d64;
#endif
}


int set_status(int errCnt, int testId) {
#ifdef BARE_MODE  
  int i=0, coreId;
  uint64_t d64, offS, myOffs;
  //
  // which core???
  //
  coreId = read_csr(mhartid);
  if (errCnt) {
    d64 = ((u_int64_t)testId << 32) | CEP_BAD_STATUS;
  } else {
    d64 = ((u_int64_t)testId << 32) | CEP_GOOD_STATUS;
  }
  // Use core status 05/18/20
  offS = reg_base_addr + cep_core0_status + (coreId * 8);
  *(volatile uint64_t *)(offS) = d64;
  //
  // Below are not predictable due to cache flush
  //
  myOffs = cep_scratch_mem + (coreId*cep_cache_size);
  //
  // Set the status
  //
  *(volatile uint64_t *)(myOffs) = d64;
  *(volatile uint64_t *)(myOffs+8) = coreId;
  // write to sratch register that belong to me
  //
  //
  // force a cache flush?? 
  //
  //asm volatile ("fence"); // flush????
  //
  i=0;
  while (i < 18) {
    offS = cep_scratch_mem | ((1<<i)*64);
    d64 = *(volatile uint64_t *)(offS | ((1<<i)*64));
    if (d64 == CEP_BAD_STATUS) { i += 2; } else { i++; }
  }
  #endif

      
  return errCnt;
}

//
// For playback command file
//
void cep_raw_write(uint64_t pAddress, uint64_t pData) {
#ifdef BARE_MODE
  *(volatile uint64_t*)(pAddress) = pData;  
#elif SIM_ENV_ONLY
  DUT_WRITE32_64(pAddress, pData);
#elif LINUX_MODE
  return lnx_cep_write(pAddress, pData);  
#else
  ; // do nothing!!! memcpy(pAddress, &pData, sizeof(pData));
#endif  
}

uint64_t cep_raw_read(uint64_t pAddress) {
#ifdef BARE_MODE
  return *(volatile uint64_t*)(pAddress);
#elif SIM_ENV_ONLY
  uint64_t d64;
  DUT_READ32_64(pAddress, d64);
  return d64;
#elif LINUX_MODE
  return lnx_cep_read(pAddress);
#else  
  return -1; // NA!!!
#endif
    
}

static int inRange(uint64_t adr, uint64_t upperAdr,uint64_t lowerAdr) {
  return ((adr >= lowerAdr) && (adr < upperAdr)) ? 1 : 0;
}
       
int cep_playback(uint64_t *cmdSeq, uint64_t upperAdr, uint64_t lowerAdr, int totalCmds, int totalSize, int verbose) {
  if (verbose) {
    LOGI("%s: playback command sequence totalCmds=%d totalSize=%d\n",__FUNCTION__,totalCmds,totalSize);
  }
  int errCnt = 0;
  int i=0, TO;
  uint64_t rdDat;
  for (int c=1;c<=totalCmds;c++) {
    // read the first item
    if (cmdSeq[i] == WRITE__CMD) {
      if (inRange(cmdSeq[i+1],upperAdr,lowerAdr)) {    
  cep_raw_write(cmdSeq[i+1],cmdSeq[i+2]);
      }
      i += WRITE__CMD_SIZE;
    }
    else if (cmdSeq[i] == RDnCMP_CMD) {
      if (inRange(cmdSeq[i+1],upperAdr,lowerAdr)) {     
  rdDat = cep_raw_read(cmdSeq[i+1]);
  if (rdDat != cmdSeq[i+2]) {
    LOGE("%s: ERROR Mismatch at cmd=%d adr=0x%016lx exp=0x%016lx act=0x%016lx\n",__FUNCTION__,
         c, cmdSeq[i+1],cmdSeq[i+2],rdDat);
    errCnt = c;
    break;
  } else if (verbose) {
    LOGI("%s: OK at cmd=%d adr=0x%016lx exp=0x%016lx act=0x%016lx\n",__FUNCTION__,
         c, cmdSeq[i+1],cmdSeq[i+2],rdDat); 
  }
      }
      i += RDnCMP_CMD_SIZE;
    }
    else if (cmdSeq[i] == RDSPIN_CMD) {
      if (inRange(cmdSeq[i+1],upperAdr,lowerAdr)) {     
  TO = cmdSeq[i+4];
  while (TO > 0) {
    rdDat = cep_raw_read(cmdSeq[i+1]);
    if (((rdDat ^ cmdSeq[i+2]) & cmdSeq[i+3]) == 0) {
      break;
    }
    TO--;
    if (TO <= 0) {
      LOGE("%s: timeout at cmd=%d adr=0x%016lx exp=0x%016lx act=0x%016lx\n",__FUNCTION__,
     c, cmdSeq[i+1],cmdSeq[i+2],rdDat);
      errCnt = c;
      break;
    }
  }
      }
      i += RDSPIN_CMD_SIZE;
    }
  }
  return errCnt;
}

//
// Lock support
//
int cep_get_lock(int myId, int lockNum, int timeOut) {
  int gotIt = 0;
  uint64_t dat64, rdDat, exp;
  dat64 = (((uint64_t)1 << reqLock_bit ) |
     ((uint64_t)(lockNum & reqLockNum_mask) << reqLockNum_bit) |
     ((uint64_t)(myId & reqId_mask) << reqId_bit_lo));
  exp = 1 | (myId << 1); // expected
  do {
    // request the lock
    cep_raw_write(reg_base_addr + testNset_reg, dat64);
    rdDat = cep_raw_read(reg_base_addr + testNset_reg);
    if (((rdDat >> (8*lockNum)) & 0xFF) == exp) {
      gotIt = 1;
      break;
    }
    timeOut--;
    USEC_SLEEP(100);
  } while (timeOut > 0);
  if (timeOut <= 0) {
    LOGE("%s: ERROR: timeout\n",__FUNCTION__);
    return -1;
  }
  return gotIt;
}

void cep_release_lock(int myId, int lockNum) {
  uint64_t dat64;
  // just release
  dat64 = (((uint64_t)1 << releaseLock_bit ) |
     ((uint64_t)(lockNum & reqLockNum_mask) << reqLockNum_bit) |
     ((uint64_t)(myId & reqId_mask) << reqId_bit_lo));  
  cep_raw_write(reg_base_addr + testNset_reg, dat64);
}

int cep_get_lock_status(int myId, int lockNum, int *lockMaster) {
  uint64_t dat64;
  dat64 = cep_raw_read(reg_base_addr + testNset_reg);
  dat64 = (dat64 >> (8*lockNum)) & 0xFF;
  *lockMaster = dat64>>1;
  return (dat64 & 0x1) ? 1 : 0;
}
//
//
//
int __c2c_captureOn = 0;
void Set_C2C_Capture(int enable) { __c2c_captureOn = enable; }
int Get_C2C_Capture(void) { return __c2c_captureOn; }
void writeDvt(int msb, int lsb, int bits) {
#ifdef SIM_ENV_ONLY    
  DUT_WRITE_DVT(msb,lsb,bits);
#endif
}

//
// Toggle dMI reset
//
void toggleDmiReset(void) {
  //
#ifdef SIM_ENV_ONLY    
  DUT_WRITE_DVT(DVTF_TOGGLE_DMI_RESET_BIT, DVTF_TOGGLE_DMI_RESET_BIT, 1);
  int loop = 100;
  int dmiReset = 1;
  do {
    dmiReset = DUT_READ_DVT(DVTF_TOGGLE_DMI_RESET_BIT, DVTF_TOGGLE_DMI_RESET_BIT);
    loop--;
  } while (dmiReset && (loop > 0));
#endif

}

