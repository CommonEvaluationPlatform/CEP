//************************************************************************
// Copyright 2022 Massachusets Institute of Technology
// SPDX License Identifier: BSD-2-Clause
//
// File Name:      cep_gps.cc/h
// Program:        Common Evaluation Platform (CEP)
// Description:    gps test for CEP
// Notes:          
//************************************************************************
#ifndef cep_gps_H
#define cep_gps_H
// ---------------------------
#include "stdint.h"
#include "cep_aes.h"

#define MIN_SAT 1
#define MAX_SAT 37
//
// CEP's GPS 
//
class cep_gps : public cep_aes { 
  // public stuffs
public: //
  // constructors
  //
  cep_gps(int coreIndex, int seed, int verbose);  
  cep_gps(int coreIndex, int seed, int staticPCodeInit, int verbose);
  ~cep_gps() {}; 

  int  GetSvNum ( ) { return mSvNum; }
  void SetSvNum (int svNum);
  void SetPcodeSpeed (uint16_t xn_cnt_speed, uint32_t z_cnt_speed);
  void SetPcodeXnInit (uint16_t x1a_initial, uint16_t x1b_initial, uint16_t x2a_initial, uint16_t x2b_initial);
  void LoadKey(void);  
  void Start(void);
  void BusReset(int assert);
  void BusReset(void);
  int  waitTilDone(int maxTO);
  

  void ResetCA_Code(void);
  void GenCA_Code(int svNum);
  int  ReadNCheckCA_Code(void);
  void GenP_Code(void);
  int  ReadNCheckP_Code(void);
  void ReadL_Code(void);  
  int RunSingle(void);
  //
  int RunGpsTest(int maxLoop);

protected:
  //
  int   mStaticPCodeInit;
  int   mSvNum;

  uint8_t   mExpCaCode[2];
  uint8_t   mActCaCode[2];
  uint16_t  m_xn_cnt_speed;
  uint32_t  m_z_cnt_speed;
  uint16_t  m_x1a_initial;
  uint16_t  m_x1b_initial;
  uint16_t  m_x2a_initial;
  uint16_t  m_x2b_initial;

  // CA Code SW implementation is a mirror of the hardware
  uint8_t   g1[11]; // [0] not used to match HW
  uint8_t   g2[11];
};

//
#endif
