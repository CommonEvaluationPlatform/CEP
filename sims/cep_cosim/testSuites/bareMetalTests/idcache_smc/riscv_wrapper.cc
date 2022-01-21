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
#include "cep_riscv.h"


//#define printf(...) { return 0; }

#ifdef __cplusplus
extern "C" {
#endif
  
//int main(void)
void thread_entry(int cid, int nc)
{
  //
  int errCnt = 0;
  int testId[4] = {0x00,0x11,0x22,0x33};
  int coreId = read_csr(mhartid);
  uint64_t mem_base = 0x90000000;
  //
  set_cur_status(CEP_RUNNING_STATUS);  
  if (coreId == 0) {  set_printf(0);  }  
  switch (coreId) {
  case 0: { mem_base = 0x90000000; break; }
  case 1: { mem_base = 0x91000000; break; }
  case 2: { mem_base = 0x92000000; break; }
  case 3: { mem_base = 0x93000000; break; }
  }
  int blockCnt = 32;
  errCnt += do_DIcache_SMC((uint64_t *)mem_base, blockCnt, 0x10+coreId, 0);
  //
  // Done
  //
  set_status(errCnt,testId[coreId]);
  //
  // Stuck here forever...
  //
  exit(errCnt);
}

#ifdef __cplusplus
}
#endif
  
#endif
