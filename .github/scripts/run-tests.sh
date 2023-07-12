#!/bin/bash

# run the different tests

# turn echo on and error on earliest command
set -ex

# get remote exec variables
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
source $SCRIPT_DIR/defaults.sh

DISABLE_SIM_PREREQ="BREAK_SIM_PREREQ=1"

run_bmark () {
    make run-bmark-tests-fast -j$CI_MAKE_NPROC -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ $@
}

run_asm () {
    make run-asm-tests-fast -j$CI_MAKE_NPROC -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ $@
}

run_both () {
    run_bmark $@
    run_asm $@
}

run_tracegen () {
    make tracegen -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ $@
}

run_none () {
    make -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ run-binary-fast BINARY=none $@
}

case $1 in
    chipyard-rocket)
        run_bmark ${mapping[$1]}
        make -C $LOCAL_CHIPYARD_DIR/tests
        make -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ ${mapping[$1]} run-binary LOADMEM=1 BINARY=$LOCAL_CHIPYARD_DIR/tests/hello.riscv
        make -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ ${mapping[$1]} run-binary BINARY=$LOCAL_CHIPYARD_DIR/tests/hello.riscv
        ;;
    chipyard-dmirocket)
        $LOCAL_CHIPYARD_DIR/scripts/generate-ckpt.sh -b $RISCV/riscv64-unknown-elf/share/riscv-tests/benchmarks/dhrystone.riscv -i 10000
        make -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ ${mapping[$1]} run-binary LOADARCH=$PWD/dhrystone.riscv.0x80000000.10000.loadarch
        ;;
    chipyard-boom)
        run_bmark ${mapping[$1]}
        ;;
    chipyard-shuttle)
        run_bmark ${mapping[$1]}
        ;;
    chipyard-dmiboom)
        $LOCAL_CHIPYARD_DIR/scripts/generate-ckpt.sh -b $RISCV/riscv64-unknown-elf/share/riscv-tests/benchmarks/dhrystone.riscv -i 10000
        make -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ ${mapping[$1]} run-binary LOADARCH=$PWD/dhrystone.riscv.0x80000000.10000.loadarch
        ;;
    chipyard-spike)
        run_bmark ${mapping[$1]}
        ;;
    chipyard-hetero)
        run_bmark ${mapping[$1]}
        ;;
    chipyard-prefetchers)
        make -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ ${mapping[$1]} run-binary BINARY=$RISCV/riscv64-unknown-elf/share/riscv-tests/benchmarks/dhrystone.riscv
        ;;
    rocketchip)
        run_bmark ${mapping[$1]}
        ;;
    chipyard-hwacha)
        make run-rv64uv-p-asm-tests -j$CI_MAKE_NPROC -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ ${mapping[$1]}
        ;;
    chipyard-gemmini)
        GEMMINI_SOFTWARE_DIR=$LOCAL_SIM_DIR/../../generators/gemmini/software/gemmini-rocc-tests
        rm -rf $GEMMINI_SOFTWARE_DIR/riscv-tests
        cd $LOCAL_SIM_DIR
        make -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ ${mapping[$1]} run-binary-fast BINARY=$GEMMINI_SOFTWARE_DIR/build/bareMetalC/aligned-baremetal
        make -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ ${mapping[$1]} run-binary-fast BINARY=$GEMMINI_SOFTWARE_DIR/build/bareMetalC/raw_hazard-baremetal
        make -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ ${mapping[$1]} run-binary-fast BINARY=$GEMMINI_SOFTWARE_DIR/build/bareMetalC/mvin_mvout-baremetal
        ;;
    chipyard-sha3)
        (cd $LOCAL_CHIPYARD_DIR/generators/sha3/software && ./build.sh)
        make -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ ${mapping[$1]} run-binary-fast BINARY=$LOCAL_CHIPYARD_DIR/generators/sha3/software/tests/bare/sha3-rocc.riscv
        ;;
    chipyard-mempress)
        (cd $LOCAL_CHIPYARD_DIR/generators/mempress/software/src && make)
        make -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ ${mapping[$1]} run-binary-fast BINARY=$LOCAL_CHIPYARD_DIR/generators/mempress/software/src/mempress-rocc.riscv
        ;;
    chipyard-manymmioaccels)
	make -C $LOCAL_CHIPYARD_DIR/tests

	# test streaming-passthrough
        make -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ ${mapping[$1]} run-binary-fast BINARY=$LOCAL_CHIPYARD_DIR/tests/streaming-passthrough.riscv

	# test streaming-fir
        make -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ ${mapping[$1]} run-binary-fast BINARY=$LOCAL_CHIPYARD_DIR/tests/streaming-fir.riscv

	# test fft
        make -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ ${mapping[$1]} BINARY=$LOCAL_CHIPYARD_DIR/tests/fft.riscv run-binary-fast
	;;
    chipyard-nvdla)
	make -C $LOCAL_CHIPYARD_DIR/tests

	# test nvdla
        make -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ ${mapping[$1]} BINARY=$LOCAL_CHIPYARD_DIR/tests/nvdla.riscv run-binary-fast
	;;
    chipyard-manyperipherals)
	# SPI Flash read tests, then bmark tests

        make -C $LOCAL_CHIPYARD_DIR/tests
        make -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ ${mapping[$1]} BINARY=$LOCAL_CHIPYARD_DIR/tests/spiflashread.riscv run-binary-fast

	run_bmark ${mapping[$1]}
        ;;
    chipyard-spiflashwrite)
        make -C $LOCAL_CHIPYARD_DIR/tests
        make -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ ${mapping[$1]} BINARY=$LOCAL_CHIPYARD_DIR/tests/spiflashwrite.riscv run-binary-fast
        [[ "`xxd $LOCAL_CHIPYARD_DIR/tests/spiflash.img  | grep 1337\ 00ff\ aa55\ face | wc -l`" == "6" ]] || false
        ;;
    tracegen)
        run_tracegen ${mapping[$1]}
        ;;
    tracegen-boom)
        run_tracegen ${mapping[$1]}
        ;;
    chipyard-cva6)
        make run-binary-fast -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ ${mapping[$1]} BINARY=$RISCV/riscv64-unknown-elf/share/riscv-tests/benchmarks/multiply.riscv
        ;;
    chipyard-ibex)
        # Ibex cannot run the riscv-tests binaries for some reason
        # make run-binary-fast -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ ${mapping[$1]} BINARY=$RISCV/riscv64-unknown-elf/share/riscv-tests/isa/rv32ui-p-simple
        ;;
    chipyard-sodor)
        run_asm ${mapping[$1]}
        ;;
    chipyard-constellation)
        make run-binary-hex BINARY=$RISCV/riscv64-unknown-elf/share/riscv-tests/benchmarks/dhrystone.riscv -C $LOCAL_SIM_DIR $DISABLE_SIM_PREREQ ${mapping[$1]}
        ;;
    icenet)
        run_none ${mapping[$1]}
        ;;
    testchipip)
        run_none ${mapping[$1]}
        ;;
    constellation)
        run_none ${mapping[$1]}
        ;;
    rocketchip-amba)
        run_none ${mapping[$1]}
        ;;
    rocketchip-tlsimple)
	run_none ${mapping[$1]}
        ;;
    rocketchip-tlwidth)
	run_none ${mapping[$1]}
        ;;
    rocketchip-tlxbar)
	run_none ${mapping[$1]}
        ;;
    *)
        echo "No set of tests for $1. Did you spell it right?"
        exit 1
        ;;
esac
