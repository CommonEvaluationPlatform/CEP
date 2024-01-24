//--------------------------------------------------------------------------------------
// Copyright 2024 Massachusetts Institute of Technology
// SPDX short identifier: BSD-3-Clause
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
  #include "portable_io.h"
  #include "CEP.h"
  #include "cepRegTest.h"
  
  #ifdef __cplusplus
  extern "C" {
  #endif
  
#ifdef VERILATOR
  int main() {
#else
  void thread_entry(int cid, int nc) {
#endif
    
    int errCnt    = 0;
    int testId[4] = {0x00, 0x11, 0x22, 0x33};
    int coreId    = read_csr(mhartid);
    int revCheck  = 1;
    int verbose   = 0;
    
    // Set the current core's status to running
    set_cur_status(CEP_RUNNING_STATUS);
  
    // Run the specified test 
    if (!errCnt) { errCnt = cepRegTest_runTest(coreId, 64, revCheck, coreId * (0x100), 0); }

    // Set the core status
    set_status(errCnt, testId[coreId]);

    // Exit with the error count
#ifdef VERILATOR
    if (errCnt)
      LOGE("Test Failed\n");
    else
      LOGI("Test Passed\n");

    return errCnt;
#else    
    exit(errCnt);
#endif
  }

  #ifdef __cplusplus
  }
  #endif
  
#endif // #ifdef BARE_MODE
