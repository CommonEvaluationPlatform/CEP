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

#ifndef __shLog_H
#define __shLog_H

#include <pthread.h>

extern pthread_t globalThread2SlotIdMap[];
extern int globalThread2SlotIdMap_initDone;

class shLog {
  // public stuffs
public:
  // constructors
  shLog() {};
  ~shLog() {}; // destroy when done -> return the share segment
//  void shMem_printf(char *prefix, char *str) ;
  void shMem_printf(char *str) ;
  int GetSlotId(pthread_t tid, int *slotId, int *cpuId) ;
  pthread_t GetThreadId() ;
  int isAThread(int *slotId, int *cpuId);
  
private:
  // unique key
};

#endif
