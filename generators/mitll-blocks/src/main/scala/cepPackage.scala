//--------------------------------------------------------------------------------------
// Copyright 2024 Massachusetts Institute of Technology
// SPDX short identifier: BSD-3-Clause
//
// File         : cepPackages.scala
// Project      : Common Evaluation Platform (CEP)
// Description  : Defines various objects, values, types used within the CEP platform
//
//                Constants related to "Functional" register decode, which occurrs in 
//                the Chisel world, can be found in this package.
//                For each CEP core, there are the following two pairs of constants:
//                  - <core>_base_addr          - Functional registers base address
//                  - <core>_base_depth         - Functional registers address depth/size
//                  - <core>_llki_base_addr     - LLKI interface base address
//                  - <core>_llki_base_depth    - LLKI interface address depth/size
//
//                Additional address constants related to the functional registers can
//                be found in this file, within the relevant object (e.g., AESAddresses)
//
//                LLKI related address constants can be found in llki_pkg.sv as all LLKI
//                functionality exists in the SystemVerilog world.
//
//--------------------------------------------------------------------------------------
package mitllBlocks.cepPackage

import chisel3._
import chisel3.util._
import freechips.rocketchip.tilelink.{TLBusWrapper}
import chisel3.experimental.{IntParam}

object CEPVersion {
  val CEP_MAJOR_VERSION             = 0x04
  val CEP_MINOR_VERSION             = 0x70
}

object CEPBaseAddresses {  
  val scratchpad_base_addr          = 0x64800000L
  val scratchpad_depth              = 0x0001FFFFL 

  val cep_cores_base_addr           = 0x70000000L
    val aes_base_addr               = 0x70000000L
    val aes_depth                   = 0x000000FFL
    val aes_llki_base_addr          = 0x70008000L
      val aes_llki_ctrlsts_addr     = 0x70008000L
      val aes_llki_sendrecv_addr    = 0x70008008L
    val aes_llki_depth              = 0x0000003fL
    
    val md5_base_addr               = 0x70010000L
    val md5_depth                   = 0x000000FFL
    val md5_llki_base_addr          = 0x70018000L
      val md5_llki_ctrlsts_addr     = 0x70018000L
      val md5_llki_sendrecv_addr    = 0x70018008L
    val md5_llki_depth              = 0x000000ffL

    val sha256_0_base_addr            = 0x70020000L
    val sha256_0_depth                = 0xFFL
    val sha256_0_llki_base_addr       = 0x70020800L
      val sha256_0_llki_ctrlsts_addr  = 0x70020800L
      val sha256_0_llki_sendrecv_addr = 0x70020808L
    val sha256_0_llki_depth           = 0xFFL

    val sha256_1_base_addr            = 0x70021000L
    val sha256_1_depth                = 0xFFL
    val sha256_1_llki_base_addr       = 0x70021800L
      val sha256_1_llki_ctrlsts_addr  = 0x70021800L
      val sha256_1_llki_sendrecv_addr = 0x70021808L
    val sha256_1_llki_depth           = 0xFFL

    val sha256_2_base_addr            = 0x70022000L
    val sha256_2_depth                = 0xFFL
    val sha256_2_llki_base_addr       = 0x70022800L
      val sha256_2_llki_ctrlsts_addr  = 0x70022800L
      val sha256_2_llki_sendrecv_addr = 0x70022808L
    val sha256_2_llki_depth           = 0xFFL

    val sha256_3_base_addr            = 0x70023000L
    val sha256_3_depth                = 0xFFL
    val sha256_3_llki_base_addr       = 0x70023800L
      val sha256_3_llki_ctrlsts_addr  = 0x70023800L
      val sha256_3_llki_sendrecv_addr = 0x70023808L
    val sha256_3_llki_depth           = 0xFFL

    val rsa_base_addr               = 0x70030000L
    val rsa_depth                   = 0x000000FFL
    val rsa_llki_base_addr          = 0x70038000L
      val rsa_llki_ctrlsts_addr     = 0x70038000L
      val rsa_llki_sendrecv_addr    = 0x70038008L
    val rsa_llki_depth              = 0x000000ffL

    val des3_base_addr              = 0x70040000L
    val des3_depth                  = 0x000000FFL
    val des3_llki_base_addr         = 0x70048000L
      val des3_llki_ctrlsts_addr    = 0x70048000L
      val des3_llki_sendrecv_addr   = 0x70048008L
    val des3_llki_depth             = 0x000000ffL

    val dft_base_addr               = 0x70050000L
    val dft_depth                   = 0x000000FFL
    val dft_llki_base_addr          = 0x70058000L
      val dft_llki_ctrlsts_addr     = 0x70058000L
      val dft_llki_sendrecv_addr    = 0x70058008L
    val dft_llki_depth              = 0x000000ffL

    val idft_base_addr              = 0x70060000L
    val idft_depth                  = 0x000000FFL
    val idft_llki_base_addr         = 0x70068000L
      val idft_llki_ctrlsts_addr    = 0x70068000L
      val idft_llki_sendrecv_addr   = 0x70068008L
    val idft_llki_depth             = 0x000000ffL

    val fir_base_addr               = 0x70070000L
    val fir_depth                   = 0x000000FFL
    val fir_llki_base_addr          = 0x70078000L
      val fir_llki_ctrlsts_addr     = 0x70078000L
      val fir_llki_sendrecv_addr    = 0x70078008L
    val fir_llki_depth              = 0x000000ffL

    val iir_base_addr               = 0x70080000L
    val iir_depth                   = 0x000000FFL
    val iir_llki_base_addr          = 0x70088000L
      val iir_llki_ctrlsts_addr     = 0x70088000L
      val iir_llki_sendrecv_addr    = 0x70088008L
    val iir_llki_depth              = 0x000000ffL

    val gps_0_base_addr             = 0x70090000L
    val gps_0_depth                 = 0xFFL
    val gps_0_llki_base_addr        = 0x70090800L
      val gps_0_llki_ctrlsts_addr   = 0x70090800L
      val gps_0_llki_sendrecv_addr  = 0x70090808L
    val gps_0_llki_depth            = 0xFFL

    val gps_1_base_addr             = 0x70091000L
    val gps_1_depth                 = 0xFFL
    val gps_1_llki_base_addr        = 0x70091800L
      val gps_1_llki_ctrlsts_addr   = 0x70091800L
      val gps_1_llki_sendrecv_addr  = 0x70091808L
    val gps_1_llki_depth            = 0xFFL

    val gps_2_base_addr             = 0x70092000L
    val gps_2_depth                 = 0xFFL
    val gps_2_llki_base_addr        = 0x70092800L
      val gps_2_llki_ctrlsts_addr   = 0x70092800L
      val gps_2_llki_sendrecv_addr  = 0x70092808L
    val gps_2_llki_depth            = 0xFFL

    val gps_3_base_addr             = 0x70093000L
    val gps_3_depth                 = 0xFFL
    val gps_3_llki_base_addr        = 0x70093800L
      val gps_3_llki_ctrlsts_addr   = 0x70093800L
      val gps_3_llki_sendrecv_addr  = 0x70093808L
    val gps_3_llki_depth            = 0xFFL


  val cep_cores_depth               = 0x000FFFFFL
  
  val cepregs_base_addr             = 0x700F0000L
  val cepregs_base_depth            = 0x0000FFFFL

  val srot_base_addr                = 0x70200000L
  val srot_base_depth               = 0x0000ffffL
}

object AESAddresses {
  val aes_ctrlstatus_addr           = 0x0000
  val aes_pt0_addr                  = 0x0008
  val aes_pt1_addr                  = 0x0010
  val aes_ct0_addr                  = 0x0018
  val aes_ct1_addr                  = 0x0020
  val aes_key0_addr                 = 0x0028
  val aes_key1_addr                 = 0x0030
  val aes_key2_addr                 = 0x0038
}

object DES3Addresses {
    val des3_ctrlstatus_addr        = 0x0000
    val des3_decrypt_addr           = 0x0008
    val des3_desIn_addr             = 0x0010  
    val des3_key1_addr              = 0x0018
    val des3_key2_addr              = 0x0020
    val des3_key3_addr              = 0x0028
    val des3_done                   = 0x0030
    val des3_desOut_addr            = 0x0038
}

object MD5Addresses {
    val md5_ready                   = 0x0000
    val md5_msg_padded_w0           = 0x0008
    val md5_msg_padded_w1           = 0x0010
    val md5_msg_padded_w2           = 0x0018
    val md5_msg_padded_w3           = 0x0020
    val md5_msg_padded_w4           = 0x0028
    val md5_msg_padded_w5           = 0x0030
    val md5_msg_padded_w6           = 0x0038
    val md5_msg_padded_w7           = 0x0040 
    val md5_msg_output_w0           = 0x0048 
    val md5_msg_output_w1           = 0x0050
    val md5_rst                     = 0x0058
    val md5_in_valid                = 0x0060
    val md5_out_valid               = 0x0068
}

object SHA256Addresses{
    val sha256_ctrlstatus_addr      = 0x0000
    val sha256_block_w0             = 0x0008
    val sha256_block_w1             = 0x0010
    val sha256_block_w2             = 0x0018
    val sha256_block_w3             = 0x0020
    val sha256_block_w4             = 0x0028
    val sha256_block_w5             = 0x0030
    val sha256_block_w6             = 0x0038
    val sha256_block_w7             = 0x0040
    val sha256_done                 = 0x0048
    val sha256_digest_w0            = 0x0050
    val sha256_digest_w1            = 0x0058
    val sha256_digest_w2            = 0x0060
    val sha256_digest_w3            = 0x0068
}

object RSAAddresses{
    val rsa_ctrlstatus_addr         = 0x0000
    val rsa_exp_ptr_rst_addr        = 0x0008
    val rsa_exp_data_addr           = 0x0010
    val rsa_exp_ctrl_addr           = 0x0018
    val rsa_mod_ptr_rst_addr        = 0x0020
    val rsa_mod_data                = 0x0028
    val rsa_mod_ctrl_addr           = 0x0030
    val rsa_message_ptr_rst         = 0x0038
    val rsa_message_data            = 0x0040
    val rsa_message_ctrl_addr       = 0x0048
    val rsa_mod_length              = 0x0050
    val rsa_exp_length              = 0x0058
    val rsa_result_ptr_rst          = 0x0060
    val rsa_result_data_addr        = 0x0068
    val rsa_result_ctrl_addr        = 0x0070
    val rsa_cycles_addr             = 0x0078
}

object GPSAddresses{
    val gps_ctrlstatus_addr         = 0x0000
    val gps_ca_code_addr            = 0x0008
    val gps_p_code_addr_w0          = 0x0010
    val gps_p_code_addr_w1          = 0x0018
    val gps_l_code_addr_w0          = 0x0020
    val gps_l_code_addr_w1          = 0x0028    
    val gps_sv_num_addr             = 0x0030
    val gps_reset_addr              = 0x0038
    val gps_aes_key_addr_w0         = 0x0040
    val gps_aes_key_addr_w1         = 0x0048
    val gps_aes_key_addr_w2         = 0x0050
    val gps_pcode_speed_addr        = 0x0058
    val gps_pcode_xini_addr         = 0x0060
}

object DFTAddresses{
    val dft_ctrlstatus_addr         = 0x0000
    val dft_datain_addr_addr        = 0x0008
    val dft_datain_data_addr        = 0x0010
    val dft_dataout_addr_addr       = 0x0018
    val dft_dataout_data_addr       = 0x0020

}

object IDFTAddresses{
    val idft_ctrlstatus_addr        = 0x0000
    val idft_datain_addr_addr       = 0x0008
    val idft_datain_data_addr       = 0x0010
    val idft_dataout_addr_addr      = 0x0018
    val idft_dataout_data_addr      = 0x0020
}

object IIRAddresses{
    val iir_ctrlstatus_addr         = 0x0000
    val iir_datain_addr_addr        = 0x0008
    val iir_datain_data_addr        = 0x0010
    val iir_dataout_addr_addr       = 0x0018
    val iir_dataout_data_addr       = 0x0020
    val iir_reset_addr              = 0x0028
    val iir_shift_addr              = 0x0030
    val iir_shift_addr2             = 0x0038
}

object FIRAddresses {
  val fir_ctrlstatus_addr           = 0x0000
  val fir_datain_addr_addr          = 0x0008
  val fir_datain_data_addr          = 0x0010
  val fir_dataout_addr_addr         = 0x0018
  val fir_dataout_data_addr         = 0x0020
  val fir_reset_addr                = 0x0028    
}

object CEPRegisterAddresses {
  val version_register              = 0x0000
  val testNset                      = 0xFD10        
  val scratch_w0                    = 0xFE00
  val scratch_w1                    = 0xFE08
  val scratch_w2                    = 0xFE10
  val scratch_w3                    = 0xFE18
  val scratch_w4                    = 0xFE20
  val scratch_w5                    = 0xFE28
  val scratch_w6                    = 0xFE30
  val scratch_w7                    = 0xFE38
  val core0_status                  = 0xFF00
  val core1_status                  = 0xFF08
  val core2_status                  = 0xFF10
  val core3_status                  = 0xFF18
}

// These are intended to be the universal TL parameters
// for all the LLKI-enabled cores (including the SRoT).
// They need to match those values called out in top_pkg.sv
// Exceptions (when needed) are explictly coded into
// the specific TLModuleImp
object LLKITilelinkParameters {
    val BeatBytes                   = 8     // Should be = TL_DW / 8
    val AddressBits                 = 32    // Should be = TL_DW
    val SourceBits                  = 4     // Should be = TL_AIW
    val SinkBits                    = 2     // Should be = TL_DIW
    val SizeBits                    = 2     // Should be = TL_SZW
}

// The following class is used to pass paramaters down into the CEP cores
case class COREParams(
  slave_base_addr     : BigInt,
  slave_depth         : BigInt,
  dev_name            : String,					        // Used for Device Tree and module chisel-generated module name
  llki_base_addr      : BigInt = 0,
  llki_depth          : BigInt = 0,
  llki_ctrlsts_addr   : BigInt = 0,
  llki_sendrecv_addr  : BigInt = 0
)

// The following parameter pass attachment info to the lower level objects/classes/etc.
// All cores require at least a slave bus connection
case class COREAttachParams(
  slave_bus           : TLBusWrapper,
  llki_bus            : Option[TLBusWrapper] = None,
  master_bus          : Option[TLBusWrapper] = None
)


// The following class is used to pass paramaters down into the SROT
case class SROTParams(
  slave_base_addr     : BigInt,
  slave_depth         : BigInt,
  dev_name            : String,
  cep_cores_base_addr : BigInt,
  cep_cores_depth     : BigInt,
  llki_cores_array    : Array[BigInt]
)

// Define the LLKI Protocol Processing blackbox and its associated IO
class llki_pp_wrapper(  llki_ctrlsts_addr     : BigInt, 
                        llki_sendrecv_addr    : BigInt,
                        slave_tl_szw          : Int,
                        slave_tl_aiw          : Int,
                        slave_tl_aw           : Int,
                        slave_tl_dbw          : Int,
                        slave_tl_dw           : Int,
                        slave_tl_diw          : Int) extends BlackBox (

    Map(
      "CTRLSTS_ADDR"    -> IntParam(llki_ctrlsts_addr),   // Address of the LLKI PP Control/Status Register
      "SENDRECV_ADDR"   -> IntParam(llki_sendrecv_addr),  // Address of the LLKI PP Message Send/Receive interface
      "SLAVE_TL_SZW"    -> IntParam(slave_tl_szw),
      "SLAVE_TL_AIW"    -> IntParam(slave_tl_aiw),
      "SLAVE_TL_AW"     -> IntParam(slave_tl_aw),
      "SLAVE_TL_DBW"    -> IntParam(slave_tl_dbw),
      "SLAVE_TL_DW"     -> IntParam(slave_tl_dw),
      "SLAVE_TL_DIW"    -> IntParam(slave_tl_diw)
    )
) {

  val io = IO(new Bundle {

    // Clock and Reset
    val clk                 = Input(Clock())
    val rst                 = Input(Reset())

    // Slave - Tilelink A Channel (Signal order/names from Tilelink Specification v1.8.0)
    val slave_a_opcode      = Input(UInt(3.W))
    val slave_a_param       = Input(UInt(3.W))
    val slave_a_size        = Input(UInt(slave_tl_szw.W))
    val slave_a_source      = Input(UInt(slave_tl_aiw.W))
    val slave_a_address     = Input(UInt(slave_tl_aw.W))
    val slave_a_mask        = Input(UInt(slave_tl_dbw.W))
    val slave_a_data        = Input(UInt(slave_tl_dw.W))
    val slave_a_corrupt     = Input(Bool())
    val slave_a_valid       = Input(Bool())
    val slave_a_ready       = Output(Bool())

    // Slave - Tilelink D Channel (Signal order/names from Tilelink Specification v1.8.0)
    val slave_d_opcode      = Output(UInt(3.W))
    val slave_d_param       = Output(UInt(3.W))
    val slave_d_size        = Output(UInt(slave_tl_szw.W))
    val slave_d_source      = Output(UInt(slave_tl_aiw.W))
    val slave_d_sink        = Output(UInt(slave_tl_diw.W))
    val slave_d_denied      = Output(Bool())
    val slave_d_data        = Output(UInt(slave_tl_dw.W))
    val slave_d_corrupt     = Output(Bool())
    val slave_d_valid       = Output(Bool())
    val slave_d_ready       = Input(Bool())

    // LLKI discrete interface
    val llkid_key_data      = Output(UInt(64.W))
    val llkid_key_valid     = Output(Bool())
    val llkid_key_ready     = Input(Bool())
    val llkid_key_complete  = Input(Bool())
    val llkid_clear_key     = Output(Bool())
    val llkid_clear_key_ack = Input(Bool())

  })
} // end class llki_pp_wrapper

// Define blackbox and its associated IO (with LLKI)
class aes_192_mock_tss() extends BlackBox with HasBlackBoxResource {

  val io = IO(new Bundle {
    // Clock and Reset
    val clk                 = Input(Clock())
    val rst                 = Input(Reset())

    // Inputs
    val start               = Input(Bool())
    val state               = Input(UInt(128.W))
    val key                 = Input(UInt(192.W))

    // Outputs
    val out                 = Output(UInt(128.W))
    val out_valid           = Output(Bool())

    // LLKI discrete interface
    val llkid_key_data      = Input(UInt(64.W))
    val llkid_key_valid     = Input(Bool())
    val llkid_key_ready     = Output(Bool())
    val llkid_key_complete  = Output(Bool())
    val llkid_clear_key     = Input(Bool())
    val llkid_clear_key_ack = Output(Bool())
  })

  // Add the SystemVerilog/Verilog files associated with the BlackBox
  // Relative to ./src/main/resources
  addResource("/vsrc/aes/aes_192_mock_tss.sv")
  addResource("/vsrc/aes/aes_192.v")
  addResource("/vsrc/aes/round.v")
  addResource("/vsrc/aes/table.v")

} // aes_192_mock_tss

// Define blackbox and its associated IO (without LLKI)
class aes_192() extends BlackBox with HasBlackBoxResource {

  val io = IO(new Bundle {
    // Clock and Reset
    val clk                 = Input(Clock())
    val rst                 = Input(Reset())

    // Inputs
    val start               = Input(Bool())
    val state               = Input(UInt(128.W))
    val key                 = Input(UInt(192.W))

    // Outputs
    val out                 = Output(UInt(128.W))
    val out_valid           = Output(Bool())
  })

  // Add the SystemVerilog/Verilog files associated with the BlackBox
  // Relative to ./src/main/resources
  addResource("/vsrc/aes/aes_192.v")
  addResource("/vsrc/aes/round.v")
  addResource("/vsrc/aes/table.v")

} // aes_192

  // Define scratchpad_wrapper blackbox and its associated IO
  class scratchpad_wrapper(   address           : BigInt, 
                              depth             : BigInt,
                              slave_tl_szw      : Int,
                              slave_tl_aiw      : Int,
                              slave_tl_aw       : Int,
                              slave_tl_dbw      : Int,
                              slave_tl_dw       : Int,
                              slave_tl_diw      : Int) extends BlackBox (
      Map(
        "ADDRESS"                       -> IntParam(address),       // Base address of the TL slave
        "DEPTH"                         -> IntParam(depth),         // Address depth of the TL slave
        "SLAVE_TL_SZW"                  -> IntParam(slave_tl_szw),
        "SLAVE_TL_AIW"                  -> IntParam(slave_tl_aiw),
        "SLAVE_TL_AW"                   -> IntParam(slave_tl_aw),
        "SLAVE_TL_DBW"                  -> IntParam(slave_tl_dbw),
        "SLAVE_TL_DW"                   -> IntParam(slave_tl_dw),
        "SLAVE_TL_DIW"                  -> IntParam(slave_tl_diw)
      )
  ) with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val clk               = Input(Clock())
      val rst               = Input(Reset())

      // Slave - Tilelink A Channel (Signal order/names from Tilelink Specification v1.8.0)
      val slave_a_opcode    = Input(UInt(3.W))
      val slave_a_param     = Input(UInt(3.W))
      val slave_a_size      = Input(UInt(slave_tl_szw.W))
      val slave_a_source    = Input(UInt(slave_tl_aiw.W))
      val slave_a_address   = Input(UInt(slave_tl_aw.W))
      val slave_a_mask      = Input(UInt(slave_tl_dbw.W))
      val slave_a_data      = Input(UInt(slave_tl_dw.W))
      val slave_a_corrupt   = Input(Bool())
      val slave_a_valid     = Input(Bool())
      val slave_a_ready     = Output(Bool())

      // Slave - Tilelink D Channel (Signal order/names from Tilelink Specification v1.8.0)
      val slave_d_opcode    = Output(UInt(3.W))
      val slave_d_param     = Output(UInt(3.W))
      val slave_d_size      = Output(UInt(slave_tl_szw.W))
      val slave_d_source    = Output(UInt(slave_tl_aiw.W))
      val slave_d_sink      = Output(UInt(slave_tl_diw.W))
      val slave_d_denied    = Output(Bool())
      val slave_d_data      = Output(UInt(slave_tl_dw.W))
      val slave_d_corrupt   = Output(Bool())
      val slave_d_valid     = Output(Bool())
      val slave_d_ready     = Input(Bool())

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/llki/scratchpad_wrapper.sv")

  } // end class scratchpad_wrapper

  // Define srot_wrapper blackbox and its associated IO.   Parameters are being
  // used to pass vector sizes (vs constants in a package) to increase flexibility
  // when some vectors might change depending on where the SRoT is instantiated
  class srot_wrapper(   slave_tl_szw              : Int,
                        slave_tl_aiw              : Int,
                        slave_tl_aw               : Int,
                        slave_tl_dbw              : Int,
                        slave_tl_dw               : Int,
                        slave_tl_diw              : Int,
                        master_tl_szw             : Int,
                        master_tl_aiw             : Int,
                        master_tl_aw              : Int,
                        master_tl_dbw             : Int,
                        master_tl_dw              : Int,
                        master_tl_diw             : Int,
                        num_cores                 : BigInt, 
                        core_index_array_packed   : BigInt) extends BlackBox (
      Map(
        "SLAVE_TL_SZW"                  -> IntParam(slave_tl_szw),
        "SLAVE_TL_AIW"                  -> IntParam(slave_tl_aiw),
        "SLAVE_TL_AW"                   -> IntParam(slave_tl_aw),
        "SLAVE_TL_DBW"                  -> IntParam(slave_tl_dbw),
        "SLAVE_TL_DW"                   -> IntParam(slave_tl_dw),
        "SLAVE_TL_DIW"                  -> IntParam(slave_tl_diw),
        "MASTER_TL_SZW"                 -> IntParam(master_tl_szw),
        "MASTER_TL_AIW"                 -> IntParam(master_tl_aiw),
        "MASTER_TL_AW"                  -> IntParam(master_tl_aw),
        "MASTER_TL_DBW"                 -> IntParam(master_tl_dbw),
        "MASTER_TL_DW"                  -> IntParam(master_tl_dw),
        "MASTER_TL_DIW"                 -> IntParam(master_tl_diw),
        // number of LLKI cores
        "LLKI_NUM_CORES"                -> IntParam(num_cores),
        // Array of LLKI base addresses, packed into single bitstream 
        // Each address is 32bit
        // MSB => address 0
        "LLKI_CORE_INDEX_ARRAY_PACKED"  -> IntParam(core_index_array_packed) 
      )
  ) with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val clk               = Input(Clock())
      val rst               = Input(Bool())

      // Slave - Tilelink A Channel (Signal order/names from Tilelink Specification v1.8.0)
      val slave_a_opcode    = Input(UInt(3.W))
      val slave_a_param     = Input(UInt(3.W))
      val slave_a_size      = Input(UInt(slave_tl_szw.W))
      val slave_a_source    = Input(UInt(slave_tl_aiw.W))
      val slave_a_address   = Input(UInt(slave_tl_aw.W))
      val slave_a_mask      = Input(UInt(slave_tl_dbw.W))
      val slave_a_data      = Input(UInt(slave_tl_dw.W))
      val slave_a_corrupt   = Input(Bool())
      val slave_a_valid     = Input(Bool())
      val slave_a_ready     = Output(Bool())

      // Slave - Tilelink D Channel (Signal order/names from Tilelink Specification v1.8.0)
      val slave_d_opcode    = Output(UInt(3.W))
      val slave_d_param     = Output(UInt(3.W))
      val slave_d_size      = Output(UInt(slave_tl_szw.W))
      val slave_d_source    = Output(UInt(slave_tl_aiw.W))
      val slave_d_sink      = Output(UInt(slave_tl_diw.W))
      val slave_d_denied    = Output(Bool())
      val slave_d_data      = Output(UInt(slave_tl_dw.W))
      val slave_d_corrupt   = Output(Bool())
      val slave_d_valid     = Output(Bool())
      val slave_d_ready     = Input(Bool())

      // Master - Tilelink A Channel (Signal order/names from Tilelink Specification v1.8.0)
      val master_a_opcode   = Output(UInt(3.W))
      val master_a_param    = Output(UInt(3.W))
      val master_a_size     = Output(UInt(master_tl_szw.W))
      val master_a_source   = Output(UInt(master_tl_aiw.W))
      val master_a_address  = Output(UInt(master_tl_aw.W))
      val master_a_mask     = Output(UInt(master_tl_dbw.W))
      val master_a_data     = Output(UInt(master_tl_dw.W))
      val master_a_corrupt  = Output(Bool())
      val master_a_valid    = Output(Bool())
      val master_a_ready    = Input(Bool())

      // Master - Tilelink D Channel (Signal order/names from Tilelink Specification v1.8.0)
      val master_d_opcode   = Input(UInt(3.W))
      val master_d_param    = Input(UInt(3.W))
      val master_d_size     = Input(UInt(master_tl_szw.W))
      val master_d_source   = Input(UInt(master_tl_aiw.W))
      val master_d_sink     = Input(UInt(master_tl_diw.W))
      val master_d_denied   = Input(Bool())
      val master_d_data     = Input(UInt(master_tl_dw.W))
      val master_d_corrupt  = Input(Bool())
      val master_d_valid    = Input(Bool())
      val master_d_ready    = Output(Bool())

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/llki/srot_wrapper.sv")

  } // end class srot_wrapper


  // Define blackbox and its associated IO (with LLKI)
  class des3_mock_tss() extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock
      val clk                 = Input(Clock())
      val rst                 = Input(Reset())

      // Inputs
      val start               = Input(Bool())
      val decrypt             = Input(Bool())
      val key1                = Input(UInt(56.W))
      val key2                = Input(UInt(56.W))
      val key3                = Input(UInt(56.W))
      val desIn               = Input(UInt(64.W))

      // Outputs
      val desOut              = Output(UInt(64.W))
      val out_valid           = Output(Bool())

      // LLKI discrete interface
      val llkid_key_data      = Input(UInt(64.W))
      val llkid_key_valid     = Input(Bool())
      val llkid_key_ready     = Output(Bool())
      val llkid_key_complete  = Output(Bool())
      val llkid_clear_key     = Input(Bool())
      val llkid_clear_key_ack = Output(Bool())

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/des3/des3_mock_tss.sv")
    addResource("/vsrc/des3/des3.v")
    addResource("/vsrc/des3/key_sel3.v")
    addResource("/vsrc/des3/crp.v")
    addResource("/vsrc/des3/sbox1.v")
    addResource("/vsrc/des3/sbox2.v")
    addResource("/vsrc/des3/sbox3.v")
    addResource("/vsrc/des3/sbox4.v")
    addResource("/vsrc/des3/sbox5.v")
    addResource("/vsrc/des3/sbox6.v")
    addResource("/vsrc/des3/sbox7.v")
    addResource("/vsrc/des3/sbox8.v")

  } // end des3_mock_tss

  // Define blackbox and its associated IO (without LLKI)
  class des3() extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock
      val clk                 = Input(Clock())
      val rst                 = Input(Reset())

      // Inputs
      val start               = Input(Bool())
      val decrypt             = Input(Bool())
      val key1                = Input(UInt(56.W))
      val key2                = Input(UInt(56.W))
      val key3                = Input(UInt(56.W))
      val desIn               = Input(UInt(64.W))

      // Outputs
      val desOut              = Output(UInt(64.W))
      val out_valid           = Output(Bool())

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/des3/des3.v")
    addResource("/vsrc/des3/key_sel3.v")
    addResource("/vsrc/des3/crp.v")
    addResource("/vsrc/des3/sbox1.v")
    addResource("/vsrc/des3/sbox2.v")
    addResource("/vsrc/des3/sbox3.v")
    addResource("/vsrc/des3/sbox4.v")
    addResource("/vsrc/des3/sbox5.v")
    addResource("/vsrc/des3/sbox6.v")
    addResource("/vsrc/des3/sbox7.v")
    addResource("/vsrc/des3/sbox8.v")

  } // end des3

  // Define blackbox and its associated IO (with LLKI)
  class dft_top_mock_tss () extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val clk                 = Input(Clock())
      val rst                 = Input(Reset())
   
      // Inputs
      val next                = Input(Bool())            
      val X0                  = Input(UInt(16.W))
      val X1                  = Input(UInt(16.W))
      val X2                  = Input(UInt(16.W))
      val X3                  = Input(UInt(16.W))
    
      // Outputs
      val next_out            = Output(Bool())
      val Y0                  = Output(UInt(16.W))
      val Y1                  = Output(UInt(16.W))
      val Y2                  = Output(UInt(16.W))
      val Y3                  = Output(UInt(16.W))

      // LLKI discrete interface
      val llkid_key_data      = Input(UInt(64.W))
      val llkid_key_valid     = Input(Bool())
      val llkid_key_ready     = Output(Bool())
      val llkid_key_complete  = Output(Bool())
      val llkid_clear_key     = Input(Bool())
      val llkid_clear_key_ack = Output(Bool())

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/dsp/dft_top_mock_tss.sv")
    addResource("/vsrc/dsp/dft_top.v")

  } // end dft_top_mock_tss

  // Define blackbox and its associated IO (without LLKI)
  class dft_top () extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val clk                 = Input(Clock())
      val rst                 = Input(Reset())
   
      // Inputs
      val next                = Input(Bool())            
      val X0                  = Input(UInt(16.W))
      val X1                  = Input(UInt(16.W))
      val X2                  = Input(UInt(16.W))
      val X3                  = Input(UInt(16.W))
    
      // Outputs
      val next_out            = Output(Bool())
      val Y0                  = Output(UInt(16.W))
      val Y1                  = Output(UInt(16.W))
      val Y2                  = Output(UInt(16.W))
      val Y3                  = Output(UInt(16.W))

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/dsp/dft_top.v")

  } // end dft_top

  // Define blackbox and its associated IO (with LLKI)
  class FIR_filter_mock_tss () extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val clk                 = Input(Clock())
      val rst                 = Input(Reset())
      val rst_dut             = Input(Reset())
   
      // Inputs
      val inData              = Input(UInt(32.W))
    
      // Outputs
      val outData             = Output(UInt(32.W))

      // LLKI discrete interface
      val llkid_key_data      = Input(UInt(64.W))
      val llkid_key_valid     = Input(Bool())
      val llkid_key_ready     = Output(Bool())
      val llkid_key_complete  = Output(Bool())
      val llkid_clear_key     = Input(Bool())
      val llkid_clear_key_ack = Output(Bool())

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/dsp/FIR_filter_mock_tss.sv")
    addResource("/vsrc/dsp/FIR_filter.v")

  } // end FIR_filter_mock_tss

  // Define blackbox and its associated IO (without LLKI)
  class FIR_filter () extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val clk                 = Input(Clock())
      val rst                 = Input(Reset())
      val rst_dut             = Input(Reset())
   
      // Inputs
      val inData              = Input(UInt(32.W))
    
      // Outputs
      val outData             = Output(UInt(32.W))

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/dsp/FIR_filter.v")

  } // end FIR_filter

  // Define blackbox and its associated IO
  class gps_mock_tss () extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val sys_clk             = Input(Clock())
      val sync_rst_in         = Input(Reset())
      val sync_rst_in_dut     = Input(Reset())

      // Inputs
      val startRound          = Input(Bool())
      val sv_num              = Input(UInt(6.W))
      val aes_key             = Input(UInt(192.W))
      val pcode_speeds        = Input(UInt(31.W))
      val pcode_initializers  = Input(UInt(48.W))
      
      // Outputs
      val ca_code             = Output(UInt(13.W))
      val p_code              = Output(UInt(128.W))
      val l_code              = Output(UInt(128.W))
      val l_code_valid        = Output(Bool())

      // LLKI discrete interface
      val llkid_key_data      = Input(UInt(64.W))
      val llkid_key_valid     = Input(Bool())
      val llkid_key_ready     = Output(Bool())
      val llkid_key_complete  = Output(Bool())
      val llkid_clear_key     = Input(Bool())
      val llkid_clear_key_ack = Output(Bool())

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/gps/gps_mock_tss.sv")
    addResource("/vsrc/gps/gps.v")
    addResource("/vsrc/gps/cacode.v")
    addResource("/vsrc/gps/pcode.v")

  } // end gps_mock_tss
 
  // Define blackbox and its associated IO
  class gps () extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val sys_clk             = Input(Clock())
      val sync_rst_in         = Input(Reset())
      val sync_rst_in_dut     = Input(Reset())

      // Inputs
      val startRound          = Input(Bool())
      val sv_num              = Input(UInt(6.W))
      val aes_key             = Input(UInt(192.W))
      val pcode_speeds        = Input(UInt(31.W))
      val pcode_initializers  = Input(UInt(48.W))
      
      // Outputs
      val ca_code             = Output(UInt(13.W))
      val p_code              = Output(UInt(128.W))
      val l_code              = Output(UInt(128.W))
      val l_code_valid        = Output(Bool())

      // LLKI discrete interface
      val llkid_key_data      = Input(UInt(64.W))
      val llkid_key_valid     = Input(Bool())
      val llkid_key_ready     = Output(Bool())
      val llkid_key_complete  = Output(Bool())
      val llkid_clear_key     = Input(Bool())
      val llkid_clear_key_ack = Output(Bool())

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/gps/gps.v")
    addResource("/vsrc/gps/cacode.v")
    addResource("/vsrc/gps/pcode.v")

  } // end gps

    // Define blackbox and its associated IO (with LLKI)
  class idft_top_mock_tss () extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val clk                 = Input(Clock())
      val rst                 = Input(Reset())
   
      // Inputs
      val next                = Input(Bool())            
      val X0                  = Input(UInt(16.W))
      val X1                  = Input(UInt(16.W))
      val X2                  = Input(UInt(16.W))
      val X3                  = Input(UInt(16.W))
    
      // Outputs
      val next_out            = Output(Bool())
      val Y0                  = Output(UInt(16.W))
      val Y1                  = Output(UInt(16.W))
      val Y2                  = Output(UInt(16.W))
      val Y3                  = Output(UInt(16.W))

      // LLKI discrete interface
      val llkid_key_data      = Input(UInt(64.W))
      val llkid_key_valid     = Input(Bool())
      val llkid_key_ready     = Output(Bool())
      val llkid_key_complete  = Output(Bool())
      val llkid_clear_key     = Input(Bool())
      val llkid_clear_key_ack = Output(Bool())

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/dsp/idft_top_mock_tss.sv")
    addResource("/vsrc/dsp/idft_top.v")

  } // end idft_top_mock_tss

  // Define blackbox and its associated IO (without LLKI)
  class idft_top () extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val clk                 = Input(Clock())
      val rst                 = Input(Reset())
   
      // Inputs
      val next                = Input(Bool())            
      val X0                  = Input(UInt(16.W))
      val X1                  = Input(UInt(16.W))
      val X2                  = Input(UInt(16.W))
      val X3                  = Input(UInt(16.W))
    
      // Outputs
      val next_out            = Output(Bool())
      val Y0                  = Output(UInt(16.W))
      val Y1                  = Output(UInt(16.W))
      val Y2                  = Output(UInt(16.W))
      val Y3                  = Output(UInt(16.W))

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/dsp/idft_top.v")

  } // end idft_top

 // Define blackbox and its associated IO
  class IIR_filter_mock_tss () extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val clk                 = Input(Clock())
      val rst                 = Input(Reset())
      val rst_dut             = Input(Reset())
   
      // Inputs
      val inData              = Input(UInt(32.W))
    
      // Outputs
      val outData             = Output(UInt(32.W))

      // LLKI discrete interface
      val llkid_key_data      = Input(UInt(64.W))
      val llkid_key_valid     = Input(Bool())
      val llkid_key_ready     = Output(Bool())
      val llkid_key_complete  = Output(Bool())
      val llkid_clear_key     = Input(Bool())
      val llkid_clear_key_ack = Output(Bool())

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/dsp/IIR_filter_mock_tss.sv")
    addResource("/vsrc/dsp/IIR_filter.v")

  } // end IIR_filter_mock_tss

  // Define blackbox and its associated IO
  class IIR_filter () extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val clk                 = Input(Clock())
      val rst                 = Input(Reset())
      val rst_dut             = Input(Reset())
   
      // Inputs
      val inData              = Input(UInt(32.W))
    
      // Outputs
      val outData             = Output(UInt(32.W))

      // LLKI discrete interface
      val llkid_key_data      = Input(UInt(64.W))
      val llkid_key_valid     = Input(Bool())
      val llkid_key_ready     = Output(Bool())
      val llkid_key_complete  = Output(Bool())
      val llkid_clear_key     = Input(Bool())
      val llkid_clear_key_ack = Output(Bool())

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/dsp/IIR_filter.v")

  } // end IIR_filter

  // Define blackbox and its associated IO
  class md5_mock_tss() extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val clk                 = Input(Clock())
      val rst                 = Input(Reset())

      // Inputs
      val init                = Input(Bool())
      val msg_in_valid        = Input(Bool())
      val msg_padded          = Input(UInt(512.W))

      // Outputs
      val msg_output          = Output(UInt(128.W))
      val msg_out_valid       = Output(Bool())
      val ready               = Output(Bool())

      // LLKI discrete interface
      val llkid_key_data      = Input(UInt(64.W))
      val llkid_key_valid     = Input(Bool())
      val llkid_key_ready     = Output(Bool())
      val llkid_key_complete  = Output(Bool())
      val llkid_clear_key     = Input(Bool())
      val llkid_clear_key_ack = Output(Bool())

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/md5/md5_mock_tss.sv")
    addResource("/vsrc/md5/md5.v")
    addResource("/vsrc/md5/pancham.v")
    addResource("/vsrc/md5/pancham_round.v")

  } // end md5_mock_tss

  // Define blackbox and its associated IO
  class md5() extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val clk                 = Input(Clock())
      val rst                 = Input(Reset())

      // Inputs
      val init                = Input(Bool())
      val msg_in_valid        = Input(Bool())
      val msg_padded          = Input(UInt(512.W))

      // Outputs
      val msg_output          = Output(UInt(128.W))
      val msg_out_valid       = Output(Bool())
      val ready               = Output(Bool())

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/md5/md5.v")
    addResource("/vsrc/md5/pancham.v")
    addResource("/vsrc/md5/pancham_round.v")

  } // end md5

  // Define blackbox and its associated IO
  class modexp_core_mock_tss() extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val clk                           = Input(Clock())
      val rst                           = Input(Reset())

      // Core I/O
      val start                         = Input(Bool())
      val exponent_length               = Input(UInt(13.W))
      val modulus_length                = Input(UInt(8.W))
      val ready                         = Output(Bool())
      val cycles                        = Output(UInt(64.W))
      val exponent_mem_api_cs           = Input(Bool())
      val exponent_mem_api_wr           = Input(Bool())
      val exponent_mem_api_rst          = Input(Bool())
      val exponent_mem_api_write_data   = Input(UInt(32.W))
      val exponent_mem_api_read_data    = Output(UInt(32.W))
      val modulus_mem_api_cs            = Input(Bool())
      val modulus_mem_api_wr            = Input(Bool())
      val modulus_mem_api_rst           = Input(Bool())
      val modulus_mem_api_write_data    = Input(UInt(32.W))
      val modulus_mem_api_read_data     = Output(UInt(32.W))
      val message_mem_api_cs            = Input(Bool())
      val message_mem_api_wr            = Input(Bool())
      val message_mem_api_rst           = Input(Bool())
      val message_mem_api_write_data    = Input(UInt(32.W))
      val message_mem_api_read_data     = Output(UInt(32.W))
      val result_mem_api_cs             = Input(Bool())
      val result_mem_api_rst            = Input(Bool())
      val result_mem_api_read_data      = Output(UInt(32.W))

      // LLKI discrete interface
      val llkid_key_data                = Input(UInt(64.W))
      val llkid_key_valid               = Input(Bool())
      val llkid_key_ready               = Output(Bool())
      val llkid_key_complete            = Output(Bool())
      val llkid_clear_key               = Input(Bool())
      val llkid_clear_key_ack           = Output(Bool())

    })


    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/rsa/rtl/modexp_core_mock_tss.sv")
    addResource("/vsrc/rsa/rtl/modexp_core.v")
    addResource("/vsrc/rsa/rtl/montprod.v")
    addResource("/vsrc/rsa/rtl/residue.v")
    addResource("/vsrc/rsa/rtl/blockmem2r1w.v")
    addResource("/vsrc/rsa/rtl/blockmem2r1w.v")
    addResource("/vsrc/rsa/rtl/blockmem2r1wptr.v")
    addResource("/vsrc/rsa/rtl/blockmem2rptr1w.v")
    addResource("/vsrc/rsa/rtl/blockmem1r1w.v")
    addResource("/vsrc/rsa/rtl/shr.v")
    addResource("/vsrc/rsa/rtl/shl.v")
    addResource("/vsrc/rsa/rtl/adder.v")

  } // end modexp_core_mock_tss

  // Define blackbox and its associated IO
  class modexp_core() extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val clk                           = Input(Clock())
      val rst                           = Input(Reset())

      // Core I/O
      val start                         = Input(Bool())
      val exponent_length               = Input(UInt(13.W))
      val modulus_length                = Input(UInt(8.W))
      val ready                         = Output(Bool())
      val cycles                        = Output(UInt(64.W))
      val exponent_mem_api_cs           = Input(Bool())
      val exponent_mem_api_wr           = Input(Bool())
      val exponent_mem_api_rst          = Input(Bool())
      val exponent_mem_api_write_data   = Input(UInt(32.W))
      val exponent_mem_api_read_data    = Output(UInt(32.W))
      val modulus_mem_api_cs            = Input(Bool())
      val modulus_mem_api_wr            = Input(Bool())
      val modulus_mem_api_rst           = Input(Bool())
      val modulus_mem_api_write_data    = Input(UInt(32.W))
      val modulus_mem_api_read_data     = Output(UInt(32.W))
      val message_mem_api_cs            = Input(Bool())
      val message_mem_api_wr            = Input(Bool())
      val message_mem_api_rst           = Input(Bool())
      val message_mem_api_write_data    = Input(UInt(32.W))
      val message_mem_api_read_data     = Output(UInt(32.W))
      val result_mem_api_cs             = Input(Bool())
      val result_mem_api_rst            = Input(Bool())
      val result_mem_api_read_data      = Output(UInt(32.W))

    })


    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/rsa/rtl/modexp_core.v")
    addResource("/vsrc/rsa/rtl/montprod.v")
    addResource("/vsrc/rsa/rtl/residue.v")
    addResource("/vsrc/rsa/rtl/blockmem2r1w.v")
    addResource("/vsrc/rsa/rtl/blockmem2r1w.v")
    addResource("/vsrc/rsa/rtl/blockmem2r1wptr.v")
    addResource("/vsrc/rsa/rtl/blockmem2rptr1w.v")
    addResource("/vsrc/rsa/rtl/blockmem1r1w.v")
    addResource("/vsrc/rsa/rtl/shr.v")
    addResource("/vsrc/rsa/rtl/shl.v")
    addResource("/vsrc/rsa/rtl/adder.v")

  } // end modexp_core

  // Define blackbox and its associated IO
  class sha256_mock_tss() extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val clk                 = Input(Clock())
      val rst                 = Input(Reset())

      // Inputs
      val init                = Input(Bool())
      val next                = Input(Bool())
      val block               = Input(UInt(512.W))

      // Outputs
      val digest_valid        = Output(Bool())
      val digest              = Output(UInt(256.W))
      val ready               = Output(Bool())

      // LLKI discrete interface
      val llkid_key_data      = Input(UInt(64.W))
      val llkid_key_valid     = Input(Bool())
      val llkid_key_ready     = Output(Bool())
      val llkid_key_complete  = Output(Bool())
      val llkid_clear_key     = Input(Bool())
      val llkid_clear_key_ack = Output(Bool())

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/sha256/sha256_mock_tss.sv")
    addResource("/vsrc/sha256/sha256.v")
    addResource("/vsrc/sha256/sha256_k_constants.v")
    addResource("/vsrc/sha256/sha256_w_mem.v")

  } // end sha256_mock_tss

  // Define blackbox and its associated IO
  class sha256() extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val clk                 = Input(Clock())
      val rst                 = Input(Reset())

      // Inputs
      val init                = Input(Bool())
      val next                = Input(Bool())
      val block               = Input(UInt(512.W))

      // Outputs
      val digest_valid        = Output(Bool())
      val digest              = Output(UInt(256.W))
      val ready               = Output(Bool())

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/sha256/sha256.v")
    addResource("/vsrc/sha256/sha256_k_constants.v")
    addResource("/vsrc/sha256/sha256_w_mem.v")

  } // end sha256_mock_tss
