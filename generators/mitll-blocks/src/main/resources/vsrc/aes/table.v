/*
 * Copyright 2012, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* verilator lint_off UNOPTFLAT */

module table_lookup (clk, rst, state, p0, p1, p2, p3);
    input clk;
    input rst;
    input [31:0] state;
    output [31:0] p0, p1, p2, p3;
    
    wire [7:0] b0, b1, b2, b3;

    assign {b0, b1, b2, b3} = state;
    T
        t0 (clk, rst, b0, {p0[23:0], p0[31:24]}),
        t1 (clk, rst, b1, {p1[15:0], p1[31:16]}),
        t2 (clk, rst, b2, {p2[7:0],  p2[31:8]} ),
        t3 (clk, rst, b3, p3);
endmodule   // end table_lookup

/* substitue four bytes in a word */
module S4 (clk, rst, in, out);
    input clk;
    input rst;
    input [31:0] in;
    output [31:0] out;

    S
        S_0 (clk, rst, in[31:24], out[31:24]),
        S_1 (clk, rst, in[23:16], out[23:16]),
        S_2 (clk, rst, in[15:8],  out[15:8] ),
        S_3 (clk, rst, in[7:0],   out[7:0]  );

endmodule   // end S4

/* S_box, S_box, S_box*(x+1), S_box*x */
module T (clk, rst, in, out);
    input         clk;
    input         rst;
    input  [7:0]  in;
    output [31:0] out;

    S
        s0 (clk, rst, in, out[31:24]);

    assign out[23:16] = out[31:24];

    xS
        s4 (clk, rst, in, out[7:0]);

    assign out[15:8] = out[23:16] ^ out[7:0];

endmodule   // end T

/* S box */
module S (clk, rst, in, out);
    input clk;
    input rst;
    input [7:0] in;
    output reg [7:0] out;

    always @ (posedge clk)
        if (rst)
            out <= 8'd0;
        else
            case (in)
            8'h00:  out <= 8'h63;
            8'h01:  out <= 8'h7c;
            8'h02:  out <= 8'h77;
            8'h03:  out <= 8'h7b;
            8'h04:  out <= 8'hf2;
            8'h05:  out <= 8'h6b;
            8'h06:  out <= 8'h6f;
            8'h07:  out <= 8'hc5;
            8'h08:  out <= 8'h30;
            8'h09:  out <= 8'h01;
            8'h0a:  out <= 8'h67;
            8'h0b:  out <= 8'h2b;
            8'h0c:  out <= 8'hfe;
            8'h0d:  out <= 8'hd7;
            8'h0e:  out <= 8'hab;
            8'h0f:  out <= 8'h76;
            8'h10:  out <= 8'hca;
            8'h11:  out <= 8'h82;
            8'h12:  out <= 8'hc9;
            8'h13:  out <= 8'h7d;
            8'h14:  out <= 8'hfa;
            8'h15:  out <= 8'h59;
            8'h16:  out <= 8'h47;
            8'h17:  out <= 8'hf0;
            8'h18:  out <= 8'had;
            8'h19:  out <= 8'hd4;
            8'h1a:  out <= 8'ha2;
            8'h1b:  out <= 8'haf;
            8'h1c:  out <= 8'h9c;
            8'h1d:  out <= 8'ha4;
            8'h1e:  out <= 8'h72;
            8'h1f:  out <= 8'hc0;
            8'h20:  out <= 8'hb7;
            8'h21:  out <= 8'hfd;
            8'h22:  out <= 8'h93;
            8'h23:  out <= 8'h26;
            8'h24:  out <= 8'h36;
            8'h25:  out <= 8'h3f;
            8'h26:  out <= 8'hf7;
            8'h27:  out <= 8'hcc;
            8'h28:  out <= 8'h34;
            8'h29:  out <= 8'ha5;
            8'h2a:  out <= 8'he5;
            8'h2b:  out <= 8'hf1;
            8'h2c:  out <= 8'h71;
            8'h2d:  out <= 8'hd8;
            8'h2e:  out <= 8'h31;
            8'h2f:  out <= 8'h15;
            8'h30:  out <= 8'h04;
            8'h31:  out <= 8'hc7;
            8'h32:  out <= 8'h23;
            8'h33:  out <= 8'hc3;
            8'h34:  out <= 8'h18;
            8'h35:  out <= 8'h96;
            8'h36:  out <= 8'h05;
            8'h37:  out <= 8'h9a;
            8'h38:  out <= 8'h07;
            8'h39:  out <= 8'h12;
            8'h3a:  out <= 8'h80;
            8'h3b:  out <= 8'he2;
            8'h3c:  out <= 8'heb;
            8'h3d:  out <= 8'h27;
            8'h3e:  out <= 8'hb2;
            8'h3f:  out <= 8'h75;
            8'h40:  out <= 8'h09;
            8'h41:  out <= 8'h83;
            8'h42:  out <= 8'h2c;
            8'h43:  out <= 8'h1a;
            8'h44:  out <= 8'h1b;
            8'h45:  out <= 8'h6e;
            8'h46:  out <= 8'h5a;
            8'h47:  out <= 8'ha0;
            8'h48:  out <= 8'h52;
            8'h49:  out <= 8'h3b;
            8'h4a:  out <= 8'hd6;
            8'h4b:  out <= 8'hb3;
            8'h4c:  out <= 8'h29;
            8'h4d:  out <= 8'he3;
            8'h4e:  out <= 8'h2f;
            8'h4f:  out <= 8'h84;
            8'h50:  out <= 8'h53;
            8'h51:  out <= 8'hd1;
            8'h52:  out <= 8'h00;
            8'h53:  out <= 8'hed;
            8'h54:  out <= 8'h20;
            8'h55:  out <= 8'hfc;
            8'h56:  out <= 8'hb1;
            8'h57:  out <= 8'h5b;
            8'h58:  out <= 8'h6a;
            8'h59:  out <= 8'hcb;
            8'h5a:  out <= 8'hbe;
            8'h5b:  out <= 8'h39;
            8'h5c:  out <= 8'h4a;
            8'h5d:  out <= 8'h4c;
            8'h5e:  out <= 8'h58;
            8'h5f:  out <= 8'hcf;
            8'h60:  out <= 8'hd0;
            8'h61:  out <= 8'hef;
            8'h62:  out <= 8'haa;
            8'h63:  out <= 8'hfb;
            8'h64:  out <= 8'h43;
            8'h65:  out <= 8'h4d;
            8'h66:  out <= 8'h33;
            8'h67:  out <= 8'h85;
            8'h68:  out <= 8'h45;
            8'h69:  out <= 8'hf9;
            8'h6a:  out <= 8'h02;
            8'h6b:  out <= 8'h7f;
            8'h6c:  out <= 8'h50;
            8'h6d:  out <= 8'h3c;
            8'h6e:  out <= 8'h9f;
            8'h6f:  out <= 8'ha8;
            8'h70:  out <= 8'h51;
            8'h71:  out <= 8'ha3;
            8'h72:  out <= 8'h40;
            8'h73:  out <= 8'h8f;
            8'h74:  out <= 8'h92;
            8'h75:  out <= 8'h9d;
            8'h76:  out <= 8'h38;
            8'h77:  out <= 8'hf5;
            8'h78:  out <= 8'hbc;
            8'h79:  out <= 8'hb6;
            8'h7a:  out <= 8'hda;
            8'h7b:  out <= 8'h21;
            8'h7c:  out <= 8'h10;
            8'h7d:  out <= 8'hff;
            8'h7e:  out <= 8'hf3;
            8'h7f:  out <= 8'hd2;
            8'h80:  out <= 8'hcd;
            8'h81:  out <= 8'h0c;
            8'h82:  out <= 8'h13;
            8'h83:  out <= 8'hec;
            8'h84:  out <= 8'h5f;
            8'h85:  out <= 8'h97;
            8'h86:  out <= 8'h44;
            8'h87:  out <= 8'h17;
            8'h88:  out <= 8'hc4;
            8'h89:  out <= 8'ha7;
            8'h8a:  out <= 8'h7e;
            8'h8b:  out <= 8'h3d;
            8'h8c:  out <= 8'h64;
            8'h8d:  out <= 8'h5d;
            8'h8e:  out <= 8'h19;
            8'h8f:  out <= 8'h73;
            8'h90:  out <= 8'h60;
            8'h91:  out <= 8'h81;
            8'h92:  out <= 8'h4f;
            8'h93:  out <= 8'hdc;
            8'h94:  out <= 8'h22;
            8'h95:  out <= 8'h2a;
            8'h96:  out <= 8'h90;
            8'h97:  out <= 8'h88;
            8'h98:  out <= 8'h46;
            8'h99:  out <= 8'hee;
            8'h9a:  out <= 8'hb8;
            8'h9b:  out <= 8'h14;
            8'h9c:  out <= 8'hde;
            8'h9d:  out <= 8'h5e;
            8'h9e:  out <= 8'h0b;
            8'h9f:  out <= 8'hdb;
            8'ha0:  out <= 8'he0;
            8'ha1:  out <= 8'h32;
            8'ha2:  out <= 8'h3a;
            8'ha3:  out <= 8'h0a;
            8'ha4:  out <= 8'h49;
            8'ha5:  out <= 8'h06;
            8'ha6:  out <= 8'h24;
            8'ha7:  out <= 8'h5c;
            8'ha8:  out <= 8'hc2;
            8'ha9:  out <= 8'hd3;
            8'haa:  out <= 8'hac;
            8'hab:  out <= 8'h62;
            8'hac:  out <= 8'h91;
            8'had:  out <= 8'h95;
            8'hae:  out <= 8'he4;
            8'haf:  out <= 8'h79;
            8'hb0:  out <= 8'he7;
            8'hb1:  out <= 8'hc8;
            8'hb2:  out <= 8'h37;
            8'hb3:  out <= 8'h6d;
            8'hb4:  out <= 8'h8d;
            8'hb5:  out <= 8'hd5;
            8'hb6:  out <= 8'h4e;
            8'hb7:  out <= 8'ha9;
            8'hb8:  out <= 8'h6c;
            8'hb9:  out <= 8'h56;
            8'hba:  out <= 8'hf4;
            8'hbb:  out <= 8'hea;
            8'hbc:  out <= 8'h65;
            8'hbd:  out <= 8'h7a;
            8'hbe:  out <= 8'hae;
            8'hbf:  out <= 8'h08;
            8'hc0:  out <= 8'hba;
            8'hc1:  out <= 8'h78;
            8'hc2:  out <= 8'h25;
            8'hc3:  out <= 8'h2e;
            8'hc4:  out <= 8'h1c;
            8'hc5:  out <= 8'ha6;
            8'hc6:  out <= 8'hb4;
            8'hc7:  out <= 8'hc6;
            8'hc8:  out <= 8'he8;
            8'hc9:  out <= 8'hdd;
            8'hca:  out <= 8'h74;
            8'hcb:  out <= 8'h1f;
            8'hcc:  out <= 8'h4b;
            8'hcd:  out <= 8'hbd;
            8'hce:  out <= 8'h8b;
            8'hcf:  out <= 8'h8a;
            8'hd0:  out <= 8'h70;
            8'hd1:  out <= 8'h3e;
            8'hd2:  out <= 8'hb5;
            8'hd3:  out <= 8'h66;
            8'hd4:  out <= 8'h48;
            8'hd5:  out <= 8'h03;
            8'hd6:  out <= 8'hf6;
            8'hd7:  out <= 8'h0e;
            8'hd8:  out <= 8'h61;
            8'hd9:  out <= 8'h35;
            8'hda:  out <= 8'h57;
            8'hdb:  out <= 8'hb9;
            8'hdc:  out <= 8'h86;
            8'hdd:  out <= 8'hc1;
            8'hde:  out <= 8'h1d;
            8'hdf:  out <= 8'h9e;
            8'he0:  out <= 8'he1;
            8'he1:  out <= 8'hf8;
            8'he2:  out <= 8'h98;
            8'he3:  out <= 8'h11;
            8'he4:  out <= 8'h69;
            8'he5:  out <= 8'hd9;
            8'he6:  out <= 8'h8e;
            8'he7:  out <= 8'h94;
            8'he8:  out <= 8'h9b;
            8'he9:  out <= 8'h1e;
            8'hea:  out <= 8'h87;
            8'heb:  out <= 8'he9;
            8'hec:  out <= 8'hce;
            8'hed:  out <= 8'h55;
            8'hee:  out <= 8'h28;
            8'hef:  out <= 8'hdf;
            8'hf0:  out <= 8'h8c;
            8'hf1:  out <= 8'ha1;
            8'hf2:  out <= 8'h89;
            8'hf3:  out <= 8'h0d;
            8'hf4:  out <= 8'hbf;
            8'hf5:  out <= 8'he6;
            8'hf6:  out <= 8'h42;
            8'hf7:  out <= 8'h68;
            8'hf8:  out <= 8'h41;
            8'hf9:  out <= 8'h99;
            8'hfa:  out <= 8'h2d;
            8'hfb:  out <= 8'h0f;
            8'hfc:  out <= 8'hb0;
            8'hfd:  out <= 8'h54;
            8'hfe:  out <= 8'hbb;
            8'hff:  out <= 8'h16;
        endcase
endmodule

/* S box * x */
module xS (clk, rst, in, out);
    input clk;
    input rst;
    input [7:0] in;
    output reg [7:0] out;

    always @ (posedge clk)
        if (rst)
            out <= 8'd0;
        else
            case (in)
            8'h00:  out <= 8'hc6;
            8'h01:  out <= 8'hf8;
            8'h02:  out <= 8'hee;
            8'h03:  out <= 8'hf6;
            8'h04:  out <= 8'hff;
            8'h05:  out <= 8'hd6;
            8'h06:  out <= 8'hde;
            8'h07:  out <= 8'h91;
            8'h08:  out <= 8'h60;
            8'h09:  out <= 8'h02;
            8'h0a:  out <= 8'hce;
            8'h0b:  out <= 8'h56;
            8'h0c:  out <= 8'he7;
            8'h0d:  out <= 8'hb5;
            8'h0e:  out <= 8'h4d;
            8'h0f:  out <= 8'hec;
            8'h10:  out <= 8'h8f;
            8'h11:  out <= 8'h1f;
            8'h12:  out <= 8'h89;
            8'h13:  out <= 8'hfa;
            8'h14:  out <= 8'hef;
            8'h15:  out <= 8'hb2;
            8'h16:  out <= 8'h8e;
            8'h17:  out <= 8'hfb;
            8'h18:  out <= 8'h41;
            8'h19:  out <= 8'hb3;
            8'h1a:  out <= 8'h5f;
            8'h1b:  out <= 8'h45;
            8'h1c:  out <= 8'h23;
            8'h1d:  out <= 8'h53;
            8'h1e:  out <= 8'he4;
            8'h1f:  out <= 8'h9b;
            8'h20:  out <= 8'h75;
            8'h21:  out <= 8'he1;
            8'h22:  out <= 8'h3d;
            8'h23:  out <= 8'h4c;
            8'h24:  out <= 8'h6c;
            8'h25:  out <= 8'h7e;
            8'h26:  out <= 8'hf5;
            8'h27:  out <= 8'h83;
            8'h28:  out <= 8'h68;
            8'h29:  out <= 8'h51;
            8'h2a:  out <= 8'hd1;
            8'h2b:  out <= 8'hf9;
            8'h2c:  out <= 8'he2;
            8'h2d:  out <= 8'hab;
            8'h2e:  out <= 8'h62;
            8'h2f:  out <= 8'h2a;
            8'h30:  out <= 8'h08;
            8'h31:  out <= 8'h95;
            8'h32:  out <= 8'h46;
            8'h33:  out <= 8'h9d;
            8'h34:  out <= 8'h30;
            8'h35:  out <= 8'h37;
            8'h36:  out <= 8'h0a;
            8'h37:  out <= 8'h2f;
            8'h38:  out <= 8'h0e;
            8'h39:  out <= 8'h24;
            8'h3a:  out <= 8'h1b;
            8'h3b:  out <= 8'hdf;
            8'h3c:  out <= 8'hcd;
            8'h3d:  out <= 8'h4e;
            8'h3e:  out <= 8'h7f;
            8'h3f:  out <= 8'hea;
            8'h40:  out <= 8'h12;
            8'h41:  out <= 8'h1d;
            8'h42:  out <= 8'h58;
            8'h43:  out <= 8'h34;
            8'h44:  out <= 8'h36;
            8'h45:  out <= 8'hdc;
            8'h46:  out <= 8'hb4;
            8'h47:  out <= 8'h5b;
            8'h48:  out <= 8'ha4;
            8'h49:  out <= 8'h76;
            8'h4a:  out <= 8'hb7;
            8'h4b:  out <= 8'h7d;
            8'h4c:  out <= 8'h52;
            8'h4d:  out <= 8'hdd;
            8'h4e:  out <= 8'h5e;
            8'h4f:  out <= 8'h13;
            8'h50:  out <= 8'ha6;
            8'h51:  out <= 8'hb9;
            8'h52:  out <= 8'h00;
            8'h53:  out <= 8'hc1;
            8'h54:  out <= 8'h40;
            8'h55:  out <= 8'he3;
            8'h56:  out <= 8'h79;
            8'h57:  out <= 8'hb6;
            8'h58:  out <= 8'hd4;
            8'h59:  out <= 8'h8d;
            8'h5a:  out <= 8'h67;
            8'h5b:  out <= 8'h72;
            8'h5c:  out <= 8'h94;
            8'h5d:  out <= 8'h98;
            8'h5e:  out <= 8'hb0;
            8'h5f:  out <= 8'h85;
            8'h60:  out <= 8'hbb;
            8'h61:  out <= 8'hc5;
            8'h62:  out <= 8'h4f;
            8'h63:  out <= 8'hed;
            8'h64:  out <= 8'h86;
            8'h65:  out <= 8'h9a;
            8'h66:  out <= 8'h66;
            8'h67:  out <= 8'h11;
            8'h68:  out <= 8'h8a;
            8'h69:  out <= 8'he9;
            8'h6a:  out <= 8'h04;
            8'h6b:  out <= 8'hfe;
            8'h6c:  out <= 8'ha0;
            8'h6d:  out <= 8'h78;
            8'h6e:  out <= 8'h25;
            8'h6f:  out <= 8'h4b;
            8'h70:  out <= 8'ha2;
            8'h71:  out <= 8'h5d;
            8'h72:  out <= 8'h80;
            8'h73:  out <= 8'h05;
            8'h74:  out <= 8'h3f;
            8'h75:  out <= 8'h21;
            8'h76:  out <= 8'h70;
            8'h77:  out <= 8'hf1;
            8'h78:  out <= 8'h63;
            8'h79:  out <= 8'h77;
            8'h7a:  out <= 8'haf;
            8'h7b:  out <= 8'h42;
            8'h7c:  out <= 8'h20;
            8'h7d:  out <= 8'he5;
            8'h7e:  out <= 8'hfd;
            8'h7f:  out <= 8'hbf;
            8'h80:  out <= 8'h81;
            8'h81:  out <= 8'h18;
            8'h82:  out <= 8'h26;
            8'h83:  out <= 8'hc3;
            8'h84:  out <= 8'hbe;
            8'h85:  out <= 8'h35;
            8'h86:  out <= 8'h88;
            8'h87:  out <= 8'h2e;
            8'h88:  out <= 8'h93;
            8'h89:  out <= 8'h55;
            8'h8a:  out <= 8'hfc;
            8'h8b:  out <= 8'h7a;
            8'h8c:  out <= 8'hc8;
            8'h8d:  out <= 8'hba;
            8'h8e:  out <= 8'h32;
            8'h8f:  out <= 8'he6;
            8'h90:  out <= 8'hc0;
            8'h91:  out <= 8'h19;
            8'h92:  out <= 8'h9e;
            8'h93:  out <= 8'ha3;
            8'h94:  out <= 8'h44;
            8'h95:  out <= 8'h54;
            8'h96:  out <= 8'h3b;
            8'h97:  out <= 8'h0b;
            8'h98:  out <= 8'h8c;
            8'h99:  out <= 8'hc7;
            8'h9a:  out <= 8'h6b;
            8'h9b:  out <= 8'h28;
            8'h9c:  out <= 8'ha7;
            8'h9d:  out <= 8'hbc;
            8'h9e:  out <= 8'h16;
            8'h9f:  out <= 8'had;
            8'ha0:  out <= 8'hdb;
            8'ha1:  out <= 8'h64;
            8'ha2:  out <= 8'h74;
            8'ha3:  out <= 8'h14;
            8'ha4:  out <= 8'h92;
            8'ha5:  out <= 8'h0c;
            8'ha6:  out <= 8'h48;
            8'ha7:  out <= 8'hb8;
            8'ha8:  out <= 8'h9f;
            8'ha9:  out <= 8'hbd;
            8'haa:  out <= 8'h43;
            8'hab:  out <= 8'hc4;
            8'hac:  out <= 8'h39;
            8'had:  out <= 8'h31;
            8'hae:  out <= 8'hd3;
            8'haf:  out <= 8'hf2;
            8'hb0:  out <= 8'hd5;
            8'hb1:  out <= 8'h8b;
            8'hb2:  out <= 8'h6e;
            8'hb3:  out <= 8'hda;
            8'hb4:  out <= 8'h01;
            8'hb5:  out <= 8'hb1;
            8'hb6:  out <= 8'h9c;
            8'hb7:  out <= 8'h49;
            8'hb8:  out <= 8'hd8;
            8'hb9:  out <= 8'hac;
            8'hba:  out <= 8'hf3;
            8'hbb:  out <= 8'hcf;
            8'hbc:  out <= 8'hca;
            8'hbd:  out <= 8'hf4;
            8'hbe:  out <= 8'h47;
            8'hbf:  out <= 8'h10;
            8'hc0:  out <= 8'h6f;
            8'hc1:  out <= 8'hf0;
            8'hc2:  out <= 8'h4a;
            8'hc3:  out <= 8'h5c;
            8'hc4:  out <= 8'h38;
            8'hc5:  out <= 8'h57;
            8'hc6:  out <= 8'h73;
            8'hc7:  out <= 8'h97;
            8'hc8:  out <= 8'hcb;
            8'hc9:  out <= 8'ha1;
            8'hca:  out <= 8'he8;
            8'hcb:  out <= 8'h3e;
            8'hcc:  out <= 8'h96;
            8'hcd:  out <= 8'h61;
            8'hce:  out <= 8'h0d;
            8'hcf:  out <= 8'h0f;
            8'hd0:  out <= 8'he0;
            8'hd1:  out <= 8'h7c;
            8'hd2:  out <= 8'h71;
            8'hd3:  out <= 8'hcc;
            8'hd4:  out <= 8'h90;
            8'hd5:  out <= 8'h06;
            8'hd6:  out <= 8'hf7;
            8'hd7:  out <= 8'h1c;
            8'hd8:  out <= 8'hc2;
            8'hd9:  out <= 8'h6a;
            8'hda:  out <= 8'hae;
            8'hdb:  out <= 8'h69;
            8'hdc:  out <= 8'h17;
            8'hdd:  out <= 8'h99;
            8'hde:  out <= 8'h3a;
            8'hdf:  out <= 8'h27;
            8'he0:  out <= 8'hd9;
            8'he1:  out <= 8'heb;
            8'he2:  out <= 8'h2b;
            8'he3:  out <= 8'h22;
            8'he4:  out <= 8'hd2;
            8'he5:  out <= 8'ha9;
            8'he6:  out <= 8'h07;
            8'he7:  out <= 8'h33;
            8'he8:  out <= 8'h2d;
            8'he9:  out <= 8'h3c;
            8'hea:  out <= 8'h15;
            8'heb:  out <= 8'hc9;
            8'hec:  out <= 8'h87;
            8'hed:  out <= 8'haa;
            8'hee:  out <= 8'h50;
            8'hef:  out <= 8'ha5;
            8'hf0:  out <= 8'h03;
            8'hf1:  out <= 8'h59;
            8'hf2:  out <= 8'h09;
            8'hf3:  out <= 8'h1a;
            8'hf4:  out <= 8'h65;
            8'hf5:  out <= 8'hd7;
            8'hf6:  out <= 8'h84;
            8'hf7:  out <= 8'hd0;
            8'hf8:  out <= 8'h82;
            8'hf9:  out <= 8'h29;
            8'hfa:  out <= 8'h5a;
            8'hfb:  out <= 8'h1e;
            8'hfc:  out <= 8'h7b;
            8'hfd:  out <= 8'ha8;
            8'hfe:  out <= 8'h6d;
            8'hff:  out <= 8'h2c;
        endcase
endmodule
