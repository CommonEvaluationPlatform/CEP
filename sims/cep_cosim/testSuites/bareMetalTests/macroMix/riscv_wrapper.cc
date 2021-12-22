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




//
// For bareMetal mode ONLY
//
#ifdef BARE_MODE
#include <stdlib.h>
#include <stdio.h>
#include "CEP.h"
#include "cep_adrMap.h"
#include "cep_apis.h"
#include "cepregression.h"
#include "cepMacroMix.h"
#include "cep_srot.h"

// Include the test vectors related to this test
#include "MD5_playback.h"
#include "SHA256_0_playback.h"
#include "SHA256_1_playback.h"
#include "SHA256_2_playback.h"
#include "SHA256_3_playback.h"
#include "IIR_playback.h"
#include "FIR_playback.h"

//
// =================================================
// Bare metal Mode
// =================================================
//
#ifdef __cplusplus
extern "C" {
#endif

//int main(void)
void thread_entry(int cid, int nc)
{

  int errCnt    = 0;
  int testId[4] = {0x00, 0x11, 0x22, 0x33};
  int coreId    = read_csr(mhartid);
  int revCheck  = 1;
  set_printf(0);

  // Set the current core's status to running
  set_cur_status(CEP_RUNNING_STATUS);

  uint64_t upper, lower;
  int verbose = 0;
  cep_srot srot(SROT_INDEX, CEP_VERSION_REG_INDEX, verbose);
  srot.SetCpuActiveMask(0xf);
  errCnt += srot.LLKI_Setup(coreId);
  if (errCnt) goto cleanup;

  if (coreId == 0) {
    upper = MD5_adrBase + MD5_adrSize;
    lower = MD5_adrBase;
    errCnt += cep_playback(MD5_playback, upper, lower, MD5_totalCommands, MD5_size, 0);    
  }
  else if (coreId == 1) {
    upper = SHA256_0_adrBase + SHA256_0_adrSize;
    lower = SHA256_0_adrBase;
    errCnt += cep_playback(SHA256_0_playback, upper, lower, SHA256_0_totalCommands, SHA256_0_size, 0);    
  }
  else if (coreId == 2) {
    upper = IIR_adrBase + IIR_adrSize;
    lower = IIR_adrBase;
    errCnt += cep_playback(IIR_playback, upper, lower, IIR_totalCommands, IIR_size, 0);    
  }
  else if (coreId == 3) {
    upper = FIR_adrBase + FIR_adrSize;
    lower = FIR_adrBase;
    errCnt += cep_playback(FIR_playback, upper, lower, FIR_totalCommands, FIR_size, 0);    
  }  

  // Set the core status
  cleanup: set_status(errCnt, testId[coreId]);

  // Exit with the error count
  exit(errCnt);

}

#ifdef __cplusplus
}
#endif
  
#endif // #ifdef BARE_MODE
