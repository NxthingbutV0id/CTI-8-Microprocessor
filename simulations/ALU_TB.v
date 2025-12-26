`timescale 1ns/1ps

module alu_tb_min;
  reg  [7:0] A, B;
  reg        carryIn, halfCarry, outputEnable;
  reg  [3:0] opcode;
  wire [7:0] result;
  wire       C, V, H;
  
  localparam ALU_ADD  = 4'h0;
  localparam ALU_SUB  = 4'h1;
  localparam ALU_AND  = 4'h2;
  localparam ALU_OR   = 4'h3;
  localparam ALU_XOR  = 4'h4;
  localparam ALU_ROL1 = 4'h5;
  localparam ALU_ROR1 = 4'h6; 
  localparam ALU_CLRB = 4'h7;
  localparam ALU_SETB = 4'h8;
  localparam ALU_INC  = 4'h9;
  localparam ALU_DEC  = 4'hA;
  localparam ALU_NOT  = 4'hB;
  localparam ALU_DAAP = 4'hC;
  localparam ALU_DAAS = 4'hD;

  ALU dut (
    .A(A), .B(B),
    .carryIn(carryIn),
    .halfCarry(halfCarry),
    .opcode(opcode),
    .outputEnable(outputEnable),
    .result(result),
    .C(C), .V(V), .H(H)
  );

  function [8:0] add9; input [7:0] x, y; input cin; begin add9 = x + y + cin; end endfunction
  function halfcarry_add; input [7:0] x, y; input cin; reg [4:0] t; begin t = {1'b0, x[3:0]} + {1'b0, y[3:0]} + cin; halfcarry_add = t[4]; end endfunction
  function ovf_add; input [7:0] a, b, r; begin ovf_add = (~(a[7]^b[7]) & (a[7]^r[7])); end endfunction
  function ovf_sub; input [7:0] a, b, r; begin ovf_sub = ((a[7]^b[7]) & (a[7]^r[7])); end endfunction

  task daa_add; input  [7:0] a_in; input carry_in, halfcarry_in; output [7:0] a_out; output c_out, h_out;
    reg   [8:0]  tmp;
    reg          c;
    begin
      tmp = {1'b0, a_in};
      c   = carry_in;
      if (halfcarry_in || (a_in[3:0] > 4'd9))
        tmp = tmp + 9'h006; // +0x06
      if (c || (tmp[7:0] > 8'h99)) begin
        tmp = tmp + 9'h060; // +0x60
        c   = 1'b1;
      end
      a_out = tmp[7:0];
      c_out = c;
      h_out = 1'b0;
    end
  endtask

  task daa_sub; input [7:0] a_in; input carry_in, halfcarry_in; output [7:0] a_out; output c_out, h_out;
    reg   [8:0]  tmp;
    reg          c;
    begin
      tmp = {1'b0, a_in};
      c   = carry_in;
      if (halfcarry_in || (a_in[3:0] > 4'd9))
        tmp = tmp - 9'h006; // -0x06
      if (c || (a_in > 8'h99)) begin
        tmp = tmp - 9'h060; // -0x60
        c   = 1'b1;
      end
      a_out = tmp[7:0];
      c_out = c;
      h_out = 1'b0;
    end
  endtask

  task model_alu; input [3:0] op; input [7:0] a, b; input cin, hcin; output [7:0] r; output cflag, vflag, hflag;
    reg   [8:0]  s9;
    reg   [7:0]  t;
    begin
      r = 8'h00; cflag = 1'b0; vflag = 1'b0; hflag = 1'b0;
      case (op)
        ALU_ADD: begin
          s9    = add9(a, b, cin);
          r     = s9[7:0];
          cflag = s9[8];
          hflag = halfcarry_add(a, b, cin);
          vflag = ovf_add(a, b, r);
        end
        ALU_SUB: begin
          s9    = add9(a, ~b, cin);   // carryIn=1 -> no borrow (6502-style)
          r     = s9[7:0];
          cflag = s9[8];
          hflag = halfcarry_add(a, ~b, cin);
          vflag = ovf_sub(a, b, r);
        end
        ALU_AND: begin r = a & b; end
        ALU_OR : begin r = a | b; end
        ALU_XOR: begin r = a ^ b; end
        ALU_ROL1: begin r = {a[6:0], cin}; cflag = a[7]; end
        ALU_ROR1: begin r = {cin, a[7:1]}; cflag = a[0]; end
        ALU_CLRB: begin r = a & ~(8'h01 << b[2:0]); end
        ALU_SETB: begin r = a |  (8'h01 << b[2:0]); end
        ALU_INC : begin
          r     = a + 8'd1;
          cflag = (a == 8'hFF);            // tweak if your RTL differs
          hflag = ((a[3:0] + 4'd1) > 4'hF);
          vflag = (a == 8'h7F);
        end
        ALU_DEC : begin
          r     = a - 8'd1;
          cflag = (a != 8'h00);            // tweak if your RTL differs
          hflag = (a[3:0] != 4'h0);
          vflag = (a == 8'h80);
        end
        ALU_NOT : begin r = ~a; end
        ALU_DAAP: begin daa_add(a, cin, hcin, r, cflag, hflag); end
        ALU_DAAS: begin daa_sub(a, cin, hcin, r, cflag, hflag); end
        default : begin r = 8'h00; cflag = 1'b0; vflag = 1'b0; hflag = 1'b0; end
      endcase
    end
  endtask

  task apply_and_check;
    input [3:0] op;
    input [7:0] a, b;
    input       cin, hcin;
    input [31:0] tag;   // just for printing an id
    reg   [7:0] exp_r;
    reg         exp_c, exp_v, exp_h;
    begin
      opcode       = op;
      A            = a;
      B            = b;
      carryIn      = cin;
      halfCarry    = hcin;
      outputEnable = 1'b1;
      #1; // combinational settle
      model_alu(op, a, b, cin, hcin, exp_r, exp_c, exp_v, exp_h);
      if (result!==exp_r || C!==exp_c || V!==exp_v || H!==exp_h) begin
        $display("FAIL tag=%0d  op=%0h  A=%02h B=%02h cin=%0d hcin=%0d  got R=%02h C=%0d V=%0d H=%0d  exp R=%02h C=%0d V=%0d H=%0d",
          tag, op, a, b, cin, hcin, result, C, V, H, exp_r, exp_c, exp_v, exp_h);
        $stop;
      end else begin
        $display("PASS tag=%0d  op=%0h  A=%02h B=%02h cin=%0d hcin=%0d  R=%02h C=%0d V=%0d H=%0d",
          tag, op, a, b, cin, hcin, result, C, V, H);
      end
    end
  endtask
  integer i;
  initial begin
    apply_and_check(ALU_ADD , 8'h00, 8'h00, 1'b0, 1'b0,  1);
    apply_and_check(ALU_ADD , 8'hFF, 8'h01, 1'b0, 1'b0,  2);
    apply_and_check(ALU_ADD , 8'h7F, 8'h01, 1'b0, 1'b0,  3);
    apply_and_check(ALU_SUB , 8'h00, 8'h01, 1'b0, 1'b0,  4);
    apply_and_check(ALU_SUB , 8'h80, 8'h01, 1'b1, 1'b0,  5);
    apply_and_check(ALU_AND , 8'hAA, 8'h0F, 1'b0, 1'b0,  6);
    apply_and_check(ALU_OR  , 8'hA0, 8'h0F, 1'b0, 1'b0,  7);
    apply_and_check(ALU_XOR , 8'hF0, 8'h0F, 1'b0, 1'b0,  8);
    apply_and_check(ALU_ROL1, 8'h81, 8'h00, 1'b1, 1'b0,  9);
    apply_and_check(ALU_ROR1, 8'h81, 8'h00, 1'b0, 1'b0, 10);
    apply_and_check(ALU_CLRB, 8'hFF, 8'd3 , 1'b0, 1'b0, 11);
    apply_and_check(ALU_SETB, 8'h00, 8'd6 , 1'b0, 1'b0, 12);
    apply_and_check(ALU_INC , 8'hFF, 8'h00, 1'b0, 1'b0, 13);
    apply_and_check(ALU_DEC , 8'h00, 8'h00, 1'b0, 1'b0, 14);
    apply_and_check(ALU_DAAP, (8'h09 + 8'h01), 8'h00, 1'b0, 1'b1, 15);
    apply_and_check(ALU_DAAP, (8'h19 + 8'h09), 8'h00, 1'b0, 1'b1, 16);
    apply_and_check(ALU_DAAS, (8'h10 - 8'h01), 8'h00, 1'b1, 1'b1, 17);
    for (i=0; i<200; i=i+1) begin
      apply_and_check(ALU_ADD , $random, $random, $random & 1, 1'b0, 100+i);
      apply_and_check(ALU_SUB , $random, $random, $random & 1, 1'b0, 200+i);
      apply_and_check(ALU_XOR , $random, $random, 1'b0,      1'b0, 300+i);
      apply_and_check(ALU_ROL1, $random, 8'h00,   $random & 1, 1'b0, 400+i);
      apply_and_check(ALU_ROR1, $random, 8'h00,   $random & 1, 1'b0, 500+i);
    end
    $display("ALL TESTS PASSED");
    $finish;
  end
endmodule
