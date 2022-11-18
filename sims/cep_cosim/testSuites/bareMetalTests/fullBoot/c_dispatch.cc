//--------------------------------------------------------------------------------------
// Copyright 2022 Massachusets Institute of Technology
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
  int maxHost             = MAX_CORES;  // number of cores/threads
  long unsigned int mask  = 0xf;        // each bit is to turn on the given core (bit0 = core0, bit1=core1, etc..)
  int done                = 0;
  shPthread               thr;

  // Set the active mask for all threads  
  thr.SetActiveMask(mask);
  
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

  // Disable UART Loopback
  set_uart_loopback(0);

  // Enable the UART in the BootROM
  enable_bootrom_uart();

  // Set the "backdoor" select in system_driver.sv to write to the SD Flash model
  set_backdoor_select(1);

  // Disable SPI loopback for this test
  set_spi_loopback(0);

  // Enable SD boot in the BootROM
  enable_bootrom_sdboot();

  //--------------------------------------------------------------------------------------
  // Load the bare executable into scratchpad memory (from the system thread)
  //--------------------------------------------------------------------------------------
  int fileOffset    = 0;
  
  // When booting from SD in simulation, the bootrom payload size is 16kB to make
  // simulation time more reasonable
  int maxByteCnt    = 0x4000;

  // Load memory
  errCnt += loadMemory(RISCV_WRAPPER, fileOffset, maxByteCnt);
  
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
