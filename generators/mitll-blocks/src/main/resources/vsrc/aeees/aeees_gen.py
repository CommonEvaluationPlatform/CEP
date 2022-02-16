#!/usr/bin/python3
#//************************************************************************
#// Copyright 2022 Massachusets Institute of Technology
#// SPDX short identifier: BSD-2-Clause
#//
#// File Name:      aeees_gen.py
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

def aeees_gen( args, env ):
    rounds = args.rounds
    trials = args.trials

    rcl = [ num for num in range(1, rounds) ]
    swires = ", ".join( map( lambda x: "s%d" % (x), rcl ))
    kwires = ", ".join( map( lambda x: "k%d" % (x), rcl ))
    kbwires = ", ".join( map( lambda x: "k%db" % (x), rcl ))
    
    ## this is actually how AES round constants are computed; we are just extending it
    ## to the point of nausea.
    rcons = [ 1 ]
    for i in range(1, rounds):
        if( rcons[i-1] >= 128 ):
            rcons.append( ((2 * rcons[i-1]) ^ 0x1B) % 256)
        else:
            rcons.append( 2 * rcons[i-1])
           
    expanders = ",\n    ".join( map( lambda x: "a%d ( clk, k%d, k%d, k%db, 8'h%2.2x)" % (x[0], x[0]-1, x[0], x[0]-1, x[1] ), zip(rcl, rcons) ))
    onerounds = ",\n    ".join( map( lambda x: "r%d (clk, rst, s%d, k%db, s%d)" % (x, x-1, x-1, x), rcl))
            
    if args.verbose:
        print("Generating %d-round AEEES to file aeees.v" % (rounds))
                
    with open( os.path.join( args.dirname, "aeees.v"), "w") as fh:
        template = env.get_template( 'aeees_gen.t')
        print( template.render(dut_name = args.dut_name, r = rounds, swires = swires, kwires = kwires, kbwires = kbwires, expanders = expanders, onerounds = onerounds, lastrcon = "%2.2x" % (rcons[ len(rcons)-1 ]) ), file=fh)
                
    if args.verbose:
        print("Generating associated round and table files to aeees_rounds.v and aeees_table.v")

    with open( os.path.join( args.dirname, "aeees_rounds.v"), "w") as fh:
        template = env.get_template( 'rounds.t')
        print( template.render(dut_name = args.dut_name), file=fh)
    with open( os.path.join( args.dirname, "aeees_table.v"), "w") as fh:
        template = env.get_template( 'table.t')
        print( template.render(dut_name = args.dut_name), file=fh)
                                          
    if args.verbose:
        print("Generating testbench stimulus with %d cases to file aeees_stimulus.csv" % (trials))
                                          
    num_samples = 0
    with open( os.path.join( args.dirname, "aeees_stimulus.csv"), "w") as fh:
        print("// AUTOGENERATED:  DO NOT EDIT", file=fh)
        for t in range(trials):
            plaintext = random.getrandbits(128)
            key = random.getrandbits(128)
            engine = aeees_emu.AEEES( key, rounds )
            ciphertext = engine.encrypt( plaintext )
            # start_plaintext_key_outvalid_out, in that order
            print("0_%32.32x_%32.32x_X_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" % (plaintext, key), file=fh)
            print("1_%32.32x_%32.32x_X_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" % (plaintext, key), file=fh)
            for i in range( 2*rounds + 1):
               print("0_%32.32x_%32.32x_0_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" % (plaintext, key), file=fh)
            print("0_%32.32x_%32.32x_1_%32.32x" % (plaintext, key, ciphertext[ rounds]), file=fh)

            num_samples = num_samples + (2*rounds + 4)

    if args.verbose:
        print("Generating testbench to file aeees_tb.sv")

    with open( os.path.join( args.dirname, "aeees_tb.sv"), "w") as fh:
        template = env.get_template( 'aeees_tb.t')
        print( template.render(dut_name = args.dut_name, r = rounds, num_samples = num_samples ), file=fh)


if __name__ == "__main__":
    import sys
    sys.exit("ERROR:  Invoke the tool as aeees.py instead.")
               
