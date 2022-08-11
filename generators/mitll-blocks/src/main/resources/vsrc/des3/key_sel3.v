/////////////////////////////////////////////////////////////////////
////                                                             ////
////  KEY_SEL                                                    ////
////  Select one of 16 sub-keys for round                        ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Rudolf Usselmann                         ////
////                    rudi@asics.ws                            ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

module  key_sel3(clk, reset, K_sub, key1, key2, key3, roundSel, decrypt);
/* verilator lint_off LITENDIAN */
output [1:48] K_sub;
/* verilator lint_on LITENDIAN */
input [55:0] key1, key2, key3;
input [5:0] roundSel;
input  decrypt;
input clk;
input reset;

wire  decrypt_int;
reg [55:0] K;
reg [1:48] K_sub;
/* verilator lint_off LITENDIAN */
wire [1:48] K1, K2, K3, K4, K5, K6, K7, K8, K9;
wire [1:48] K10, K11, K12, K13, K14, K15, K16;
/* verilator lint_on LITENDIAN */

always @(clk)
    begin
        if (reset)
            K = 56'b0;
        else
    case ({decrypt, roundSel[5:4]})
        3'b0_00:
            K = key1;
        3'b0_01:
            K = key2;
        3'b0_10:
            K = key3;
        3'b1_00:
            K = key3;
        3'b1_01:
            K = key2;
        3'b1_10:
            K = key1;
        3'b0_11:
            K = 56'b0;
        3'b1_11:
            K = 56'b0;
    endcase
end

assign decrypt_int = (roundSel[5:4]==2'h1) ? !decrypt : decrypt;

always @(*)
    begin
            case(roundSel[3:0])
                0:
                    K_sub = K1;
                1:
                    K_sub = K2;
                2:
                    K_sub = K3;
                3:
                    K_sub = K4;
                4:
                    K_sub = K5;
                5:
                    K_sub = K6;
                6:
                    K_sub = K7;
                7:
                    K_sub = K8;
                8:
                    K_sub = K9;
                9:
                    K_sub = K10;
                10:
                    K_sub = K11;
                11:
                    K_sub = K12;
                12:
                    K_sub = K13;
                13:
                    K_sub = K14;
                14:
                    K_sub = K15;
                15:
                    K_sub = K16;
            endcase
    end


assign K16[1] = decrypt_int ? K[47] : K[40];
assign K16[2] = decrypt_int ? K[11] : K[4];
assign K16[3] = decrypt_int ? K[26] : K[19];
assign K16[4] = decrypt_int ? K[3] : K[53];
assign K16[5] = decrypt_int ? K[13] : K[6];
assign K16[6] = decrypt_int ? K[41] : K[34];
assign K16[7] = decrypt_int ? K[27] : K[20];
assign K16[8] = decrypt_int ? K[6] : K[24];
assign K16[9] = decrypt_int ? K[54] : K[47];
assign K16[10] = decrypt_int ? K[48] : K[41];
assign K16[11] = decrypt_int ? K[39] : K[32];
assign K16[12] = decrypt_int ? K[19] : K[12];
assign K16[13] = decrypt_int ? K[53] : K[46];
assign K16[14] = decrypt_int ? K[25] : K[18];
assign K16[15] = decrypt_int ? K[33] : K[26];
assign K16[16] = decrypt_int ? K[34] : K[27];
assign K16[17] = decrypt_int ? K[17] : K[10];
assign K16[18] = decrypt_int ? K[5] : K[55];
assign K16[19] = decrypt_int ? K[4] : K[54];
assign K16[20] = decrypt_int ? K[55] : K[48];
assign K16[21] = decrypt_int ? K[24] : K[17];
assign K16[22] = decrypt_int ? K[32] : K[25];
assign K16[23] = decrypt_int ? K[40] : K[33];
assign K16[24] = decrypt_int ? K[20] : K[13];
assign K16[25] = decrypt_int ? K[36] : K[29];
assign K16[26] = decrypt_int ? K[31] : K[51];
assign K16[27] = decrypt_int ? K[21] : K[14];
assign K16[28] = decrypt_int ? K[8] : K[1];
assign K16[29] = decrypt_int ? K[23] : K[16];
assign K16[30] = decrypt_int ? K[52] : K[45];
assign K16[31] = decrypt_int ? K[14] : K[7];
assign K16[32] = decrypt_int ? K[29] : K[22];
assign K16[33] = decrypt_int ? K[51] : K[44];
assign K16[34] = decrypt_int ? K[9] : K[2];
assign K16[35] = decrypt_int ? K[35] : K[28];
assign K16[36] = decrypt_int ? K[30] : K[23];
assign K16[37] = decrypt_int ? K[2] : K[50];
assign K16[38] = decrypt_int ? K[37] : K[30];
assign K16[39] = decrypt_int ? K[22] : K[15];
assign K16[40] = decrypt_int ? K[0] : K[52];
assign K16[41] = decrypt_int ? K[42] : K[35];
assign K16[42] = decrypt_int ? K[38] : K[31];
assign K16[43] = decrypt_int ? K[16] : K[9];
assign K16[44] = decrypt_int ? K[43] : K[36];
assign K16[45] = decrypt_int ? K[44] : K[37];
assign K16[46] = decrypt_int ? K[1] : K[49];
assign K16[47] = decrypt_int ? K[7] : K[0];
assign K16[48] = decrypt_int ? K[28] : K[21];

assign K15[1] = decrypt_int ? K[54] : K[33];
assign K15[2] = decrypt_int ? K[18] : K[54];
assign K15[3] = decrypt_int ? K[33] : K[12];
assign K15[4] = decrypt_int ? K[10] : K[46];
assign K15[5] = decrypt_int ? K[20] : K[24];
assign K15[6] = decrypt_int ? K[48] : K[27];
assign K15[7] = decrypt_int ? K[34] : K[13];
assign K15[8] = decrypt_int ? K[13] : K[17];
assign K15[9] = decrypt_int ? K[4] : K[40];
assign K15[10] = decrypt_int ? K[55] : K[34];
assign K15[11] = decrypt_int ? K[46] : K[25];
assign K15[12] = decrypt_int ? K[26] : K[5];
assign K15[13] = decrypt_int ? K[3] : K[39];
assign K15[14] = decrypt_int ? K[32] : K[11];
assign K15[15] = decrypt_int ? K[40] : K[19];
assign K15[16] = decrypt_int ? K[41] : K[20];
assign K15[17] = decrypt_int ? K[24] : K[3];
assign K15[18] = decrypt_int ? K[12] : K[48];
assign K15[19] = decrypt_int ? K[11] : K[47];
assign K15[20] = decrypt_int ? K[5] : K[41];
assign K15[21] = decrypt_int ? K[6] : K[10];
assign K15[22] = decrypt_int ? K[39] : K[18];
assign K15[23] = decrypt_int ? K[47] : K[26];
assign K15[24] = decrypt_int ? K[27] : K[6];
assign K15[25] = decrypt_int ? K[43] : K[22];
assign K15[26] = decrypt_int ? K[38] : K[44];
assign K15[27] = decrypt_int ? K[28] : K[7];
assign K15[28] = decrypt_int ? K[15] : K[49];
assign K15[29] = decrypt_int ? K[30] : K[9];
assign K15[30] = decrypt_int ? K[0] : K[38];
assign K15[31] = decrypt_int ? K[21] : K[0];
assign K15[32] = decrypt_int ? K[36] : K[15];
assign K15[33] = decrypt_int ? K[31] : K[37];
assign K15[34] = decrypt_int ? K[16] : K[50];
assign K15[35] = decrypt_int ? K[42] : K[21];
assign K15[36] = decrypt_int ? K[37] : K[16];
assign K15[37] = decrypt_int ? K[9] : K[43];
assign K15[38] = decrypt_int ? K[44] : K[23];
assign K15[39] = decrypt_int ? K[29] : K[8];
assign K15[40] = decrypt_int ? K[7] : K[45];
assign K15[41] = decrypt_int ? K[49] : K[28];
assign K15[42] = decrypt_int ? K[45] : K[51];
assign K15[43] = decrypt_int ? K[23] : K[2];
assign K15[44] = decrypt_int ? K[50] : K[29];
assign K15[45] = decrypt_int ? K[51] : K[30];
assign K15[46] = decrypt_int ? K[8] : K[42];
assign K15[47] = decrypt_int ? K[14] : K[52];
assign K15[48] = decrypt_int ? K[35] : K[14];

assign K14[1] = decrypt_int ? K[11] : K[19];
assign K14[2] = decrypt_int ? K[32] : K[40];
assign K14[3] = decrypt_int ? K[47] : K[55];
assign K14[4] = decrypt_int ? K[24] : K[32];
assign K14[5] = decrypt_int ? K[34] : K[10];
assign K14[6] = decrypt_int ? K[5] : K[13];
assign K14[7] = decrypt_int ? K[48] : K[24];
assign K14[8] = decrypt_int ? K[27] : K[3];
assign K14[9] = decrypt_int ? K[18] : K[26];
assign K14[10] = decrypt_int ? K[12] : K[20];
assign K14[11] = decrypt_int ? K[3] : K[11];
assign K14[12] = decrypt_int ? K[40] : K[48];
assign K14[13] = decrypt_int ? K[17] : K[25];
assign K14[14] = decrypt_int ? K[46] : K[54];
assign K14[15] = decrypt_int ? K[54] : K[5];
assign K14[16] = decrypt_int ? K[55] : K[6];
assign K14[17] = decrypt_int ? K[13] : K[46];
assign K14[18] = decrypt_int ? K[26] : K[34];
assign K14[19] = decrypt_int ? K[25] : K[33];
assign K14[20] = decrypt_int ? K[19] : K[27];
assign K14[21] = decrypt_int ? K[20] : K[53];
assign K14[22] = decrypt_int ? K[53] : K[4];
assign K14[23] = decrypt_int ? K[4] : K[12];
assign K14[24] = decrypt_int ? K[41] : K[17];
assign K14[25] = decrypt_int ? K[2] : K[8];
assign K14[26] = decrypt_int ? K[52] : K[30];
assign K14[27] = decrypt_int ? K[42] : K[52];
assign K14[28] = decrypt_int ? K[29] : K[35];
assign K14[29] = decrypt_int ? K[44] : K[50];
assign K14[30] = decrypt_int ? K[14] : K[51];
assign K14[31] = decrypt_int ? K[35] : K[45];
assign K14[32] = decrypt_int ? K[50] : K[1];
assign K14[33] = decrypt_int ? K[45] : K[23];
assign K14[34] = decrypt_int ? K[30] : K[36];
assign K14[35] = decrypt_int ? K[1] : K[7];
assign K14[36] = decrypt_int ? K[51] : K[2];
assign K14[37] = decrypt_int ? K[23] : K[29];
assign K14[38] = decrypt_int ? K[31] : K[9];
assign K14[39] = decrypt_int ? K[43] : K[49];
assign K14[40] = decrypt_int ? K[21] : K[31];
assign K14[41] = decrypt_int ? K[8] : K[14];
assign K14[42] = decrypt_int ? K[0] : K[37];
assign K14[43] = decrypt_int ? K[37] : K[43];
assign K14[44] = decrypt_int ? K[9] : K[15];
assign K14[45] = decrypt_int ? K[38] : K[16];
assign K14[46] = decrypt_int ? K[22] : K[28];
assign K14[47] = decrypt_int ? K[28] : K[38];
assign K14[48] = decrypt_int ? K[49] : K[0];

assign K13[1] = decrypt_int ? K[25] : K[5];
assign K13[2] = decrypt_int ? K[46] : K[26];
assign K13[3] = decrypt_int ? K[4] : K[41];
assign K13[4] = decrypt_int ? K[13] : K[18];
assign K13[5] = decrypt_int ? K[48] : K[53];
assign K13[6] = decrypt_int ? K[19] : K[24];
assign K13[7] = decrypt_int ? K[5] : K[10];
assign K13[8] = decrypt_int ? K[41] : K[46];
assign K13[9] = decrypt_int ? K[32] : K[12];
assign K13[10] = decrypt_int ? K[26] : K[6];
assign K13[11] = decrypt_int ? K[17] : K[54];
assign K13[12] = decrypt_int ? K[54] : K[34];
assign K13[13] = decrypt_int ? K[6] : K[11];
assign K13[14] = decrypt_int ? K[3] : K[40];
assign K13[15] = decrypt_int ? K[11] : K[48];
assign K13[16] = decrypt_int ? K[12] : K[17];
assign K13[17] = decrypt_int ? K[27] : K[32];
assign K13[18] = decrypt_int ? K[40] : K[20];
assign K13[19] = decrypt_int ? K[39] : K[19];
assign K13[20] = decrypt_int ? K[33] : K[13];
assign K13[21] = decrypt_int ? K[34] : K[39];
assign K13[22] = decrypt_int ? K[10] : K[47];
assign K13[23] = decrypt_int ? K[18] : K[55];
assign K13[24] = decrypt_int ? K[55] : K[3];
assign K13[25] = decrypt_int ? K[16] : K[49];
assign K13[26] = decrypt_int ? K[7] : K[16];
assign K13[27] = decrypt_int ? K[1] : K[38];
assign K13[28] = decrypt_int ? K[43] : K[21];
assign K13[29] = decrypt_int ? K[31] : K[36];
assign K13[30] = decrypt_int ? K[28] : K[37];
assign K13[31] = decrypt_int ? K[49] : K[31];
assign K13[32] = decrypt_int ? K[9] : K[42];
assign K13[33] = decrypt_int ? K[0] : K[9];
assign K13[34] = decrypt_int ? K[44] : K[22];
assign K13[35] = decrypt_int ? K[15] : K[52];
assign K13[36] = decrypt_int ? K[38] : K[43];
assign K13[37] = decrypt_int ? K[37] : K[15];
assign K13[38] = decrypt_int ? K[45] : K[50];
assign K13[39] = decrypt_int ? K[2] : K[35];
assign K13[40] = decrypt_int ? K[35] : K[44];
assign K13[41] = decrypt_int ? K[22] : K[0];
assign K13[42] = decrypt_int ? K[14] : K[23];
assign K13[43] = decrypt_int ? K[51] : K[29];
assign K13[44] = decrypt_int ? K[23] : K[1];
assign K13[45] = decrypt_int ? K[52] : K[2];
assign K13[46] = decrypt_int ? K[36] : K[14];
assign K13[47] = decrypt_int ? K[42] : K[51];
assign K13[48] = decrypt_int ? K[8] : K[45];

assign K12[1] = decrypt_int ? K[39] : K[48];
assign K12[2] = decrypt_int ? K[3] : K[12];
assign K12[3] = decrypt_int ? K[18] : K[27];
assign K12[4] = decrypt_int ? K[27] : K[4];
assign K12[5] = decrypt_int ? K[5] : K[39];
assign K12[6] = decrypt_int ? K[33] : K[10];
assign K12[7] = decrypt_int ? K[19] : K[53];
assign K12[8] = decrypt_int ? K[55] : K[32];
assign K12[9] = decrypt_int ? K[46] : K[55];
assign K12[10] = decrypt_int ? K[40] : K[17];
assign K12[11] = decrypt_int ? K[6] : K[40];
assign K12[12] = decrypt_int ? K[11] : K[20];
assign K12[13] = decrypt_int ? K[20] : K[54];
assign K12[14] = decrypt_int ? K[17] : K[26];
assign K12[15] = decrypt_int ? K[25] : K[34];
assign K12[16] = decrypt_int ? K[26] : K[3];
assign K12[17] = decrypt_int ? K[41] : K[18];
assign K12[18] = decrypt_int ? K[54] : K[6];
assign K12[19] = decrypt_int ? K[53] : K[5];
assign K12[20] = decrypt_int ? K[47] : K[24];
assign K12[21] = decrypt_int ? K[48] : K[25];
assign K12[22] = decrypt_int ? K[24] : K[33];
assign K12[23] = decrypt_int ? K[32] : K[41];
assign K12[24] = decrypt_int ? K[12] : K[46];
assign K12[25] = decrypt_int ? K[30] : K[35];
assign K12[26] = decrypt_int ? K[21] : K[2];
assign K12[27] = decrypt_int ? K[15] : K[51];
assign K12[28] = decrypt_int ? K[2] : K[7];
assign K12[29] = decrypt_int ? K[45] : K[22];
assign K12[30] = decrypt_int ? K[42] : K[23];
assign K12[31] = decrypt_int ? K[8] : K[44];
assign K12[32] = decrypt_int ? K[23] : K[28];
assign K12[33] = decrypt_int ? K[14] : K[50];
assign K12[34] = decrypt_int ? K[31] : K[8];
assign K12[35] = decrypt_int ? K[29] : K[38];
assign K12[36] = decrypt_int ? K[52] : K[29];
assign K12[37] = decrypt_int ? K[51] : K[1];
assign K12[38] = decrypt_int ? K[0] : K[36];
assign K12[39] = decrypt_int ? K[16] : K[21];
assign K12[40] = decrypt_int ? K[49] : K[30];
assign K12[41] = decrypt_int ? K[36] : K[45];
assign K12[42] = decrypt_int ? K[28] : K[9];
assign K12[43] = decrypt_int ? K[38] : K[15];
assign K12[44] = decrypt_int ? K[37] : K[42];
assign K12[45] = decrypt_int ? K[7] : K[43];
assign K12[46] = decrypt_int ? K[50] : K[0];
assign K12[47] = decrypt_int ? K[1] : K[37];
assign K12[48] = decrypt_int ? K[22] : K[31];

assign K11[1] = decrypt_int ? K[53] : K[34];
assign K11[2] = decrypt_int ? K[17] : K[55];
assign K11[3] = decrypt_int ? K[32] : K[13];
assign K11[4] = decrypt_int ? K[41] : K[47];
assign K11[5] = decrypt_int ? K[19] : K[25];
assign K11[6] = decrypt_int ? K[47] : K[53];
assign K11[7] = decrypt_int ? K[33] : K[39];
assign K11[8] = decrypt_int ? K[12] : K[18];
assign K11[9] = decrypt_int ? K[3] : K[41];
assign K11[10] = decrypt_int ? K[54] : K[3];
assign K11[11] = decrypt_int ? K[20] : K[26];
assign K11[12] = decrypt_int ? K[25] : K[6];
assign K11[13] = decrypt_int ? K[34] : K[40];
assign K11[14] = decrypt_int ? K[6] : K[12];
assign K11[15] = decrypt_int ? K[39] : K[20];
assign K11[16] = decrypt_int ? K[40] : K[46];
assign K11[17] = decrypt_int ? K[55] : K[4];
assign K11[18] = decrypt_int ? K[11] : K[17];
assign K11[19] = decrypt_int ? K[10] : K[48];
assign K11[20] = decrypt_int ? K[4] : K[10];
assign K11[21] = decrypt_int ? K[5] : K[11];
assign K11[22] = decrypt_int ? K[13] : K[19];
assign K11[23] = decrypt_int ? K[46] : K[27];
assign K11[24] = decrypt_int ? K[26] : K[32];
assign K11[25] = decrypt_int ? K[44] : K[21];
assign K11[26] = decrypt_int ? K[35] : K[43];
assign K11[27] = decrypt_int ? K[29] : K[37];
assign K11[28] = decrypt_int ? K[16] : K[52];
assign K11[29] = decrypt_int ? K[0] : K[8];
assign K11[30] = decrypt_int ? K[1] : K[9];
assign K11[31] = decrypt_int ? K[22] : K[30];
assign K11[32] = decrypt_int ? K[37] : K[14];
assign K11[33] = decrypt_int ? K[28] : K[36];
assign K11[34] = decrypt_int ? K[45] : K[49];
assign K11[35] = decrypt_int ? K[43] : K[51];
assign K11[36] = decrypt_int ? K[7] : K[15];
assign K11[37] = decrypt_int ? K[38] : K[42];
assign K11[38] = decrypt_int ? K[14] : K[22];
assign K11[39] = decrypt_int ? K[30] : K[7];
assign K11[40] = decrypt_int ? K[8] : K[16];
assign K11[41] = decrypt_int ? K[50] : K[31];
assign K11[42] = decrypt_int ? K[42] : K[50];
assign K11[43] = decrypt_int ? K[52] : K[1];
assign K11[44] = decrypt_int ? K[51] : K[28];
assign K11[45] = decrypt_int ? K[21] : K[29];
assign K11[46] = decrypt_int ? K[9] : K[45];
assign K11[47] = decrypt_int ? K[15] : K[23];
assign K11[48] = decrypt_int ? K[36] : K[44];

assign K10[1] = decrypt_int ? K[10] : K[20];
assign K10[2] = decrypt_int ? K[6] : K[41];
assign K10[3] = decrypt_int ? K[46] : K[24];
assign K10[4] = decrypt_int ? K[55] : K[33];
assign K10[5] = decrypt_int ? K[33] : K[11];
assign K10[6] = decrypt_int ? K[4] : K[39];
assign K10[7] = decrypt_int ? K[47] : K[25];
assign K10[8] = decrypt_int ? K[26] : K[4];
assign K10[9] = decrypt_int ? K[17] : K[27];
assign K10[10] = decrypt_int ? K[11] : K[46];
assign K10[11] = decrypt_int ? K[34] : K[12];
assign K10[12] = decrypt_int ? K[39] : K[17];
assign K10[13] = decrypt_int ? K[48] : K[26];
assign K10[14] = decrypt_int ? K[20] : K[55];
assign K10[15] = decrypt_int ? K[53] : K[6];
assign K10[16] = decrypt_int ? K[54] : K[32];
assign K10[17] = decrypt_int ? K[12] : K[47];
assign K10[18] = decrypt_int ? K[25] : K[3];
assign K10[19] = decrypt_int ? K[24] : K[34];
assign K10[20] = decrypt_int ? K[18] : K[53];
assign K10[21] = decrypt_int ? K[19] : K[54];
assign K10[22] = decrypt_int ? K[27] : K[5];
assign K10[23] = decrypt_int ? K[3] : K[13];
assign K10[24] = decrypt_int ? K[40] : K[18];
assign K10[25] = decrypt_int ? K[31] : K[7];
assign K10[26] = decrypt_int ? K[49] : K[29];
assign K10[27] = decrypt_int ? K[43] : K[23];
assign K10[28] = decrypt_int ? K[30] : K[38];
assign K10[29] = decrypt_int ? K[14] : K[49];
assign K10[30] = decrypt_int ? K[15] : K[50];
assign K10[31] = decrypt_int ? K[36] : K[16];
assign K10[32] = decrypt_int ? K[51] : K[0];
assign K10[33] = decrypt_int ? K[42] : K[22];
assign K10[34] = decrypt_int ? K[0] : K[35];
assign K10[35] = decrypt_int ? K[2] : K[37];
assign K10[36] = decrypt_int ? K[21] : K[1];
assign K10[37] = decrypt_int ? K[52] : K[28];
assign K10[38] = decrypt_int ? K[28] : K[8];
assign K10[39] = decrypt_int ? K[44] : K[52];
assign K10[40] = decrypt_int ? K[22] : K[2];
assign K10[41] = decrypt_int ? K[9] : K[44];
assign K10[42] = decrypt_int ? K[1] : K[36];
assign K10[43] = decrypt_int ? K[7] : K[42];
assign K10[44] = decrypt_int ? K[38] : K[14];
assign K10[45] = decrypt_int ? K[35] : K[15];
assign K10[46] = decrypt_int ? K[23] : K[31];
assign K10[47] = decrypt_int ? K[29] : K[9];
assign K10[48] = decrypt_int ? K[50] : K[30];

assign K9[1] = decrypt_int ? K[24] : K[6];
assign K9[2] = decrypt_int ? K[20] : K[27];
assign K9[3] = decrypt_int ? K[3] : K[10];
assign K9[4] = decrypt_int ? K[12] : K[19];
assign K9[5] = decrypt_int ? K[47] : K[54];
assign K9[6] = decrypt_int ? K[18] : K[25];
assign K9[7] = decrypt_int ? K[4] : K[11];
assign K9[8] = decrypt_int ? K[40] : K[47];
assign K9[9] = decrypt_int ? K[6] : K[13];
assign K9[10] = decrypt_int ? K[25] : K[32];
assign K9[11] = decrypt_int ? K[48] : K[55];
assign K9[12] = decrypt_int ? K[53] : K[3];
assign K9[13] = decrypt_int ? K[5] : K[12];
assign K9[14] = decrypt_int ? K[34] : K[41];
assign K9[15] = decrypt_int ? K[10] : K[17];
assign K9[16] = decrypt_int ? K[11] : K[18];
assign K9[17] = decrypt_int ? K[26] : K[33];
assign K9[18] = decrypt_int ? K[39] : K[46];
assign K9[19] = decrypt_int ? K[13] : K[20];
assign K9[20] = decrypt_int ? K[32] : K[39];
assign K9[21] = decrypt_int ? K[33] : K[40];
assign K9[22] = decrypt_int ? K[41] : K[48];
assign K9[23] = decrypt_int ? K[17] : K[24];
assign K9[24] = decrypt_int ? K[54] : K[4];
assign K9[25] = decrypt_int ? K[45] : K[52];
assign K9[26] = decrypt_int ? K[8] : K[15];
assign K9[27] = decrypt_int ? K[2] : K[9];
assign K9[28] = decrypt_int ? K[44] : K[51];
assign K9[29] = decrypt_int ? K[28] : K[35];
assign K9[30] = decrypt_int ? K[29] : K[36];
assign K9[31] = decrypt_int ? K[50] : K[2];
assign K9[32] = decrypt_int ? K[38] : K[45];
assign K9[33] = decrypt_int ? K[1] : K[8];
assign K9[34] = decrypt_int ? K[14] : K[21];
assign K9[35] = decrypt_int ? K[16] : K[23];
assign K9[36] = decrypt_int ? K[35] : K[42];
assign K9[37] = decrypt_int ? K[7] : K[14];
assign K9[38] = decrypt_int ? K[42] : K[49];
assign K9[39] = decrypt_int ? K[31] : K[38];
assign K9[40] = decrypt_int ? K[36] : K[43];
assign K9[41] = decrypt_int ? K[23] : K[30];
assign K9[42] = decrypt_int ? K[15] : K[22];
assign K9[43] = decrypt_int ? K[21] : K[28];
assign K9[44] = decrypt_int ? K[52] : K[0];
assign K9[45] = decrypt_int ? K[49] : K[1];
assign K9[46] = decrypt_int ? K[37] : K[44];
assign K9[47] = decrypt_int ? K[43] : K[50];
assign K9[48] = decrypt_int ? K[9] : K[16];

assign K8[1] = decrypt_int ? K[6] : K[24];
assign K8[2] = decrypt_int ? K[27] : K[20];
assign K8[3] = decrypt_int ? K[10] : K[3];
assign K8[4] = decrypt_int ? K[19] : K[12];
assign K8[5] = decrypt_int ? K[54] : K[47];
assign K8[6] = decrypt_int ? K[25] : K[18];
assign K8[7] = decrypt_int ? K[11] : K[4];
assign K8[8] = decrypt_int ? K[47] : K[40];
assign K8[9] = decrypt_int ? K[13] : K[6];
assign K8[10] = decrypt_int ? K[32] : K[25];
assign K8[11] = decrypt_int ? K[55] : K[48];
assign K8[12] = decrypt_int ? K[3] : K[53];
assign K8[13] = decrypt_int ? K[12] : K[5];
assign K8[14] = decrypt_int ? K[41] : K[34];
assign K8[15] = decrypt_int ? K[17] : K[10];
assign K8[16] = decrypt_int ? K[18] : K[11];
assign K8[17] = decrypt_int ? K[33] : K[26];
assign K8[18] = decrypt_int ? K[46] : K[39];
assign K8[19] = decrypt_int ? K[20] : K[13];
assign K8[20] = decrypt_int ? K[39] : K[32];
assign K8[21] = decrypt_int ? K[40] : K[33];
assign K8[22] = decrypt_int ? K[48] : K[41];
assign K8[23] = decrypt_int ? K[24] : K[17];
assign K8[24] = decrypt_int ? K[4] : K[54];
assign K8[25] = decrypt_int ? K[52] : K[45];
assign K8[26] = decrypt_int ? K[15] : K[8];
assign K8[27] = decrypt_int ? K[9] : K[2];
assign K8[28] = decrypt_int ? K[51] : K[44];
assign K8[29] = decrypt_int ? K[35] : K[28];
assign K8[30] = decrypt_int ? K[36] : K[29];
assign K8[31] = decrypt_int ? K[2] : K[50];
assign K8[32] = decrypt_int ? K[45] : K[38];
assign K8[33] = decrypt_int ? K[8] : K[1];
assign K8[34] = decrypt_int ? K[21] : K[14];
assign K8[35] = decrypt_int ? K[23] : K[16];
assign K8[36] = decrypt_int ? K[42] : K[35];
assign K8[37] = decrypt_int ? K[14] : K[7];
assign K8[38] = decrypt_int ? K[49] : K[42];
assign K8[39] = decrypt_int ? K[38] : K[31];
assign K8[40] = decrypt_int ? K[43] : K[36];
assign K8[41] = decrypt_int ? K[30] : K[23];
assign K8[42] = decrypt_int ? K[22] : K[15];
assign K8[43] = decrypt_int ? K[28] : K[21];
assign K8[44] = decrypt_int ? K[0] : K[52];
assign K8[45] = decrypt_int ? K[1] : K[49];
assign K8[46] = decrypt_int ? K[44] : K[37];
assign K8[47] = decrypt_int ? K[50] : K[43];
assign K8[48] = decrypt_int ? K[16] : K[9];

assign K7[1] = decrypt_int ? K[20] : K[10];
assign K7[2] = decrypt_int ? K[41] : K[6];
assign K7[3] = decrypt_int ? K[24] : K[46];
assign K7[4] = decrypt_int ? K[33] : K[55];
assign K7[5] = decrypt_int ? K[11] : K[33];
assign K7[6] = decrypt_int ? K[39] : K[4];
assign K7[7] = decrypt_int ? K[25] : K[47];
assign K7[8] = decrypt_int ? K[4] : K[26];
assign K7[9] = decrypt_int ? K[27] : K[17];
assign K7[10] = decrypt_int ? K[46] : K[11];
assign K7[11] = decrypt_int ? K[12] : K[34];
assign K7[12] = decrypt_int ? K[17] : K[39];
assign K7[13] = decrypt_int ? K[26] : K[48];
assign K7[14] = decrypt_int ? K[55] : K[20];
assign K7[15] = decrypt_int ? K[6] : K[53];
assign K7[16] = decrypt_int ? K[32] : K[54];
assign K7[17] = decrypt_int ? K[47] : K[12];
assign K7[18] = decrypt_int ? K[3] : K[25];
assign K7[19] = decrypt_int ? K[34] : K[24];
assign K7[20] = decrypt_int ? K[53] : K[18];
assign K7[21] = decrypt_int ? K[54] : K[19];
assign K7[22] = decrypt_int ? K[5] : K[27];
assign K7[23] = decrypt_int ? K[13] : K[3];
assign K7[24] = decrypt_int ? K[18] : K[40];
assign K7[25] = decrypt_int ? K[7] : K[31];
assign K7[26] = decrypt_int ? K[29] : K[49];
assign K7[27] = decrypt_int ? K[23] : K[43];
assign K7[28] = decrypt_int ? K[38] : K[30];
assign K7[29] = decrypt_int ? K[49] : K[14];
assign K7[30] = decrypt_int ? K[50] : K[15];
assign K7[31] = decrypt_int ? K[16] : K[36];
assign K7[32] = decrypt_int ? K[0] : K[51];
assign K7[33] = decrypt_int ? K[22] : K[42];
assign K7[34] = decrypt_int ? K[35] : K[0];
assign K7[35] = decrypt_int ? K[37] : K[2];
assign K7[36] = decrypt_int ? K[1] : K[21];
assign K7[37] = decrypt_int ? K[28] : K[52];
assign K7[38] = decrypt_int ? K[8] : K[28];
assign K7[39] = decrypt_int ? K[52] : K[44];
assign K7[40] = decrypt_int ? K[2] : K[22];
assign K7[41] = decrypt_int ? K[44] : K[9];
assign K7[42] = decrypt_int ? K[36] : K[1];
assign K7[43] = decrypt_int ? K[42] : K[7];
assign K7[44] = decrypt_int ? K[14] : K[38];
assign K7[45] = decrypt_int ? K[15] : K[35];
assign K7[46] = decrypt_int ? K[31] : K[23];
assign K7[47] = decrypt_int ? K[9] : K[29];
assign K7[48] = decrypt_int ? K[30] : K[50];

assign K6[1] = decrypt_int ? K[34] : K[53];
assign K6[2] = decrypt_int ? K[55] : K[17];
assign K6[3] = decrypt_int ? K[13] : K[32];
assign K6[4] = decrypt_int ? K[47] : K[41];
assign K6[5] = decrypt_int ? K[25] : K[19];
assign K6[6] = decrypt_int ? K[53] : K[47];
assign K6[7] = decrypt_int ? K[39] : K[33];
assign K6[8] = decrypt_int ? K[18] : K[12];
assign K6[9] = decrypt_int ? K[41] : K[3];
assign K6[10] = decrypt_int ? K[3] : K[54];
assign K6[11] = decrypt_int ? K[26] : K[20];
assign K6[12] = decrypt_int ? K[6] : K[25];
assign K6[13] = decrypt_int ? K[40] : K[34];
assign K6[14] = decrypt_int ? K[12] : K[6];
assign K6[15] = decrypt_int ? K[20] : K[39];
assign K6[16] = decrypt_int ? K[46] : K[40];
assign K6[17] = decrypt_int ? K[4] : K[55];
assign K6[18] = decrypt_int ? K[17] : K[11];
assign K6[19] = decrypt_int ? K[48] : K[10];
assign K6[20] = decrypt_int ? K[10] : K[4];
assign K6[21] = decrypt_int ? K[11] : K[5];
assign K6[22] = decrypt_int ? K[19] : K[13];
assign K6[23] = decrypt_int ? K[27] : K[46];
assign K6[24] = decrypt_int ? K[32] : K[26];
assign K6[25] = decrypt_int ? K[21] : K[44];
assign K6[26] = decrypt_int ? K[43] : K[35];
assign K6[27] = decrypt_int ? K[37] : K[29];
assign K6[28] = decrypt_int ? K[52] : K[16];
assign K6[29] = decrypt_int ? K[8] : K[0];
assign K6[30] = decrypt_int ? K[9] : K[1];
assign K6[31] = decrypt_int ? K[30] : K[22];
assign K6[32] = decrypt_int ? K[14] : K[37];
assign K6[33] = decrypt_int ? K[36] : K[28];
assign K6[34] = decrypt_int ? K[49] : K[45];
assign K6[35] = decrypt_int ? K[51] : K[43];
assign K6[36] = decrypt_int ? K[15] : K[7];
assign K6[37] = decrypt_int ? K[42] : K[38];
assign K6[38] = decrypt_int ? K[22] : K[14];
assign K6[39] = decrypt_int ? K[7] : K[30];
assign K6[40] = decrypt_int ? K[16] : K[8];
assign K6[41] = decrypt_int ? K[31] : K[50];
assign K6[42] = decrypt_int ? K[50] : K[42];
assign K6[43] = decrypt_int ? K[1] : K[52];
assign K6[44] = decrypt_int ? K[28] : K[51];
assign K6[45] = decrypt_int ? K[29] : K[21];
assign K6[46] = decrypt_int ? K[45] : K[9];
assign K6[47] = decrypt_int ? K[23] : K[15];
assign K6[48] = decrypt_int ? K[44] : K[36];

assign K5[1] = decrypt_int ? K[48] : K[39];
assign K5[2] = decrypt_int ? K[12] : K[3];
assign K5[3] = decrypt_int ? K[27] : K[18];
assign K5[4] = decrypt_int ? K[4] : K[27];
assign K5[5] = decrypt_int ? K[39] : K[5];
assign K5[6] = decrypt_int ? K[10] : K[33];
assign K5[7] = decrypt_int ? K[53] : K[19];
assign K5[8] = decrypt_int ? K[32] : K[55];
assign K5[9] = decrypt_int ? K[55] : K[46];
assign K5[10] = decrypt_int ? K[17] : K[40];
assign K5[11] = decrypt_int ? K[40] : K[6];
assign K5[12] = decrypt_int ? K[20] : K[11];
assign K5[13] = decrypt_int ? K[54] : K[20];
assign K5[14] = decrypt_int ? K[26] : K[17];
assign K5[15] = decrypt_int ? K[34] : K[25];
assign K5[16] = decrypt_int ? K[3] : K[26];
assign K5[17] = decrypt_int ? K[18] : K[41];
assign K5[18] = decrypt_int ? K[6] : K[54];
assign K5[19] = decrypt_int ? K[5] : K[53];
assign K5[20] = decrypt_int ? K[24] : K[47];
assign K5[21] = decrypt_int ? K[25] : K[48];
assign K5[22] = decrypt_int ? K[33] : K[24];
assign K5[23] = decrypt_int ? K[41] : K[32];
assign K5[24] = decrypt_int ? K[46] : K[12];
assign K5[25] = decrypt_int ? K[35] : K[30];
assign K5[26] = decrypt_int ? K[2] : K[21];
assign K5[27] = decrypt_int ? K[51] : K[15];
assign K5[28] = decrypt_int ? K[7] : K[2];
assign K5[29] = decrypt_int ? K[22] : K[45];
assign K5[30] = decrypt_int ? K[23] : K[42];
assign K5[31] = decrypt_int ? K[44] : K[8];
assign K5[32] = decrypt_int ? K[28] : K[23];
assign K5[33] = decrypt_int ? K[50] : K[14];
assign K5[34] = decrypt_int ? K[8] : K[31];
assign K5[35] = decrypt_int ? K[38] : K[29];
assign K5[36] = decrypt_int ? K[29] : K[52];
assign K5[37] = decrypt_int ? K[1] : K[51];
assign K5[38] = decrypt_int ? K[36] : K[0];
assign K5[39] = decrypt_int ? K[21] : K[16];
assign K5[40] = decrypt_int ? K[30] : K[49];
assign K5[41] = decrypt_int ? K[45] : K[36];
assign K5[42] = decrypt_int ? K[9] : K[28];
assign K5[43] = decrypt_int ? K[15] : K[38];
assign K5[44] = decrypt_int ? K[42] : K[37];
assign K5[45] = decrypt_int ? K[43] : K[7];
assign K5[46] = decrypt_int ? K[0] : K[50];
assign K5[47] = decrypt_int ? K[37] : K[1];
assign K5[48] = decrypt_int ? K[31] : K[22];

assign K4[1] = decrypt_int ? K[5] : K[25];
assign K4[2] = decrypt_int ? K[26] : K[46];
assign K4[3] = decrypt_int ? K[41] : K[4];
assign K4[4] = decrypt_int ? K[18] : K[13];
assign K4[5] = decrypt_int ? K[53] : K[48];
assign K4[6] = decrypt_int ? K[24] : K[19];
assign K4[7] = decrypt_int ? K[10] : K[5];
assign K4[8] = decrypt_int ? K[46] : K[41];
assign K4[9] = decrypt_int ? K[12] : K[32];
assign K4[10] = decrypt_int ? K[6] : K[26];
assign K4[11] = decrypt_int ? K[54] : K[17];
assign K4[12] = decrypt_int ? K[34] : K[54];
assign K4[13] = decrypt_int ? K[11] : K[6];
assign K4[14] = decrypt_int ? K[40] : K[3];
assign K4[15] = decrypt_int ? K[48] : K[11];
assign K4[16] = decrypt_int ? K[17] : K[12];
assign K4[17] = decrypt_int ? K[32] : K[27];
assign K4[18] = decrypt_int ? K[20] : K[40];
assign K4[19] = decrypt_int ? K[19] : K[39];
assign K4[20] = decrypt_int ? K[13] : K[33];
assign K4[21] = decrypt_int ? K[39] : K[34];
assign K4[22] = decrypt_int ? K[47] : K[10];
assign K4[23] = decrypt_int ? K[55] : K[18];
assign K4[24] = decrypt_int ? K[3] : K[55];
assign K4[25] = decrypt_int ? K[49] : K[16];
assign K4[26] = decrypt_int ? K[16] : K[7];
assign K4[27] = decrypt_int ? K[38] : K[1];
assign K4[28] = decrypt_int ? K[21] : K[43];
assign K4[29] = decrypt_int ? K[36] : K[31];
assign K4[30] = decrypt_int ? K[37] : K[28];
assign K4[31] = decrypt_int ? K[31] : K[49];
assign K4[32] = decrypt_int ? K[42] : K[9];
assign K4[33] = decrypt_int ? K[9] : K[0];
assign K4[34] = decrypt_int ? K[22] : K[44];
assign K4[35] = decrypt_int ? K[52] : K[15];
assign K4[36] = decrypt_int ? K[43] : K[38];
assign K4[37] = decrypt_int ? K[15] : K[37];
assign K4[38] = decrypt_int ? K[50] : K[45];
assign K4[39] = decrypt_int ? K[35] : K[2];
assign K4[40] = decrypt_int ? K[44] : K[35];
assign K4[41] = decrypt_int ? K[0] : K[22];
assign K4[42] = decrypt_int ? K[23] : K[14];
assign K4[43] = decrypt_int ? K[29] : K[51];
assign K4[44] = decrypt_int ? K[1] : K[23];
assign K4[45] = decrypt_int ? K[2] : K[52];
assign K4[46] = decrypt_int ? K[14] : K[36];
assign K4[47] = decrypt_int ? K[51] : K[42];
assign K4[48] = decrypt_int ? K[45] : K[8];

assign K3[1] = decrypt_int ? K[19] : K[11];
assign K3[2] = decrypt_int ? K[40] : K[32];
assign K3[3] = decrypt_int ? K[55] : K[47];
assign K3[4] = decrypt_int ? K[32] : K[24];
assign K3[5] = decrypt_int ? K[10] : K[34];
assign K3[6] = decrypt_int ? K[13] : K[5];
assign K3[7] = decrypt_int ? K[24] : K[48];
assign K3[8] = decrypt_int ? K[3] : K[27];
assign K3[9] = decrypt_int ? K[26] : K[18];
assign K3[10] = decrypt_int ? K[20] : K[12];
assign K3[11] = decrypt_int ? K[11] : K[3];
assign K3[12] = decrypt_int ? K[48] : K[40];
assign K3[13] = decrypt_int ? K[25] : K[17];
assign K3[14] = decrypt_int ? K[54] : K[46];
assign K3[15] = decrypt_int ? K[5] : K[54];
assign K3[16] = decrypt_int ? K[6] : K[55];
assign K3[17] = decrypt_int ? K[46] : K[13];
assign K3[18] = decrypt_int ? K[34] : K[26];
assign K3[19] = decrypt_int ? K[33] : K[25];
assign K3[20] = decrypt_int ? K[27] : K[19];
assign K3[21] = decrypt_int ? K[53] : K[20];
assign K3[22] = decrypt_int ? K[4] : K[53];
assign K3[23] = decrypt_int ? K[12] : K[4];
assign K3[24] = decrypt_int ? K[17] : K[41];
assign K3[25] = decrypt_int ? K[8] : K[2];
assign K3[26] = decrypt_int ? K[30] : K[52];
assign K3[27] = decrypt_int ? K[52] : K[42];
assign K3[28] = decrypt_int ? K[35] : K[29];
assign K3[29] = decrypt_int ? K[50] : K[44];
assign K3[30] = decrypt_int ? K[51] : K[14];
assign K3[31] = decrypt_int ? K[45] : K[35];
assign K3[32] = decrypt_int ? K[1] : K[50];
assign K3[33] = decrypt_int ? K[23] : K[45];
assign K3[34] = decrypt_int ? K[36] : K[30];
assign K3[35] = decrypt_int ? K[7] : K[1];
assign K3[36] = decrypt_int ? K[2] : K[51];
assign K3[37] = decrypt_int ? K[29] : K[23];
assign K3[38] = decrypt_int ? K[9] : K[31];
assign K3[39] = decrypt_int ? K[49] : K[43];
assign K3[40] = decrypt_int ? K[31] : K[21];
assign K3[41] = decrypt_int ? K[14] : K[8];
assign K3[42] = decrypt_int ? K[37] : K[0];
assign K3[43] = decrypt_int ? K[43] : K[37];
assign K3[44] = decrypt_int ? K[15] : K[9];
assign K3[45] = decrypt_int ? K[16] : K[38];
assign K3[46] = decrypt_int ? K[28] : K[22];
assign K3[47] = decrypt_int ? K[38] : K[28];
assign K3[48] = decrypt_int ? K[0] : K[49];

assign K2[1] = decrypt_int ? K[33] : K[54];
assign K2[2] = decrypt_int ? K[54] : K[18];
assign K2[3] = decrypt_int ? K[12] : K[33];
assign K2[4] = decrypt_int ? K[46] : K[10];
assign K2[5] = decrypt_int ? K[24] : K[20];
assign K2[6] = decrypt_int ? K[27] : K[48];
assign K2[7] = decrypt_int ? K[13] : K[34];
assign K2[8] = decrypt_int ? K[17] : K[13];
assign K2[9] = decrypt_int ? K[40] : K[4];
assign K2[10] = decrypt_int ? K[34] : K[55];
assign K2[11] = decrypt_int ? K[25] : K[46];
assign K2[12] = decrypt_int ? K[5] : K[26];
assign K2[13] = decrypt_int ? K[39] : K[3];
assign K2[14] = decrypt_int ? K[11] : K[32];
assign K2[15] = decrypt_int ? K[19] : K[40];
assign K2[16] = decrypt_int ? K[20] : K[41];
assign K2[17] = decrypt_int ? K[3] : K[24];
assign K2[18] = decrypt_int ? K[48] : K[12];
assign K2[19] = decrypt_int ? K[47] : K[11];
assign K2[20] = decrypt_int ? K[41] : K[5];
assign K2[21] = decrypt_int ? K[10] : K[6];
assign K2[22] = decrypt_int ? K[18] : K[39];
assign K2[23] = decrypt_int ? K[26] : K[47];
assign K2[24] = decrypt_int ? K[6] : K[27];
assign K2[25] = decrypt_int ? K[22] : K[43];
assign K2[26] = decrypt_int ? K[44] : K[38];
assign K2[27] = decrypt_int ? K[7] : K[28];
assign K2[28] = decrypt_int ? K[49] : K[15];
assign K2[29] = decrypt_int ? K[9] : K[30];
assign K2[30] = decrypt_int ? K[38] : K[0];
assign K2[31] = decrypt_int ? K[0] : K[21];
assign K2[32] = decrypt_int ? K[15] : K[36];
assign K2[33] = decrypt_int ? K[37] : K[31];
assign K2[34] = decrypt_int ? K[50] : K[16];
assign K2[35] = decrypt_int ? K[21] : K[42];
assign K2[36] = decrypt_int ? K[16] : K[37];
assign K2[37] = decrypt_int ? K[43] : K[9];
assign K2[38] = decrypt_int ? K[23] : K[44];
assign K2[39] = decrypt_int ? K[8] : K[29];
assign K2[40] = decrypt_int ? K[45] : K[7];
assign K2[41] = decrypt_int ? K[28] : K[49];
assign K2[42] = decrypt_int ? K[51] : K[45];
assign K2[43] = decrypt_int ? K[2] : K[23];
assign K2[44] = decrypt_int ? K[29] : K[50];
assign K2[45] = decrypt_int ? K[30] : K[51];
assign K2[46] = decrypt_int ? K[42] : K[8];
assign K2[47] = decrypt_int ? K[52] : K[14];
assign K2[48] = decrypt_int ? K[14] : K[35];

assign K1[1] = decrypt_int ? K[40]  : K[47];
assign K1[2] = decrypt_int ? K[4]   : K[11];
assign K1[3] = decrypt_int ? K[19]  : K[26];
assign K1[4] = decrypt_int ? K[53]  : K[3];
assign K1[5] = decrypt_int ? K[6]   : K[13];
assign K1[6] = decrypt_int ? K[34]  : K[41];
assign K1[7] = decrypt_int ? K[20]  : K[27];
assign K1[8] = decrypt_int ? K[24]  : K[6];
assign K1[9] = decrypt_int ? K[47]  : K[54];
assign K1[10] = decrypt_int ? K[41] : K[48];
assign K1[11] = decrypt_int ? K[32] : K[39];
assign K1[12] = decrypt_int ? K[12] : K[19];
assign K1[13] = decrypt_int ? K[46] : K[53];
assign K1[14] = decrypt_int ? K[18] : K[25];
assign K1[15] = decrypt_int ? K[26] : K[33];
assign K1[16] = decrypt_int ? K[27] : K[34];
assign K1[17] = decrypt_int ? K[10] : K[17];
assign K1[18] = decrypt_int ? K[55] : K[5];
assign K1[19] = decrypt_int ? K[54] : K[4];
assign K1[20] = decrypt_int ? K[48] : K[55];
assign K1[21] = decrypt_int ? K[17] : K[24];
assign K1[22] = decrypt_int ? K[25] : K[32];
assign K1[23] = decrypt_int ? K[33] : K[40];
assign K1[24] = decrypt_int ? K[13] : K[20];
assign K1[25] = decrypt_int ? K[29] : K[36];
assign K1[26] = decrypt_int ? K[51] : K[31];
assign K1[27] = decrypt_int ? K[14] : K[21];
assign K1[28] = decrypt_int ? K[1]  : K[8];
assign K1[29] = decrypt_int ? K[16] : K[23];
assign K1[30] = decrypt_int ? K[45] : K[52];
assign K1[31] = decrypt_int ? K[7]  : K[14];
assign K1[32] = decrypt_int ? K[22] : K[29];
assign K1[33] = decrypt_int ? K[44] : K[51];
assign K1[34] = decrypt_int ? K[2]  : K[9];
assign K1[35] = decrypt_int ? K[28] : K[35];
assign K1[36] = decrypt_int ? K[23] : K[30];
assign K1[37] = decrypt_int ? K[50] : K[2];
assign K1[38] = decrypt_int ? K[30] : K[37];
assign K1[39] = decrypt_int ? K[15] : K[22];
assign K1[40] = decrypt_int ? K[52] : K[0];
assign K1[41] = decrypt_int ? K[35] : K[42];
assign K1[42] = decrypt_int ? K[31] : K[38];
assign K1[43] = decrypt_int ? K[9]  : K[16];
assign K1[44] = decrypt_int ? K[36] : K[43];
assign K1[45] = decrypt_int ? K[37] : K[44];
assign K1[46] = decrypt_int ? K[49] : K[1];
assign K1[47] = decrypt_int ? K[0]  : K[7];
assign K1[48] = decrypt_int ? K[21] : K[28];

endmodule
