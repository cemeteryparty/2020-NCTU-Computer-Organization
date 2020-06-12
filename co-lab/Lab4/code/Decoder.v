// Author: 0716316洪珩鈞, 0716085賴品樺

module Decoder(
    instr_op,
    RegWrite,
    MemToReg,
    MemRead,
    MemWrite,
    ALU_op,
    ALUSrc,
    RegDst,
    Branch,
    BranchType,
    Jump
    );

//I/O ports
input  [6-1:0] instr_op;

output         RegWrite;
output         MemToReg;
output         MemRead;
output         MemWrite;
output [3-1:0] ALU_op;
output         ALUSrc;
output         RegDst;
output         Branch;
output [2-1:0] BranchType;
output         Jump;


//Internal Signals
assign RegWrite = (instr_op == 0 || instr_op == 8 || instr_op == 11 || instr_op == 13 || instr_op == 15 || instr_op == 35 || instr_op == 3);
assign MemToReg = (instr_op == 35) ? 1 : 0;
assign MemRead = (instr_op == 35) ? 1 : 0;
assign MemWrite = (instr_op == 43) ? 1 : 0;
assign ALU_op = (instr_op == 4 ? 3'b011 : // BEQ -> SUB
                (instr_op == 5 ? 3'b011 : // BNE -> SUB
                (instr_op == 6 ? 3'b011 : // BLEZ -> SUB
                (instr_op == 7 ? 3'b011 : // BGTZ -> SUB
                (instr_op == 8 ? 3'b010 : // ADDI -> ADD
                (instr_op == 11 ? 3'b100 : // SLTIU -> SLTIU
                (instr_op == 13 ? 3'b001 : // ORI -> OR
                (instr_op == 15 ? 3'b110 : // LUI -> LUI
                (instr_op == 35 ? 3'b010 : // LW -> ADD
                (instr_op == 43 ? 3'b010 : // SW -> ADD
                3'b111))))))))));
assign ALUSrc = (instr_op == 8 || instr_op == 11 || instr_op == 15 || instr_op == 13 || instr_op == 43 || instr_op == 35);
assign RegDst = (instr_op == 0);
assign Branch = (instr_op == 4 || instr_op == 5 || instr_op == 6 || instr_op == 7);
assign BranchType = (instr_op == 4 ? 2'b00 : // BEQ
                    (instr_op == 5 ? 2'b01 : // BNE
                    (instr_op == 6 ? 2'b10 : // BLEZ
                    2'b11)));                // BGTZ
assign Jump = (instr_op == 2 || instr_op == 3);


endmodule
