//--------------------------------------------------------------------------------------
// Copyright 2021 Massachusetts Institute of Technology
// SPDX short identifier: BSD-2-Clause
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
  #include "cepregression.h"
  #include "CEP.h"
  #include "cep_srot.h"
  #include "cepRegTest.h"
  #include "portable_io.h"

  // Include the test vectors related to this test
  #include "AES_playback.h"
  //#include "SHA256_1_playback.h"
  //#include "IIR_playback.h"
  //#include "FIR_playback.h"

  #ifdef __cplusplus
  extern "C" {
  #endif

  void thread_entry(int cid, int nc) {
    
    int errCnt    = 0;
    int testId[4] = {0x00, 0x11, 0x22, 0x33};
    int coreId    = read_csr(mhartid);
    int revCheck  = 1;
    int verbose   = 0;
    uint64_t upper;
    uint64_t lower;
    
    set_printf(0);
  
    // Set the current core's status to running
    set_cur_status(CEP_RUNNING_STATUS);

    // To avoid unnecessary SRoT operations, the coreMask should correspond
    // to the selected cores for this macroMix instance
//  int coreMask = 0xFFFFCFFB; // all cores (minus CMU ones)
//  int coreMask = 0xFFFFFFFF; // all cores
  int coreMask = 0x00000001;  // AES
//  int coreMask = 0x00000002;  // MD5
//  int coreMask = 0x00000004;  // SHA256.0 (CMU Core)
//  int coreMask = 0x00000008;  // SHA256.1
//  int coreMask = 0x00000010;  // SHA256.2
//  int coreMask = 0x00000020;  // SHA256.3
//  int coreMask = 0x00000040;  // RSA
//  int coreMask = 0x00000080;  // DES3
//  int coreMask = 0x00000100;  // DFT
//  int coreMask = 0x00000200;  // IDFT
//  int coreMask = 0x00000400;  // FIR
//  int coreMask = 0x00000800;  // IIR
//  int coreMask = 0x00001000;  // GPS.0 (CMU Core)
//  int coreMask = 0x00002000;  // GPS.1 (CMU Core)
//  int coreMask = 0x00004000;  // GPS.2
//  int coreMask = 0x00008000;  // GPS.3

//    int coreMask = 0x00000001 ^ 0x00000008 ^ 0x00000800 ^ 0x00000400;

    // Initialize the cepregression ipCores datastructure (needed for various access methods in the cep_crypto class, from which cep_srot is derived)
    initConfig();

    // Initialize the SRoT
    cep_srot srot(SROT_INDEX, CEP_VERSION_REG_INDEX, verbose);
    srot.SetCpuActiveMask(0xF);
    srot.SetCoreMask(coreMask);
    errCnt += srot.LLKI_Setup(coreId);
    srot.freeMe();

    if (errCnt) goto cleanup;

    // There is no Crypto++ support for RISC-V, so pre-recorded vectors will be used
    if (coreId == 0) {
      upper = AES_adrBase + AES_adrSize;
      lower = AES_adrBase;
      errCnt += cep_playback(AES_playback, upper, lower, AES_totalCommands, AES_size, 0);    
    }
    // else if (coreId == 1) {
    //   upper = SHA256_1_adrBase + SHA256_1_adrSize;
    //   lower = SHA256_1_adrBase;
    //   errCnt += cep_playback(SHA256_1_playback, upper, lower, SHA256_1_totalCommands, SHA256_1_size, 0);    
    // }
    // else if (coreId == 2) {
    //   upper = IIR_adrBase + IIR_adrSize;
    //   lower = IIR_adrBase;
    //   errCnt += cep_playback(IIR_playback, upper, lower, IIR_totalCommands, IIR_size, 0);    
    // }
    // else if (coreId == 3) {
    //   upper = FIR_adrBase + FIR_adrSize;
    //   lower = FIR_adrBase;
    //   errCnt += cep_playback(FIR_playback, upper, lower, FIR_totalCommands, FIR_size, 0);    
    // }  

    // Set the core status
cleanup:
    set_status(errCnt, testId[coreId]);

    // Exit with the error count
    exit(errCnt);
  }

  #ifdef __cplusplus
  }
  #endif
  
#endif // #ifdef BARE_MODE
