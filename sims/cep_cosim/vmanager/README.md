[//]: # (Copyright 2022 Massachusetts Institute of Technology)

# Common Evaluation Platform v3.6 - VManager Setup instructions

Setup the vManager Server:
1. Navigate to the vmanager/scripts/vmanager_server_setup directory. A script package
   is available in this directory to manage creation and maintenance of vManager.

2. To set up a vManager server instance execute the command below. This creates 
   a script vmanager_service_<vmgr_version> in the same directory which allows 
   stopping, starting, and restarting the server. When the server is first created 
   it is also started so you should be able to skip step 3.: 
     ./vmanager_server_setup -db_port <db_port_number> -vmgr_server <vmgr_server_port>
     e.g.: ./vmanager_server_setup -db_port 5510 -vmgr_server_port 8810

3. To start/stop the vManager server execute the following command: 
     vmanager_service_<vmgr_version> <start/stop>
     e.g.: ./vmanager_service_VMANAGERAGILE20.06.001 stop

4. Once the vManager server has been created and started, you can launch the vManager 
   GUI. To launch the GUI execute the following command:
     vmanager -server <machine_name : port_number>
     e.g.: vmanager -server 566195-mitll:8810

Setup the environment variables:
1. The environment variables needed to run the included vManager scripts are located 
   in scripts/tracking_environment_setup.csh. The CEP_INSTALL variable needs to
   be modified to point to the cep_cosim directory within the CEP Chipyard repo. These
   variables need to either be added to your profile or this file needs to be sourced. 
   The variables included in the file are:
     CEP_INSTALL – where the CEP cosim environment is installed 
     MY_REGRESSION/MY_REGRESSION_AREA - testSuite regression area
     VM_DASHBOARD – scripts area
     VPLAN_TOP – point to directory containing vPlans
     VMGR_VERSION/VMGR_DIR – Where vManager software is installed
     XCELIUM_VERSION/XCELIUM_DIR – Where xcelium software is installed
     RISCV – Points to riscv toolchain
     LM_LICENSE_FILE – license file for Cadence tools

Run tests:
1. You should now be able to either launch the vsif files for each test suite from
   the vManager GUI, or continue with the instructions provided in vManager_setup.readme.txt.
   The vsif files are located in vmanager/vsif.
   
   