// Author: Pin-Hua Lai, Heng-Jun Hong

module Decoder(
    instr_op_i,
    RegWrite_o,
    ALU_op_o,
    ALUSrc_o,
    RegDst_o,
    Branch_o
    );

//I/O ports
input  [6-1:0] instr_op_i;

output         RegWrite_o;
output [3-1:0] ALU_op_o;
output         ALUSrc_o;
output         RegDst_o;
output         Branch_o;

//Internal Signals
// reg    [3-1:0] ALU_op_o;
// reg            ALUSrc_o;
// reg            RegWrite_o;
// reg            RegDst_o;
// reg            Branch_o;
assign RegWrite_o = (instr_op_i == 0 || instr_op_i == 8 || instr_op_i == 11 || instr_op_i == 15 || instr_op_i == 13);
assign ALU_op_o = (instr_op_i == 4 ? 3'b011 : // BEQ -> SUB
                  (instr_op_i == 5 ? 3'b011 : // BNE -> SUB
                  (instr_op_i == 8 ? 3'b010 : // ADDI -> ADD
                  (instr_op_i == 11 ? 3'b100 : // SLTIU -> SLTIU
                  (instr_op_i == 13 ? 3'b001 : // ORI -> OR
                  (instr_op_i == 15 ? 3'b110 : // LUI -> LUI
                  3'b111))))));
assign ALUSrc_o = (instr_op_i == 8 || instr_op_i == 11 || instr_op_i == 15 || instr_op_i == 13);
assign RegDst_o = (instr_op_i == 0);
assign Branch_o = (instr_op_i == 4 || instr_op_i == 5);


endmodule
