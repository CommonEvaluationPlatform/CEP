//--------------------------------------------------------------------------------------
// Copyright 2024 Massachusetts Institute of Technology
// SPDX short identifier: BSD-3-Clause
//
// File Name:      riscv_wrapper.cc
// Program:        Common Evaluation Platform (CEP)
// Description:    RISC-V template for MacroMix
// Notes:          
//
//--------------------------------------------------------------------------------------




//
// For bareMetal mode ONLY
//
#ifdef BARE_MODE
  #include "cep_apis.h"
  #include "portable_io.h"
  #include "CEP.h"
  #include "cepRegTest.h"

  // Include the test vectors related to this test
  #include "SROT_playback.h"
  #include "GPS_0_playback.h"
  #include "GPS_1_playback.h"
  #include "GPS_2_playback.h"
  #include "GPS_3_playback.h"
  
  #ifdef __cplusplus
  extern "C" {
  #endif

  int cep_readNspin(int coreIndex, uint32_t pAddress,uint64_t pData,uint64_t mask, int timeOut) {
    uint64_t rdDat;
    while (timeOut > 0) {
      rdDat = cep_read64(coreIndex, pAddress);
      if (((rdDat ^ pData) & mask) == 0) {
        break;
      }
      USEC_SLEEP(100);
      timeOut--;
    };
    return (timeOut <= 0) ? 1 : 0;  
  }

#ifdef VERILATOR
  int main() {
#else
  void thread_entry(int cid, int nc) {
#endif
    
    int errCnt    = 0;
    int testId[4] = {0x00, 0x11, 0x22, 0x33};
    int coreId    = read_csr(mhartid);
    int revCheck  = 1;
    int verbose   = 1;
    int maxTO     = 5000;
    uint64_t upper;
    uint64_t lower;
    
    // Set the current core's status to running
    set_cur_status(CEP_RUNNING_STATUS);

    // There is no Crypto++ support for RISC-V, so pre-recorded vectors will be used
    if (coreId == 0) {
      upper = SROT_adrBase + SROT_adrSize;
      lower = SROT_adrBase;
      errCnt += cep_playback(SROT_playback, upper, lower, SROT_totalCommands, verbose);
      cep_write64(CEP_VERSION_REG_INDEX, cep_scratch4_reg, CEP_OK2RUN_SIGNATURE);
      upper = GPS_0_adrBase + GPS_0_adrSize;
      lower = GPS_0_adrBase;
      errCnt += cep_playback(GPS_0_playback, upper, lower, GPS_0_totalCommands, verbose);
    }
    else if (coreId == 1) {
      errCnt += cep_readNspin(CEP_VERSION_REG_INDEX, cep_scratch4_reg, CEP_OK2RUN_SIGNATURE, 0xFFFFFFFF, maxTO); 
      if (errCnt) goto cleanup;
      upper = GPS_1_adrBase + GPS_1_adrSize;
      lower = GPS_1_adrBase;
      errCnt += cep_playback(GPS_1_playback, upper, lower, GPS_1_totalCommands, verbose);    
    }
    else if (coreId == 2) {
      errCnt += cep_readNspin(CEP_VERSION_REG_INDEX, cep_scratch4_reg, CEP_OK2RUN_SIGNATURE, 0xFFFFFFFF, maxTO); 
      if (errCnt) goto cleanup;
      upper = GPS_2_adrBase + GPS_2_adrSize;
      lower = GPS_2_adrBase;
      errCnt += cep_playback(GPS_2_playback, upper, lower, GPS_2_totalCommands, verbose);    
    }
    else if (coreId == 3) {
      errCnt += cep_readNspin(CEP_VERSION_REG_INDEX, cep_scratch4_reg, CEP_OK2RUN_SIGNATURE, 0xFFFFFFFF, maxTO); 
      if (errCnt) goto cleanup;
      upper = GPS_3_adrBase + GPS_0_adrSize;
      lower = GPS_3_adrBase;
      errCnt += cep_playback(GPS_3_playback, upper, lower, GPS_3_totalCommands, verbose);
    }  

    // Set the core status
cleanup:
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
