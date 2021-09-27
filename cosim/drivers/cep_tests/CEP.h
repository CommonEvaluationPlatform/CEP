//************************************************************************
// Copyright 2021 Massachusetts Institute of Technology
// SPDX License Identifier: BSD-2-Clause
//
// File Name:      
// Program:        Common Evaluation Platform (CEP)
// Description:    
// Notes:          
//
//************************************************************************


#ifndef cep_H
#define cep_H
#include "cep_version.h"

    // General Constants
    const uint32_t BITS_PER_BYTE    = 8;
    const uint32_t BYTES_PER_WORD   = 8;    // 64-bit word accesses for RISC-V


    // Maximum expected name size for the ipCoreData structure
    #define MAX_CONFIG_STRING_K     32

    // Enumerated type that is used by cepMacroMix to know which type of test
    // to run on the selected core
    typedef enum core_type_t {
        AES_CORE,
        MD5_CORE,
        SHA256_CORE,
        RSA_CORE,
        DES3_CORE,
        DFT_CORE,
        IDFT_CORE,
        FIR_CORE,
        IIR_CORE,
        GPS_CORE,
        CEP_VERSION_CORE,
        SROT_CORE
    } core_type_t;

    // Structure defining the base address and status
    // of the CEP cores
    typedef struct cep_core_info_t {
        const char      *name;
        core_type_t     type;
        uint32_t        base_address;
        bool            enabled;
    } cep_core_info_t;

    // Defines the total number of cores in the CEP
    #define CEP_TOTAL_CORES         18

    // Array containing the base addresses and enable status of
    // all the CEP cores (index in array == core index)
    // cepMacroMix.cc implementation limits this to 32 total cores.
    const cep_core_info_t cep_core_info[CEP_TOTAL_CORES] = {
        {"AES",         AES_CORE,         0x70000000, true },     // AES
        {"MD5",         MD5_CORE,         0x70010000, true },     // MD5
        {"SHA256.0",    SHA256_CORE,      0x70020000, true },     // SHA256 .0
        {"SHA256.1",    SHA256_CORE,      0x70021000, true },     // SHA256 .1
        {"SHA256.2",    SHA256_CORE,      0x70022000, true },     // SHA256 .2
        {"SHA256.3",    SHA256_CORE,      0x70023000, true },     // SHA256 .3
        {"RSA",         RSA_CORE,         0x70030000, true },     // RSA
        {"DES3",        DES3_CORE,        0x70040000, true },     // DES3
        {"DFT",         DFT_CORE,         0x70050000, true },     // DFT
        {"IDFT",        IDFT_CORE,        0x70060000, true },     // IDFT
        {"FIR",         FIR_CORE,         0x70070000, true },     // FIR
        {"IIR",         IIR_CORE,         0x70080000, true },     // IIR
        {"GPS.0",       GPS_CORE,         0x70090000, true },     // GPS .0
        {"GPS.1",       GPS_CORE,         0x70091000, true },     // GPS .1
        {"GPS.2",       GPS_CORE,         0x70092000, true },     // GPS .2
        {"GPS.3",       GPS_CORE,         0x70093000, true },     // GPS .3
        {"CEP Version", CEP_VERSION_CORE, 0x700F0000, true },     // CEP Version Register
        {"SROT",        SROT_CORE,        0x70200000, true }};    // SRoT
    
    // Direct indexes of version+SROT "cores"
    #define CEP_VERSION_REG_INDEX  (CEP_TOTAL_CORES - 2)
    #define SROT_INDEX             (CEP_TOTAL_CORES - 1)
   

    // ------------------------------------------------------------------------------------------------------------
    // The constants below, copied from the original implementations of the CEP
    // cores, provide constants and offsets for a given core, but not
    // ------------------------------------------------------------------------------------------------------------

    // Constants copied from AES.h
    const uint32_t AES_KEY_BITS     = 192;
    const uint32_t AES_BLOCK_BITS   = 128;
    const uint32_t AES_START_BYTES  = BYTES_PER_WORD;
    const uint32_t AES_DONE_BYTES   = BYTES_PER_WORD;

    const uint32_t AES_KEY_BYTES    = AES_KEY_BITS / BITS_PER_BYTE;
    const uint32_t AES_KEY_WORDS    = AES_KEY_BYTES / BYTES_PER_WORD;
    const uint32_t AES_BLOCK_BYTES  = AES_BLOCK_BITS / BITS_PER_BYTE;
    const uint32_t AES_BLOCK_WORDS  = AES_BLOCK_BYTES / BYTES_PER_WORD;

    const uint32_t AES_START        = 0;
    const uint32_t AES_PT_BASE      = AES_START + AES_START_BYTES;
    const uint32_t AES_CT_BASE      = AES_PT_BASE + AES_BLOCK_BYTES;
    const uint32_t AES_KEY_BASE     = AES_CT_BASE + AES_BLOCK_BYTES;
    const uint32_t AES_DONE         = 0;

    // Constants copied from DES.h
    const uint32_t DES3_KEY_BITS = 64*3;
    const uint32_t DES3_BLOCK_BITS = 64;
    const uint32_t DES3_START_BYTES = BYTES_PER_WORD;
    const uint32_t DES3_DECRYPT_BYTES = BYTES_PER_WORD;
    const uint32_t DES3_DONE_BYTES = BYTES_PER_WORD;

    // Automatically generated constants
    const uint32_t DES3_KEY_BYTES = DES3_KEY_BITS / BITS_PER_BYTE;
    const uint32_t DES3_KEY_WORDS = DES3_KEY_BYTES / BYTES_PER_WORD;
    const uint32_t DES3_BLOCK_BYTES = DES3_BLOCK_BITS / BITS_PER_BYTE;
    const uint32_t DES3_BLOCK_WORDS = DES3_BLOCK_BYTES / BYTES_PER_WORD;

    // Offset of DES3 data and control registers in device memory map
    const uint32_t DES3_START = 0;
    const uint32_t DES3_DECRYPT = DES3_START + DES3_START_BYTES;
    const uint32_t DES3_IN_BASE = DES3_DECRYPT + DES3_DECRYPT_BYTES;
    const uint32_t DES3_KEY_BASE = DES3_IN_BASE + DES3_BLOCK_BYTES;
    const uint32_t DES3_DONE = DES3_KEY_BASE + DES3_KEY_BYTES;
    const uint32_t DES3_CT_BASE = DES3_DONE + DES3_DONE_BYTES;

    // Constants from MD5.h
    const uint32_t MD5_HASH_BITS = 128;  
    const uint32_t MD5_MESSAGE_BITS = 512;
    const uint32_t MD5_READY_BYTES = 8;
    // const uint32_t MD5_HASH_DONE_BYTES = 8;
    const uint32_t MD5_HASH_DONE_BYTES = 0;

    // Automatically generated constants
    const uint32_t MD5_HASH_BYTES = MD5_HASH_BITS / BITS_PER_BYTE;
    const uint32_t MD5_HASH_WORDS = MD5_HASH_BYTES / BYTES_PER_WORD;
    const uint32_t MD5_MESSAGE_BYTES = MD5_MESSAGE_BITS / BITS_PER_BYTE;
    const uint32_t MD5_MESSAGE_WORDS = MD5_MESSAGE_BYTES / BYTES_PER_WORD;

    // Offset of MD5 data and control registers in device memory map
    const uint32_t MD5_READY = 0;
    const uint32_t MD5_MSG_BASE = MD5_READY + MD5_READY_BYTES;
    const uint32_t MD5_HASH_DONE = MD5_MSG_BASE + MD5_MESSAGE_BYTES;
    const uint32_t MD5_HASH_BASE = MD5_HASH_DONE + MD5_HASH_DONE_BYTES;
    const uint32_t MD5_RST = MD5_HASH_BASE + MD5_HASH_BYTES;
    const uint32_t MD5_MSG_IN_VALID = MD5_RST + BYTES_PER_WORD;
    const uint32_t MD5_MSG_OUT_VALID = MD5_MSG_IN_VALID + BYTES_PER_WORD;

    // Constants from SHA256.h
    const uint32_t SHA256_HASH_BITS = 256;
    const uint32_t SHA256_MESSAGE_BITS = 512;
    const uint32_t SHA256_READY_BYTES = BYTES_PER_WORD;
    const uint32_t SHA256_HASH_DONE_BYTES = BYTES_PER_WORD;

    // Automatically generated constants
    const uint32_t SHA256_HASH_BYTES = SHA256_HASH_BITS / BITS_PER_BYTE; // 256 / 8 = 32
    const uint32_t SHA256_HASH_WORDS = SHA256_HASH_BYTES / BYTES_PER_WORD; // 32 / 8 = 4
    const uint32_t SHA256_MESSAGE_BYTES = SHA256_MESSAGE_BITS / BITS_PER_BYTE; // 512 / 8 = 64
    const uint32_t SHA256_MESSAGE_WORDS = SHA256_MESSAGE_BYTES / BYTES_PER_WORD; // 64 / 8 = 8

    // Offset of SHA256 data and control registers in device memory map
    const uint32_t SHA256_READY = 0;
    const uint32_t SHA256_MSG_BASE = SHA256_READY + SHA256_READY_BYTES; // 0 + 8 = 8 h08
    const uint32_t SHA256_HASH_DONE = SHA256_MSG_BASE + SHA256_MESSAGE_BYTES; // 8 + 64 = 72 h48
    const uint32_t SHA256_HASH_BASE = SHA256_HASH_DONE + SHA256_HASH_DONE_BYTES; // 72 + 8 = 80 h50
    const uint32_t SHA256_NEXT_INIT = 0;

    // Constants from the RSA core's define.h
    const uint32_t RSA_ADDR_STATUS           = 0; 
    const uint32_t RSA_ADDR_CTRL             = 0;

    const uint32_t RSA_ADDR_EXPONENT_PTR_RST = RSA_ADDR_CTRL + BYTES_PER_WORD;  
    const uint32_t RSA_ADDR_EXPONENT_DATA    = RSA_ADDR_EXPONENT_PTR_RST + BYTES_PER_WORD;
    const uint32_t RSA_ADDR_EXPONENT_CTRL    = RSA_ADDR_EXPONENT_DATA + BYTES_PER_WORD;

    const uint32_t RSA_ADDR_MODULUS_PTR_RST  = RSA_ADDR_EXPONENT_CTRL+ BYTES_PER_WORD;
    const uint32_t RSA_ADDR_MODULUS_DATA     = RSA_ADDR_MODULUS_PTR_RST + BYTES_PER_WORD;
    const uint32_t RSA_ADDR_MODULUS_CTRL     = RSA_ADDR_MODULUS_DATA + BYTES_PER_WORD;

    const uint32_t RSA_ADDR_MESSAGE_PTR_RST  = RSA_ADDR_MODULUS_CTRL + BYTES_PER_WORD;
    const uint32_t RSA_ADDR_MESSAGE_DATA     = RSA_ADDR_MESSAGE_PTR_RST+ BYTES_PER_WORD;
    const uint32_t RSA_ADDR_MESSAGE_CTRL     = RSA_ADDR_MESSAGE_DATA+ BYTES_PER_WORD;

    const uint32_t RSA_ADDR_MODULUS_LENGTH   = RSA_ADDR_MESSAGE_CTRL + BYTES_PER_WORD;
    const uint32_t RSA_ADDR_EXPONENT_LENGTH  = RSA_ADDR_MODULUS_LENGTH + BYTES_PER_WORD;
    const uint32_t RSA_ADDR_RESULT_PTR_RST   = RSA_ADDR_EXPONENT_LENGTH+ BYTES_PER_WORD;
    const uint32_t RSA_ADDR_RESULT_DATA      = RSA_ADDR_RESULT_PTR_RST+ BYTES_PER_WORD;
    const uint32_t RSA_ADDR_RESULT_CTRL      = RSA_ADDR_RESULT_DATA+ BYTES_PER_WORD;

    const uint32_t RSA_ADDR_CYCLES           = RSA_ADDR_RESULT_CTRL + BYTES_PER_WORD;   

    // Constants from GPS.h
    const uint32_t GPS_GEN_NEXT_BYTES = BYTES_PER_WORD;
    const uint32_t GPS_CA_BYTES = BYTES_PER_WORD;
    const uint32_t GPS_P_BYTES = 128 / BITS_PER_BYTE;
    const uint32_t GPS_L_BYTES = 128 / BITS_PER_BYTE;
    const uint32_t GPS_KEY_BYTES = 192 / BITS_PER_BYTE;
    const uint32_t GPS_GEN_NEXT = 0;
    const uint32_t GPS_GEN_DONE = 0;
    const uint32_t GPS_CA_BASE = GPS_GEN_NEXT + GPS_GEN_NEXT_BYTES;
    const uint32_t GPS_P_BASE = GPS_CA_BASE + GPS_CA_BYTES;
    const uint32_t GPS_L_BASE = GPS_P_BASE + GPS_P_BYTES;
    const uint32_t GPS_SV_NUM = GPS_L_BASE + GPS_L_BYTES;
    const uint32_t GPS_RESET = GPS_SV_NUM + BYTES_PER_WORD;
    const uint32_t GPS_KEY_BASE = GPS_RESET + BYTES_PER_WORD;
    const uint32_t GPS_PCODE_SPEED = GPS_KEY_BASE + GPS_KEY_BYTES;
    const uint32_t GPS_PCODE_XINI = GPS_PCODE_SPEED + BYTES_PER_WORD;

    // Constants from DFT.h
    const uint32_t DFT_BLOCK_BITS    = 32;
    const uint32_t DFT_BLOCK_BYTES   = DFT_BLOCK_BITS / BITS_PER_BYTE;
    const uint32_t DFT_BLOCK_WORDS   = DFT_BLOCK_BYTES / BYTES_PER_WORD;
    const uint32_t DFT_START         = 0;
    const uint32_t DFT_IN_WRITE      = 0;  
    const uint32_t DFT_IN_ADDR       = DFT_IN_WRITE + BYTES_PER_WORD;
    const uint32_t DFT_IN_DATA       = DFT_IN_ADDR  + BYTES_PER_WORD;  
    const uint32_t DFT_OUT_ADDR      = DFT_IN_DATA  + BYTES_PER_WORD;
    const uint32_t DFT_OUT_DATA      = DFT_OUT_ADDR + BYTES_PER_WORD; 
    const uint32_t DFT_DONE          = 0;

    // Constants from IDFT.h
    const uint32_t IDFT_BLOCK_BITS   = 32;
    const uint32_t IDFT_BLOCK_BYTES  = IDFT_BLOCK_BITS / BITS_PER_BYTE;
    const uint32_t IDFT_BLOCK_WORDS  = IDFT_BLOCK_BYTES / BYTES_PER_WORD; 
    const uint32_t IDFT_START        = 0;
    const uint32_t IDFT_IN_WRITE     = 0;
    const uint32_t IDFT_IN_ADDR      = IDFT_IN_WRITE + BYTES_PER_WORD;
    const uint32_t IDFT_IN_DATA      = IDFT_IN_ADDR  + BYTES_PER_WORD;
    const uint32_t IDFT_OUT_ADDR     = IDFT_IN_DATA  + BYTES_PER_WORD;
    const uint32_t IDFT_OUT_DATA     = IDFT_OUT_ADDR + BYTES_PER_WORD;
    const uint32_t IDFT_DONE         = 0;

    // Constants from IIR.h
    const uint32_t IIR_BLOCK_BITS    = 32;
    const uint32_t IIR_BLOCK_BYTES   = IIR_BLOCK_BITS / BITS_PER_BYTE;
    const uint32_t IIR_BLOCK_WORDS   = IIR_BLOCK_BYTES / BYTES_PER_WORD;
    const uint32_t IIR_START         = 0;
    const uint32_t IIR_IN_WRITE      = 0;
    const uint32_t IIR_IN_ADDR       = IIR_IN_WRITE + BYTES_PER_WORD;
    const uint32_t IIR_IN_DATA       = IIR_IN_ADDR  + BYTES_PER_WORD;
    const uint32_t IIR_OUT_ADDR      = IIR_IN_DATA  + BYTES_PER_WORD;
    const uint32_t IIR_OUT_DATA      = IIR_OUT_ADDR + BYTES_PER_WORD;
    const uint32_t IIR_DONE          = 0;
    const uint32_t IIR_RESET = 40;
    const uint32_t IIR_SHIFT = 48;
    const uint32_t IIR_SHIFT2= 56;

    // Constants from FIR.h
    const uint32_t FIR_BLOCK_BITS    = 32;
    const uint32_t FIR_BLOCK_BYTES   = FIR_BLOCK_BITS / BITS_PER_BYTE;
    const uint32_t FIR_BLOCK_WORDS   = FIR_BLOCK_BYTES / BYTES_PER_WORD;
    const uint32_t FIR_START         = 0;
    const uint32_t FIR_IN_WRITE      = 0;
    const uint32_t FIR_IN_ADDR       = FIR_IN_WRITE + BYTES_PER_WORD;
    const uint32_t FIR_IN_DATA       = FIR_IN_ADDR  + BYTES_PER_WORD;
    const uint32_t FIR_OUT_ADDR      = FIR_IN_DATA  + BYTES_PER_WORD;
    const uint32_t FIR_OUT_DATA      = FIR_OUT_ADDR + BYTES_PER_WORD;
    const uint32_t FIR_DONE          = 0;
    const uint32_t FIR_RESET        = 40;
    const uint32_t FIR_SHIFT        = 48;
    const uint32_t FIR_SHIFT2       = 56;   

    // ------------------------------------------------------------------------------------------------------------
    // Constants related to the Surrogate Root of Trust
    // These constants MUST be equal to those in llki_pkg.sv
    //
    // Additional, those constants which are addresses (i.e., ***_ADDR) are offsets
    // within the SRoT memory map.  
    //
    // Note: Other LLKI related constants/definitions may be found in cep_crypto.h
    // ------------------------------------------------------------------------------------------------------------
    const uint32_t SROT_KEYINDEXRAM_ADDR            = 0x00000100;   // Offset from SROT base address
    const uint32_t SROT_KEYINDEXRAM_SIZE            = 0x00000020;   // 32 64-bit words
    const uint32_t SROT_KEYRAM_ADDR                 = 0x00000200;   // Offset from SROT base address
                                                                    // Note: This cannot be less than SROT_KEYINDEXRAM_ADDR + (SROT_KEYINDEXRAM_SIZE * 8)!!!
    const uint32_t SROT_KEYRAM_SIZE                 = 0x00000800;   // 2048 64-bit words

    // Reminder: data width is 64-bits
    const uint32_t SROT_CTRLSTS_ADDR                = 0x00000000;
    const uint32_t SROT_CTRLSTS_MODEBIT0_MASK       = 0x0000000000000001;   // If either mode bit is set, TileLink access to the Key and Key Index RAMs are disabled
                                                                            // These bits are SET ONLY    
    const uint32_t SROT_CTRLSTS_MODEBIT1_MASK       = 0x0000000000000002;
    const uint32_t SROT_CTRLSTS_RESP_WAITING_MASK   = 0x0000000000000004;
 
    const uint32_t SROT_LLKIC2_SENDRECV_ADDR        = 0x00000008;
    const uint32_t SROT_LLKIC2_SCRATCHPAD0_ADDR     = 0x00000010;
    const uint32_t SROT_LLKIC2_SCRATCHPAD1_ADDR     = 0x00000018;
    // ------------------------------------------------------------------------------------------------------------


#endif