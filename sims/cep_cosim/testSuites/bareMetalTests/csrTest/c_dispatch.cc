//--------------------------------------------------------------------------------------
// Copyright 2021 Massachusetts Institute of Technology
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
#include "cepregression.h"
#include "simPio.h"

int main(int argc, char *argv[])
{

  unsigned long seed;
  sscanf(argv[1], "0x%x", &seed);  
  printf("Seed = 0x%x\n", seed);
  
  int errCnt              = 0;
  int verbose             = 0x1f;
  int activeSlot          = 0;          // only 1 board 
  int maxHost             = MAX_CORES;  // number of cores/threads
  long unsigned int mask  = 0xf;        // each bit is to turn on the given core (bit0 = core0, bit1=core1, etc..)
  shPthread               thr;

  // Set the active mask for all threads  
  thr.SetActiveMask(mask);
  
  // Initialize the core data structures (from cepgression.h)
  initConfig();

  // spawn threads for each core
  for (int i = 0; i < maxHost; i++) {
    if ((long unsigned int)(1 << i) & mask) {
      thr.ForkAThread(activeSlot, i, verbose, seed * (1+i), c_module);
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
  // Load the bare executable into scratchpad memory (from the system thread)
  // Ignoring the first 4096 bytes (stripping the ELF header?)
  //--------------------------------------------------------------------------------------
  int verify        = 0;
  int srcOffset     = 0x1000;
  int destOffset    = 0;
  int maxByteCnt    = cep_max_program_size;
  errCnt += load_mainMemory(RISCV_WRAPPER, scratchpad_base_addr, srcOffset, destOffset, verify, maxByteCnt);
  //--------------------------------------------------------------------------------------



  //--------------------------------------------------------------------------------------
  // Have the system thea wait until all threads are complete
  //--------------------------------------------------------------------------------------
  int done = 0;
  while (!done) {

    // Check to see if all the threads are done
    done = thr.AllThreadDone();

  }
  //--------------------------------------------------------------------------------------



  //--------------------------------------------------------------------------------------
  // End of test checking and thread termination
  //--------------------------------------------------------------------------------------
  errCnt += thr.GetErrorCount();
  if (errCnt != 0) {
    LOGE("======== TEST FAIL ========== %x\n",errCnt);
  } else {
    LOGI("%s ======== TEST PASS ========== \n",__FUNCTION__);
  }

  thr.Shutdown();

  return(errCnt);
  //--------------------------------------------------------------------------------------
}
