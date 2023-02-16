//--------------------------------------------------------------------------------------
// Copyright 2022 Massachusets Institute of Technology
// SPDX short identifier: BSD-3-Clause
//
// File Name:      riscv_wrapper.cc
// Program:        Common Evaluation Platform (CEP)
// Description:    
// Notes:          Due to the L1 Cache is the Rocket Chip, there will be
//                 a delay between when the instructions are read from
//                 from the SD card and when it gets written to memory
//
//--------------------------------------------------------------------------------------

// For bareMetal mode ONLY  
#ifdef BARE_MODE
  #include <stdio.h>
  #include <stddef.h>
  #include <stdlib.h>
  #include <stdint.h>
  #include <platform.h>
  #include "kprintf.h"
  #include "cep_apis.h"
  #include "portable_io.h"
  
  #ifdef __cplusplus
  extern "C" {
  #endif
  
  void thread_entry(int cid, int nc) {
    
    int errCnt    = 0;
    int testId[4] = {0x00, 0x11, 0x22, 0x33};
    int coreId    = read_csr(mhartid);
    int revCheck  = 1;
    int verbose   = 0;
    
    // Set the current core's status to running
    set_cur_status(CEP_RUNNING_STATUS);
    
    // Print a hello to the console (UART) - Core0 only
    if (coreId == 0)
        LOGI("Baremetal - FullBoot Successfull\n");
    
    // Set the core status
    set_status(errCnt, testId[coreId]);

    // Exit with the error count
    exit(errCnt);
  }

  #ifdef __cplusplus
  }
  #endif
  
#endif // #ifdef BARE_MODE
