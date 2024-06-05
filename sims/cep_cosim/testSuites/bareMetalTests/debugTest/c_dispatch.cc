#define MAX_TIMEOUT 2000
//--------------------------------------------------------------------------------------
// Copyright 2024 Massachusetts Institute of Technology
// SPDX short identifier: BSD-3-Clause
//
// File Name:      c_dispatch.cc
// Program:        Common Evaluation Platform (CEP)
// Description:    
// Notes:          
//
//--------------------------------------------------------------------------------------
#include <unistd.h>
#include "v2c_cmds.h"
#include "access.h"
#include "c_dispatch.h"
#include "c_module.h"
#include "cep_adrMap.h"
#include "cep_apis.h"
#include "portable_io.h"
#include "simPio.h"

int main(int argc, char *argv[])
{

  unsigned long seed;
  sscanf(argv[1], "0x%x", &seed);  
  printf("Seed = 0x%x\n", seed);
  
  int errCnt              = 0;
  int verbose             = 0x1f;
  int activeSlot          = 0;          // only 1 board 
  int maxHost             = CHIPYARD_CPU_COUNT;  // number of cores/threads
  long unsigned int mask  = 0xf;        // each bit is to turn on the given core (bit0 = core0, bit1=core1, etc..)
  int done                = 0;
  shPthread               thr;

  // Set the active mask for all threads  
  thr.SetActiveMask(mask);
  
  // spawn threads for each core
  for (int i = 0; i < maxHost; i++) {
    if ((long unsigned int)(1 << i) & mask) {
      thr.ForkAThread(activeSlot, i, verbose, MAX_TIMEOUT, c_module);
    }
  }
  
  // spawn system thread
  thr.AddSysThread(SYSTEM_SLOT_ID, SYSTEM_CPU_ID);

  // Enable waveform capture, unless disabled
  int cycle2start   = 0;
  int cycle2capture = -1; // til end
  int wave_enable   = 1;
  #ifndef NOWAVE
    dump_wave(cycle2start, cycle2capture, wave_enable);
  #endif

  //--------------------------------------------------------------------------------------
  // Setup and fork OpenOCD 
  //--------------------------------------------------------------------------------------
  int socketPortId = 0;
  int timeOut = 1000;
  LOGI("SocketPortId = 0x%08x to=%d\n",socketPortId,timeOut);        
  while (timeOut > 0) {
      DUT_WRITE_DVT(DVTF_GET_SOCKET_ID_BIT,DVTF_GET_SOCKET_ID_BIT,1);
      socketPortId = DUT_READ_DVT(DVTF_PAT_HI, DVTF_PAT_LO);
      LOGI("SocketPortId = 0x%08x to=%d\n",socketPortId,timeOut);      
      if (socketPortId >> 31)  {
          break; 
      }
      DUT_WRITE_DVT(DVTF_GET_SOCKET_ID_BIT,DVTF_GET_SOCKET_ID_BIT,0);
      DUT_RUNCLK(100);
      timeOut--;
  }
  
  char cmd[128];
  sprintf(cmd,"openocd -c \"set _JTAG_SOCKET_PORT %d\" -f dtm.cfg -d2 -l openOcd.log", socketPortId & 0xffff);
  DUT_WRITE_DVT(DVTF_ENABLE_REMOTE_BITBANG_BIT, DVTF_ENABLE_REMOTE_BITBANG_BIT, 1);
  // Fork child process
  if (fork() == 0) {
      LOGI("Executing system command %s\n",cmd);  
      system(cmd);
      return 0;
  }
  //--------------------------------------------------------------------------------------



  //--------------------------------------------------------------------------------------
  // Load the bare executable into scratchpad memory (from the system thread)
  //--------------------------------------------------------------------------------------
  int verify        = 0;
  int fileOffset    = 0;
  int destOffset    = 0;
  int maxByteCnt    = cep_max_program_size;
  errCnt += loadMemory(RISCV_WRAPPER, fileOffset, destOffset, maxByteCnt);
  
  if (errCnt) goto cleanup;
  //--------------------------------------------------------------------------------------



  //--------------------------------------------------------------------------------------
  // Have the system wait until all threads are complete
  //--------------------------------------------------------------------------------------
  while (!done) {

    // Check to see if all the threads are done
    done = thr.AllThreadDone();

  }
  //--------------------------------------------------------------------------------------



  //--------------------------------------------------------------------------------------
  // End of test checking and thread termination
  //--------------------------------------------------------------------------------------
  cleanup: errCnt += thr.GetErrorCount();
  if (errCnt != 0) {
    LOGE("======== TEST FAIL ========== %x\n",errCnt);
  } else {
    LOGI("%s ======== TEST PASS ========== \n",__FUNCTION__);
  }

  thr.Shutdown();

  return(errCnt);
  //--------------------------------------------------------------------------------------
}
