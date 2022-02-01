#!/usr/bin/python3
#//************************************************************************
#// Copyright 2021 Massachusetts Institute of Technology
#//
#// File Name:      convert-bootrom.py
#// Program:        Common Evaluation Platform (CEP)
#// Description:    Generates an ARM Compiled ROM compatible version
#//                 of the CEP Bootrom
#// Notes:          - Convert .img to .hex (as binary2ascii does)
#//                 - Pad out to a specified number of lines
#//
#//************************************************************************

import sys
import re
import os
import binascii

if (len(sys.argv) != 4):
  sys.exit(sys.argv[0] + " : [ERROR] Usage: <inputFile> <outputFile> <# of lines to pad to>")

# Save the arguments
inputFile    = sys.argv[1]
outputFile   = sys.argv[2]
padToLines   = sys.argv[3]

# DO some error checking
if (not os.path.exists(inputFile)) or (inputFile == outputFile):
  sys.exit(sys.argv[0] + " : [ERROR] inputFile does not exist or inputFile == outputFile.")

# Open input nad output files
inputFile_fd    = open(inputFile, "rb")
#outputFile_fd   = open(outputFile, "w")

# Read input file into byte array
inputFile_data  = bytearray(inputFile_fd.read())

print(sys.argv[0] + " : Input file is",len(inputFile_data), "bytes.")

for x in inputFile_data:
  print(binascii.b2a_hex(x))

# Close open files
inputFile_fd.close()
#outputFile_fd.close()
