[//]: # (Copyright 2024 Massachusetts Institute of Technology)
[//]: # (SPDX short identifier: BSD-3-Clause)

[![DOI](https://zenodo.org/badge/108179132.svg)](https://zenodo.org/badge/latestdoi/108179132)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-orange.svg)](https://opensource.org/licenses/BSD-3-Clause)

# CEP Changelog

## [v4.60] - 2024-XX-XX

### Added
### Changed
  - Chipyard upgraded to v1.11.0
### Fixed
### Issues

## [v4.50] - 2024-01-25

### Added
### Changed
  - Chipyard upgraded to v1.10.0
### Fixed
  - Issue #7: COSIM: XCellium *occasional* failures on RHEL7
### Issues
  - cep_vcu118 SUB_PROJECT currently does not build
  - cep_cosim on QuestaSim: 
    - isaTests: Virtual mode support not implemented, rv64u*-v-* tests fail
    - isaTests: rv64u* tests failing
    - bareMetalTests: macro4mix and macroMix tests failing

## [v4.41] - 2023-03-02

### Added
### Changed
  - Issue #15: idft_top.v and dft_top.v added to repository due to less restrictive licenses
### Fixed
  - Issue #18: COSIM: bareMetal macro(n)Mix tests failing
  - Issue #4:  COSIM: FullBoot needs to be updated with new BAREMETAL_PRINTF switches

## [v4.4] - 2022-12-01

### Added
  - Added support for Ubuntu 20.04 LTS w/libcrypto++8

### Changed
  - Updated Chipyard to v1.8.1

### Fixed


## [v4.30] - 2022-11-14

### Added
  - Add cep_verilator SUB_PROJECT to allow for Verilator-based CEP simulations
  - Modified all bare-metal cosimulation tests to support execution on Verilator (However, not all tests pass)

### Changed
  - Removed all // synopsys full_case parallel_case synthesis directives
  - Performed verilator-based lint cleanup of CEP verilog/system verilog code

### Fixed
  - GPS pcode Known Answer Tests now agrees with the HW

## [v4.20] - 2022-08-03

### Added
* Added kgetc to bare metal console routines
* Verified firemarshal generated linux build boots on the Arty100T, VC707, and VCU118.  Instructions added to [README.md](./README.md)
* Added `helloworld` and `gpiotest` to ./software/linux.  Makefiles allow application's install to firemarshal's buildroot.
* Added VC707 CEP FPGA target thanks to the folks at NECSTLab (https://github.com/necst)
* Added VCU118 CEP FPGA target

### Changed
* Unified console print routines across bootroms, cosim baremetal, and standalone bare metal code.  Bare metal prints are now handled using stdio functions with
  putchar, getchar, and putstr being mapped to the console versions

### Known issues
* cep_cosim
  * Cadence XCellium on RHEL7 *occasionally* fails some of the bareMetal tests.  Root cause has not been determined, but it is recommended that the test be re-run.
  * Known est failures: 
    * ./testSuites/bfmTests/macroMix - GPS Test - First core passes, subsequent cores fail.
    * Virtual mode ISA tests - Failure on Questsim/Ubuntu, passes on XCellium/RHEL7
    * ./testSuites/isaTests/rv64mi-p-csr
    * ./testSuites/isaTests/rv64si-p-csr
    * ./testSuites/bfmTests/srotErrorTest
    * ./testSuites/bareMetalTests/plicPrioIntr
    * ./testSuites/bareMetalTests/extIntr
    * ./testSuites/bareMetalTests/lsrcOps
    * ./testSuites/isaTests/dtmTest

## [v4.10] - 2022-07-01

### Added
* Added a bareMetal/aesMacro test for running on the Arty100T build, which currently only has one AES core and the SRoT

### Changed
* Unified/debugged console printf functionality when building bare metal executables.  By default, it is disabled, but can be enabled with the ENABLE_KPRINTF directive
* Arty100T and cep_sim use the same 'sd.c' source file, but leverage different makefiles.
* Misc. code and readme cleanup
* Bumped Chipyard to 1.7.0 from 1.5.0.  See [CHANGELOG](./CHANGELOG.md).
* Rocket-Chip bumped to v1.5

### Fixed
* iDFT test code fixed in cep_idft.cc

## [v4.00] - 2022-06-21

### Added
* Chipyard Arty100t branch merged in (Commit 4440db0, March 4, 2022)

### Changed
* CHANGELOG.CEP.md updated based on guidance from *keep a changelog* (https://keepachangelog.com/en/1.0.0/)
* CEP has been completely ported to the UCB Chipyard Framework (https://github.com/ucb-bar/chipyard)
* Arty-A7 100T FPGA target running bare-metal code is currently supported (Linux is not currently supported)

## v3.41 - (10 September 2021)
* CEP Configuration nows includes 4xGPS and 4xSHA-256 cores
* Integrated configurable co-simulation environment (provide a co-sim that can more easily adapt to CEP architecture changes)
* Known Issues:
  - Some idft test vectors fail under QuestaSim (xcellium regression ran successfully)
  - Multithreaded test (#23) non-functional under linux

##v3.4 - (6 August 2021)
* Added external interrupt test (extIntr)
* Added test to boot rom to verify code execution out of scratchpad is working
* Added cryptoMask to cep_srot to support individual key loading only if enable
* Restructured cosim Makefiles to support re-use from other repos
* Modified cadence Makefile to enable partial toggle scoring
* Changed un-initialized main memory default state (from 0 -> 1) to improve coverage
* Addressed an LLKI bug in which the LLKI-PP component would send a respond to the SRoT before llkid_key_complete is asserted by the mock_tss_fsm
* Fixed GPS port directions in verilog
* Scratchpad RAM changed to blackbox implementation to facilitate ASIC development
* OpenSSL replaced by Cryptopp for crypto-related tests (cosim + linux)

##v3.3 - (19 May 2021)
* Increased capacity for LLKI key size including larger KeyRAM (2048 64-bit words)
* Added Cosim JTAG/OpenOCD 
* Stability fixes for cep_diag under Linux 
* Virtual Address TLB test suite is added to regression (not 100% complete)
* Expanded cep_diag
* New simulation ONLY interrupt tests for CLINT and PLIC modules (on going)
* Re-capture vectors for unit sim due to changes in LLKI key size
* Bootrom size is increased to 32K bytes (8kx32) to accomodate new built-in test (execute codes out of bootrom without main memory)

##v3.2 - (16 April 2021)
* LLKI bug fixes 
* Scratchpad RAM added
* Cadenece xcelium simulator and coverage support added
* Linux tests updated and expanded
* New tests added to cosim focused on LLKI and Scratchpad RAM

##v3.11 - (29 March 2021)
* Unit Simulations updated for full LLKI support
* GPS core bugfix to provide specification compliance and increase functional coverage
* SRoT tests added
* SRoT has been updated to use a single port (1RW) RAM.
* Misc. bug fixes and README cleanup
* Known Issues:
  - cep_diag (on Linux) has NOT been updated to work with the LLKI.  Thus, running the tests that use
    the CEP cores (e.g., cep_aes, cep_des3, etc.) will result in failure

##v3.1 - (22 February 2021) 
* Full LLKI support (All CEP cores are now LLKI enabled)
* Known Issues:
  - cep_diag (on Linux) has NOT been updated to work with the LLKI.  Thus, running the tests that use
    the CEP cores (e.g., cep_aes, cep_des3, etc.) will result in failure
  - rv64si-p-dirty ISA test fails
  - unit_simulations need to be updated to be compatible with the LLKI

##v3.01 - (19 December 2020)
* Removed used flash model reference in cep_tb.v

##v3.0 - (18 December 2020)
* Initial LLKI release with Surrogate Root of Trust
* AES core replaced with LLKI-enabled AES core, all other cores remain unchanged

##v2.71 - (2 November 2020)
* Corrected README.md issue

##v2.7 - (28 October 2020)
* Added support for RISC-V ISA tests (under ./cosim/isaTests)
* Updated license statements to BSD-2-Clause
* KNOWN ISSUES:
  - The iCacheCoherency passes when running bare-metal simulation, but fails when running on the VC-707.  There is an issue with
    the iCache protocol that the tight-looped iCache coherency test results in one or more of the Rocket Cores (there are 4 in 
    the CEP) L1 iCache not getting the value associated with the most recent write to instruction memory.

    Functionally, this should only cause an issue when dealing with self-modifying code, which is an atypical coding practice.

  - The following cosim tests fail when run under RHEL using the "new" RISC-V toolchain:
    - bareMetalTests/cacheCoherence
    - isaTests/rv64mi-p-access 
    - isaTests/rv64ud-p-ldst

##v2.61 - (2 October 2020)
  - Added initial simulation support for Cadence XCellium
  - Cosim: Expanded DDR3 memory size to support "larger" bare-metal executables created by the new RISCV toolchain released with v2.6

##v2.6 - (18 September 2020)
* Rocket-Chip and Freedom repositories updated.  Source responsitory list:
    https://github.com/sifive/freedom/tree/8622a684e7e54d0a20df90659285b9c587772629              - Aug 19, 2020
    https://github.com/chipsalliance/rocket-chip/tree/d2210f9545903fad40c9860389cdcf9c28515dba   - Apr  2, 2020
    https://github.com/sifive/fpga-shells/tree/19d0818deda5d295154992bd4e2c490b7c905df9          - Jan 28, 2020
    https://github.com/sifive/sifive-blocks/tree/12bdbe50636b6c57c8dc997e483787fdb5ee540b        - Dec 17, 2019
    https://github.com/mcd500/freedom-u-sdk/tree/29fe529f8dd8e1974fe1743184b3e13ebb2a21dc        - Apr 12, 2019
* riscv-tools (formerly under rocket-chip) now located in ./software/riscv-gnu-toolchain
* KNOWN ISSUES:
    - The iCacheCoherency passes when running bare-metal simulation, but fails when running on the VC-707.  There is an issue with
      the iCache protocol that the tight-looped iCache coherency test results in one or more of the Rocket Cores (there are 4 in 
      the CEP) L1 iCache not getting the value associated with the most recent write to instruction memory.

      Functionally, this should only cause an issue when dealing with self-modifying code, which is an atypical coding practice.

##v2.52 - (2 September 2020)
* Added ./doc/CEP_TestDescriptions.pdf

##v2.51 - (7 August 2020)
* Legacy unused core wrapper files (axi4lite and wb) removed

##v2.5 - (31 July 2020)
* All Unit-level testbenches have been expanded to optional support the Logic Locking Keying Interface (LLKI)
  for both cycle-level and transactional-level modes

##v2.4 - (5 June 2020)
* CEP core test coverage expanded
* Unit testbenches transactional-level support added
* AES-derived and FIR-derived generated cores added
* Misc. bug fixes

##v2.3 - (17 April 2020)
* Added unit-level testbenches for all CEP cores.  Co-simulation modified to generate unit-level test stimulus.  

##v2.2 - (31 January 2020)
* Added co-simulation environment that supports both Bus Functional Model (BFM) and Baremetal simulation modes.  Additional diagnostic capabilities within Linux.

##v2.1 - (31 October 2019)
* Integrated DES3, GPS, MD5, RSA, SHA256, DFT, IDFT, and IIR cores.

##v2.0 - (16 August 2019)
* Major Update: mor1k proceesor core replaced with the UCB Rocket-Chip within the SiFive Freedom U500 Platform.  All modules have been updated to support TileLink natively.  Currently only the AES and FIR cores have been integrated, but v2.1 will include the re-release of all the CEP cores.   

##v1.2 - (15 November 2018)
* Major Update: The underlying bus has been converted from Wishbone-B4 to AXI4-Lite.  All cores as well as the MOR1KX has been wrapped with translation modules.  All the wrapping logic and interconnect are now in SystemVerilog.
* Regression Suite: In additon to each core's unit tests, a regression test suite has been included.  When compiled by the or1k toolchain, it be loaded/synthesized into the CEP RAM block and run at boot time.
* Modelsim Testing: Unit-level and system-level modelsim-based testbenches added
* GPS clkgen: The GPS clock gen component has been moved to the top level of the CEP, simplifying its replacement when targetting an ASIC.
* Misc. bug fixes

##v1.1.1 - (27 September 2018)
* Added CEP\_utilization\_placed.rpt in implSummaries directory.  This summarizes utlization of the CEP v1.1 targetted to the VC707 using Vivado 2018.1.

##v1.1 - (19 July 2018)
* Directory structure has been reorganized (details below)
* Upgraded to the non-deprecated mor1kx (added as a subnodule)
* Verified with both the pre-built and build-your-own version of the Newlib toolchain as described on [http://openrisc.io](http://openrisc.io)
* In addition to test vectors for each of the cores, some additional test_software, such as "hello world", have been added for reference
* Expanded testbench (details below)
* Bug fixes and general code cleanup [Additional details in the git commit history]

##v1.0 - Initial release (15 Aug 2017)

#### Return to the root CEP [README](./README.md)
