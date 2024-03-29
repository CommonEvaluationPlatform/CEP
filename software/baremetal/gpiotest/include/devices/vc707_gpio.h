//************************************************************************
// Copyright 2024 Massachusetts Institute of Technology
// SPDX short identifier: BSD-3-Clause
//
// File Name:      vc707_gpio.h
// Program:        Common Evaluation Platform
// Description:    Bit mappings for the CEP's Arty100T GPIO
// Notes:          
//
//************************************************************************

#ifdef VC707_TARGET
#ifndef _VC707_GPIO_H
#define _VC707_GPIO_H

#define SW0_MASK        (0x00000001)
#define SW1_MASK        (0x00000002)
#define SW2_MASK        (0x00000004)
#define SW3_MASK        (0x00000008)
#define SW4_MASK        (0x00000010)
#define SW5_MASK        (0x00000020)
#define SW6_MASK        (0x00000040)
#define SW7_MASK        (0x00000080)
#define SWN_MASK        (0x00000100)
#define SWE_MASK        (0x00000200)
#define SWS_MASK        (0x00000400)
#define SWW_MASK        (0x00000800)
#define SWC_MASK        (0x00001000)
#define LED0_MASK       (0x00002000)
#define LED1_MASK       (0x00004000)
#define LED2_MASK       (0x00008000)
#define LED3_MASK       (0x00010000)
#define LED4_MASK       (0x00020000)
#define LED5_MASK       (0x00040000)
#define LED6_MASK       (0x00080000)
#define LED7_MASK       (0x00100000)

#define SWtoLED_SHIFT	5
#define SWtoLED_MASK	(0x00000F00)

#endif /* _VC707_GPIO_H */
#endif /* VC707_TARGET */