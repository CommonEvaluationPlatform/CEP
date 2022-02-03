//--------------------------------------------------------------------------------------
// Copyright 2021 Massachusetts Institute of Technology
// SPDX short identifier: BSD-2-Clause
//
// File Name:      riscv_wrapper.cc
// Program:        Common Evaluation Platform (CEP)
// Description:    
// Notes:          
//
//--------------------------------------------------------------------------------------

// For bareMetal mode ONLY
#ifdef BARE_MODE
  #include "cep_apis.h"
  #include "cepregression.h"
  #include "CEP.h"
  
  #include "cepUartTest.h"
  #include "cepSpiTest.h"
  #include "cepGpioTest.h"
  #include "cepMaskromTest.h"
  
  #ifdef __cplusplus
  extern "C" {
  #endif
  
  void thread_entry(int cid, int nc) {
    
    int errCnt    = 0;
    int testId[4] = {0x00, 0x11, 0x22, 0x33};
    int coreId    = read_csr(mhartid);
    int revCheck  = 1;
    int verbose   = 0;
    
    set_printf(0);
  
    // Set the current core's status to running
    set_cur_status(CEP_RUNNING_STATUS);
  
    switch (coreId) {
      case 0 :  errCnt += cepUartTest_runTest(coreId,0x10, 0); break;
      case 1 :  errCnt += cepSpiTest_runTest(coreId,0x20, 0); break;
      case 2 :  errCnt += cepGpioTest_runTest(coreId,0x30,0); break;
      case 3 :  errCnt += cepMaskromTest_runTest(coreId,0x40,0); break;
    }

    // Set the core status
    set_status(errCnt, testId[coreId]);

    // Exit with the error count
    exit(errCnt);
  }

  #ifdef __cplusplus
  }
  #endif
  
#endif // #ifdef BARE_MODE
