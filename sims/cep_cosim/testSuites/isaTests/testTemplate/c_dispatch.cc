//--------------------------------------------------------------------------------------
// Copyright 2022 Massachusets Institute of Technology
// SPDX short identifier: BSD-2-Clause
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
  
  int errCnt                = 0;
  int verbose               = 0x1f;
  int activeSlot            = 0;          // only 1 board 
  int maxHost               = MAX_CORES;  // number of cores/threads

  // Some ISA Tests only run on a single core and thus only a single core thread will be launched, depending on the
  // value of the SINGLE_CORE_ONLY parameter
  #ifdef SINGLE_CORE_ONLY
    long unsigned int mask  = SINGLE_CORE_ONLY; // each bit is to turn on the given core (bit0 = core0, bit1=core1, etc..)
  #else
    long unsigned int mask  = 0xF;              // each bit is to turn on the given core (bit0 = core0, bit1=core1, etc..)
  #endif

  int done                = 0;
  shPthread               thr;

  // Set the active mask for all threads  
  thr.SetActiveMask(mask);
  
  // spawn threads for each core (MAX_TIMEOUT will be inserted when each test is defined)
  for (int i = 0; i < maxHost; i++) {
    if ((long unsigned int)(1 << i) & mask) {
      thr.ForkAThread(activeSlot, i, verbose, MAX_TIMEOUT, c_module);
    }
  }
  
  // spawn system thread
  thr.AddSysThread(SYSTEM_SLOT_ID, SYSTEM_CPU_ID);

  // Communicate some items to the cep testbench
  
  // Initialize main memory to all zeroes
  DUT_WRITE_DVT(DVTF_PAT_LO, DVTF_PAT_LO, 0);
  DUT_WRITE_DVT(DVTF_SET_DEFAULTX_BIT, DVTF_SET_DEFAULTX_BIT, 1);  
  

  // Force a single thread
  #ifdef SINGLE_THREAD_ONLY
    DUT_WRITE_DVT(DVTF_PAT_HI, DVTF_PAT_LO, mask);
    DUT_WRITE_DVT(DVTF_FORCE_SINGLE_THREAD, DVTF_FORCE_SINGLE_THREAD, 1);
  #endif

  // Enable virtual mode
  #ifdef VIRTUAL_MODE
    DUT_WRITE_DVT(DVTF_SET_VIRTUAL_MODE, DVTF_SET_VIRTUAL_MODE,1);
  #endif  

  // Some tests just go straight to there if not <fail>
  #ifdef PASS_IS_TO_HOST
    DUT_WRITE_DVT(DVTF_PASS_IS_TO_HOST, DVTF_PASS_IS_TO_HOST, 1);
  #endif

  // Enable waveform capture, unless disabled
  int cycle2start   = 0;
  int cycle2capture = -1; // til end
  int wave_enable   = 1;
  #ifndef NOWAVE
    dump_wave(cycle2start, cycle2capture, wave_enable);
  #endif

  //--------------------------------------------------------------------------------------
  // Load the bare executable into scratchpad memory (from the system thread)
  // Ignoring the first 4096 bytes (stripping the ELF header?)
  //--------------------------------------------------------------------------------------
  int verify        = 0;
  int fileOffset    = 0x1000;
  int maxByteCnt    = cep_max_program_size;
  errCnt += load_mainMemory(RISCV_WRAPPER, scratchpad_base_addr, fileOffset, maxByteCnt);
  
  if (errCnt) goto cleanup;
  //--------------------------------------------------------------------------------------



  //--------------------------------------------------------------------------------------
  // Have the system thea wait until all threads are complete
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
