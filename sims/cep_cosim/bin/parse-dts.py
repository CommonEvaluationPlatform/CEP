#!/usr/bin/python3
#//************************************************************************
#// Copyright 2024 Massachusetts Institute of Technology
#//
#// File Name:      parse-dts.py
#// Program:        Common Evaluation Platform (CEP)
#// Description:    Parses the specified DTS file for the number
#//                 of module instances matching a certain filters
#// Notes:          
#//
#//************************************************************************

import sys
import re
import os

if (len(sys.argv) != 3):
  sys.exit(sys.argv[0] + " : [ERROR] Usage: <DTS file> <filter>")

# Save the arguments
inputFileName = sys.argv[1]
filter        = sys.argv[2]
regex         = re.compile(filter)

# initialize our match counter
count         = 0

# DO some error checking
if (not os.path.exists(inputFileName)):
  sys.exit(sys.argv[0] + " : [ERROR] DTS File does not exist.")

with open(inputFileName, "r") as inputFile:
  for line in inputFile:
    if regex.search(line):
      count = count + 1

print(count)
