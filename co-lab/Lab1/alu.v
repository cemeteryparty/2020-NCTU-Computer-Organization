`timescale 1ns/1ps
// Pin-Hua Lai 0716085
module alu(
    rst_n,          // negative reset            (input)
    src1,           // 32 bits source 1          (input)
    src2,           // 32 bits source 2          (input)
    ALU_control,    // 4 bits ALU control input  (input)
    //bonus_control   // 3 bits bonus control input(input) 
    result,         // 32 bits result            (output)
    zero,           // 1 bit when the output is 0, zero must be set (output)
    cout,           // 1 bit carry out           (output)
    overflow        // 1 bit overflow            (output)
    );

input rst_n;
input [32-1:0] src1;
input [32-1:0] src2;
input [4-1:0] ALU_control;
//input [3-1:0] bonus_control; 

output [32-1:0] result;
output zero;
output cout;
output overflow;

wire [32:0] cin;
wire A_invert,B_invert;
wire [1:0]  operation;
// name  symbol  code   ai bi c0 // comment
// AND   a & b   0000   a  b  0  //
// OR    a | b   0001   a  b  0  //
// ADD   a + b   0010   a  b  0  // s = a^b^ci, ci+1 = (a&b)|(c&(a^b))
// SUB   a - b   0110   a  b' 1  // s = a+b'+1
// NOR  (a | b)' 1100   a' b' 0  // a' & b'
// NAND (a & b)' 1101   a' b' 0  // a' | b'
// SLT   a-b<0?  0111   a  b' 1  //
//               3210    

assign cin[0] = (ALU_control == 4'b0110 || ALU_control == 4'b0111);
assign A_invert = ALU_control[3];
assign B_invert = ALU_control[2];
assign operation[1] = ALU_control[1];
assign operation[0] = ALU_control[0];

assign zero = (result == 32'b0); // (res0 | res1 | ... | res31)'
assign cout = (ALU_control == 4'b0010 || ALU_control == 4'b0110) & cin[32];
assign overflow = (ALU_control == 4'b0010 || ALU_control == 4'b0110) & (cin[32] ^ cin[31]); // v = c31 ^ c32 v?overflow:no_overflow 
alu_top alu_top0(
    .src1(src1[0]),
    .src2(src2[0]),
    .less((src1[31] ^ ~src2[31] ^ cin[31]) | overflow), // less[0] = sub[31] | overflow
    .A_invert(A_invert),
    .B_invert(B_invert),
    .cin(cin[0]),
    .operation(operation),
    .result(result[0]),
    .cout(cin[1])
);
genvar i;
generate
    for (i = 1;i < 32;i = i + 1) begin
        alu_top alu_topi(
            .src1(src1[i]),
            .src2(src2[i]),
            .less(1'b0),
            .A_invert(A_invert),
            .B_invert(B_invert),
            .cin(cin[i]),
            .operation(operation),
            .result(result[i]),
            .cout(cin[i + 1])
        );
    end
endgenerate

endmodule
