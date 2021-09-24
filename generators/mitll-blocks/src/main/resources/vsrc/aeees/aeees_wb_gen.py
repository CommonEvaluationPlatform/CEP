#!/usr/bin/python3
#//************************************************************************
#// Copyright 2021 Massachusetts Institute of Technology
#// SPDX short identifier: BSD-2-Clause
#//
#// File Name:      aeees_wb_gen.py
#// Program:        Common Evaluation Platform (CEP)
#// Description:    Helper script for aeees.py
#//
#// Notes:          
#//
#//************************************************************************

import os
import sys
import random
from jinja2 import Environment, Template, FileSystemLoader
import aeees_emu

def aeees_wb_gen( args, env ):
    key = int( args.key, 16 )
    rounds = args.rounds
    trials = args.trials
    
    engine = aeees_emu.AEEES( key, rounds )
    template = env.get_template( 'fnsbox_wb.t')

    for round in range(1, rounds+1):
        bauxfn = "aeees_box_%d.vi" % ( round )
        if args.verbose:
            print("Generating S-Boxes for round %d to file %s" % (round, bauxfn))

        with open( os.path.join( args.dirname, bauxfn), "w") as fh:
            print( """/*
 * A(EE)ES AUTOGENERATED S-BOXES.  DO NOT EDIT.
 */
""", file=fh)

            for idx in range(0, 16):
                print( template.render( dut_name=args.dut_name, round=round, idx=idx, box=engine.get_modded_sbox(round, idx)), file=fh)

    if args.verbose:
        print("Generating %d-round AEEES-SBOX-WB rounds source to file aeees_rounds.v" % (rounds))

    template = env.get_template( 'rounds_wb.t')
    with open( os.path.join( args.dirname, "aeees_rounds.v"), "w") as fh:
        print( template.render( dut_name = args.dut_name, num_rounds = rounds), file=fh)

    if args.verbose:
        print("Generating %d-round AEEES-SBOX-WB toplevel module to file aeees.v" % (rounds))

    template = env.get_template( 'aeees_wb_gen.t')
    with open( os.path.join( args.dirname, "aeees.v"), "w") as fh:
        print( template.render( dut_name = args.dut_name, num_rounds = rounds), file=fh)

    if args.verbose:
        print("Generating AES shift and mix functions to file aeees_roundfn.vi")

    template = env.get_template( 'roundfn_wb.t')
    with open( os.path.join( args.dirname, "aeees_roundfn.vi"), "w") as fh:
        print( template.render( dut_name = args.dut_name), file=fh)

    if args.verbose:
        print("Generating testbench stimulus with %d cases to file aeees_stimulus.csv" % (trials))

    num_samples = 0
    with open( os.path.join( args.dirname, "aeees_stimulus.csv"), "w") as fh:
        print("// AUTOGENERATED:  DO NOT EDIT", file=fh)
        for t in range(trials):
            plaintext = random.getrandbits(128)
            ## could use encrypt_wb here; it's slower, though, and we don't care about
            ## intermediate results
            ciphertext = engine.encrypt( plaintext )

            # start_plaintext_key_outvalid_out, in that order
            print("0_%32.32x_X_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" % (plaintext), file=fh)
            print("1_%32.32x_X_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" % (plaintext), file=fh)
            for i in range( rounds):
                print("0_%32.32x_0_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" % (plaintext), file=fh)
            print("0_%32.32x_1_%32.32x" % (plaintext, ciphertext[ rounds]), file=fh)
            num_samples = num_samples + (rounds + 3)

    if args.verbose:
        print("Generating testbench to file aeees_tb.sv")

    template = env.get_template( 'aeees_wb_tb.t')
    with open( os.path.join( args.dirname, "aeees_tb.sv"), "w") as fh:
        print( template.render(dut_name = args.dut_name, r = rounds, num_samples = num_samples ), file=fh)


if __name__ == "__main__":
    import sys
    sys.exit("ERROR:  Invoke the tool as aeees.py instead.")
        
