//************************************************************************
// Copyright 2021 Massachusetts Institute of Technology
// SPDX short identifier: BSD-2-Clause
//
// File Name:      
// Program:        Common Evaluation Platform (CEP)
// Description:    
// Notes:          
//
//************************************************************************
//
// For bareMetal mode ONLY
//
#ifdef BARE_MODE
#include "cep_adrMap.h"
#include "cep_apis.h"

#include "cepMemTest.h"
#include "cepregression.h"


//#define printf(...) { return 0; }

#ifdef __cplusplus
extern "C" {
#endif
  
//int main(void)
void thread_entry(int cid, int nc)
{
  //
  int errCnt = 0;
  int coreId = read_csr(mhartid);
  uint32_t mem_base = 0x90000000;
  int adrWidth = 10;
  //
  if (coreId == 0) {  set_printf(0);  }  
  switch (coreId) {
  case 0: { mem_base = 0x90000000; break; }
  case 1: { mem_base = 0x91000000; break; }
  case 2: { mem_base = 0x92000000; break; }
  case 3: { mem_base = 0x93000000; break; }
  }
  set_cur_status(CEP_RUNNING_STATUS);  
  //
  //
  int dataWidth = 0;
  int i;
  for (i=0;i<4;i++) {
    switch ((i + coreId) & 0x3) {
    case 0 : dataWidth = 8; break;
    case 1 : dataWidth = 16; break;
    case 2 : dataWidth = 32; break;
    case 3 : dataWidth = 64; break;
    }
    errCnt = cepMemTest_runTest(coreId,mem_base,adrWidth,dataWidth ,((coreId+i)*0x10), 0, 0); 
    if (errCnt) break;
  }

  //
  // Done
  //
  set_status(errCnt,i);
  //
  // Stuck here forever...
  //
  exit(errCnt);
}

#ifdef __cplusplus
}
#endif
  
#endif
