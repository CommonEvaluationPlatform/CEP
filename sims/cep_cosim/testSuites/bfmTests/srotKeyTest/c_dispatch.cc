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

int main(int argc, char *argv[]) {

  //--------------------------------------------------------------------------------------
  //   SETUP SECTION FOR SIMULATION 
  //--------------------------------------------------------------------------------------
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
 
  // Spawn threads for each core
  for (int i = 0; i < maxHost; i++) {
    if ((long unsigned int)(1 << i) & mask) {
      thr.ForkAThread(activeSlot, i, verbose, seed * (1+i), c_module);
    }
  }

  // Spawn system thread
  thr.AddSysThread(SYSTEM_SLOT_ID,SYSTEM_CPU_ID);
  
  // Enable waveform capture, unless disabled
  int cycle2start   = 0;
  int cycle2capture = -1; // til end
  int wave_enable   = 1;
#ifndef NOWAVE
  dump_wave(cycle2start, cycle2capture, wave_enable);
#endif

  // Wait until all threads are complete
  int Done = 0;
  while (!Done) {
    Done = thr.AllThreadDone();
    sleep(2);
  }

  //--------------------------------------------------------------------------------------
  // END-OF-TEST CHECKING
  //--------------------------------------------------------------------------------------
  errCnt += thr.GetErrorCount();
  if (errCnt != 0) {
    LOGE("======== TEST FAIL ========== %x\n",errCnt);
  } else {
    LOGI("%s ======== TEST PASS ========== \n",__FUNCTION__);
  }
  // shutdown HW side
  thr.Shutdown();
  return(errCnt);
}
