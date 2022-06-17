#!/usr/bin/python3
#//************************************************************************
#// Copyright 2022 Massachusetts Institute of Technology
#// SPDX short identifier: BSD-2-Clause
#//
#// File Name:      manage-export.py
#// Program:        Common Evaluation Platform (CEP)
#// Description:    Supports exporting/importing of the CEP releases
#//                 from the internal to external repositories  
#// Notes:          
#//
#//************************************************************************

# replaces a `include with the full include file
#
# args
# $1 - Operation: 'import' or 'export'
import os
import sys
import subprocess

# Check the arguments
if (len(sys.argv) != 2 or (sys.argv[1] != "import" and sys.argv[1] != "export")):
  sys.exit("Usage: " + __file__ +" <import | export>")

# Grab the repo's root directory and change current working directory accordingly
repoRoot, repoRootErr = subprocess.Popen(['git', 'rev-parse', '--show-toplevel'], stdout=subprocess.PIPE).communicate()
repoRoot = repoRoot.decode('utf-8').strip() if repoRoot else u''
os.chdir(repoRoot)
cwd = os.getcwd()

print("Current working directory: {0}".format(cwd))

# Perform an inport or export operation
if (sys.argv[1] == "export"):

  # Run the git submodule command with the output being a list of lists, which each sublist being a pair of commit and path
  gitSubmoduleStatus, gitSubmoduleStatusErr = subprocess.Popen(['git', 'submodule'], stdout=subprocess.PIPE).communicate()
  gitSubmoduleStatus = gitSubmoduleStatus.decode('utf-8') if gitSubmoduleStatus else u''
  gitSubmoduleStatus = gitSubmoduleStatus.split()
  gitSubmoduleStatus = [x for x in gitSubmoduleStatus if not x.startswith('(')]
  gitSubmoduleStatus = [x.replace("-", "") if x.startswith('-') else x for x in gitSubmoduleStatus]
  gitSubmoduleStatus = [gitSubmoduleStatus[x:x+2] for x in range(0, len(gitSubmoduleStatus), 2)]


  # Read .gitmodules into a list and process it
  with open(".gitmodules") as file:
    gitModules = file.readlines()
  gitModules = [x.strip() for x in gitModules]
  gitModules = [x for x in gitModules if x.startswith('[submodule') or x.startswith('path') or x.startswith('url')]
  gitModules = [x.replace('[submodule "', '') for x in gitModules]
  gitModules = [x.replace('"]', '') for x in gitModules]
#  gitModules = [gitModules[x:x+3] for x in range(0, len(gitModules), 3)]
  print(gitModules)


else:
  print("import")
