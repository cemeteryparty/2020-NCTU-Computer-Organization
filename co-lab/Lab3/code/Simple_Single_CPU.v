// Author: 0716085賴品樺, 0716316洪珩均

module Simple_Single_CPU(
    clk_i,
    rst_i
    );

// Input port
input clk_i;
input rst_i;

wire [32-1:0] addr_n;  // next address, from before
wire [32-1:0] addr;    // present address
wire [32-1:0] addr_n1; // address + 4
wire [32-1:0] addr_sh; // TARGET * 4
wire [32-1:0] addr_n2; // addr_n1 + addr_sh
wire [32-1:0] addr_shj; // instr[25:0] * 4, instr[25:0] => [27:0] // simplify, using 32-bit
wire [32-1:0] addr_nj; // addr_n1[31:28]###addr_shj[27:0] 
wire [32-1:0] addr_nr; // regular address, no jump
wire [32-1:0] addr_jor; // address from jump or regular

wire [32-1:0] instr;   // Instruction
// decoder output (control) 
wire         RegWrite;  
wire         MemToReg;
wire         MemRead;
wire         MemWrite;
wire [3-1:0] ALUOp;
wire         ALUSrc;
wire         RegDst;
wire         Branch;
wire         BranchType;
wire         Jump;
// ALU control output
wire [4-1:0]  ALUCtrl;
wire          JumpReg;
wire          Shamt;

wire          Zero;
wire          GetBranch; // Branch result checking

wire [5-1:0]  reg_write;
wire [32-1:0] reg_rs_out;
wire [32-1:0] reg_rt_out;
wire [32-1:0] alu_src0;
wire [32-1:0] alu_src;
wire [32-1:0] data_ext; // extend data
wire [32-1:0] alu_res;  // ALU result
wire [32-1:0] DM_out;
wire [32-1:0] WriteData; // data write back to reg

ProgramCounter PC(
    .clk_i(clk_i),
    .rst_i (rst_i),
    .pc_in_i(addr_n),
    .pc_out_o(addr)
    );

Instr_Memory IM(
    .pc_addr_i(addr),
    .instr_o(instr)
    );

MUX_2to1 #(.size(5)) Mux_Write_Reg( // RD
    .data0_i(instr[20:16]),
    .data1_i(instr[15:11]),
    .select_i(RegDst),
    .data_o(reg_write)
    );

Reg_File RF(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .RSaddr_i(instr[25:21]), // rs
    .RTaddr_i(instr[20:16]), // rt
    .RDaddr_i(reg_write), // rd  
    .RDdata_i(WriteData),  // 
    .RegWrite_i(RegWrite),
    .RSdata_o(reg_rs_out), // rs out
    .RTdata_o(reg_rt_out)  //rt out
    );

Decoder Decoder(
    .instr_op(instr[31:26]),
    .RegWrite(RegWrite),
    .MemToReg(MemToReg), // DM
    .MemRead(MemRead), // DM
    .MemWrite(MemWrite), //DM
    .ALU_op(ALUOp),
    .ALUSrc(ALUSrc),
    .RegDst(RegDst),
    .Branch(Branch), // branch redirect PC
    .BranchType(BranchType), // branch redirect PC
    .Jump(Jump) // j-type redirect PC
    );

ALU_Ctrl AC(
    .funct_i(instr[5:0]),
    .ALUOp_i(ALUOp),
    .ALUCtrl_o(ALUCtrl),
    .JumpReg(JumpReg), // jr redirect PC
    .Shamt(Shamt) // determine alu_src0 from reg_rs_out or instr[10:6](shamt)
    );

Sign_Extend SE(
    .data_i(instr[15:0]),
    .data_o(data_ext)
    );

MUX_2to1 #(.size(32)) Mux_ALUSrc( // ALUSrc
    .data0_i(reg_rt_out), //rt out
    .data1_i(data_ext), // extend
    .select_i(ALUSrc),
    .data_o(alu_src)
    );
assign alu_src0 = (Shamt == 1'b0)?reg_rs_out:{17'b00000000000000000, instr[10:6]}; // MUX(rt:shamt)
ALU ALU(
    .src1_i(alu_src0),
    .src2_i(alu_src),
    .ctrl_i(ALUCtrl),
    .result_o(alu_res),
    .zero_o(Zero)
    );

Data_Memory Data_Memory(
    .clk_i(clk_i),
    .addr_i(alu_res),
    .data_i(reg_rt_out),
    .MemRead_i(MemRead),
    .MemWrite_i(MemWrite),
    .data_o(DM_out)
);
assign WriteData = MemToReg?DM_out:alu_res;

Adder Adder1( // address + 4
    .src1_i(addr),
    .src2_i(4),
    .sum_o(addr_n1)
    );
Adder Adder2( // addr_n1 + addr_sh
    .src1_i(addr_n1),
    .src2_i(addr_sh),
    .sum_o(addr_n2)
    );

Shift_Left_Two_32 Shifterb( // branch shifter
    .data_i(data_ext),
    .data_o(addr_sh)
    );
Shift_Left_Two_32 Shifterj( // jump shifter
    .data_i(instr),
    .data_o(addr_shj)
    );
assign addr_nj = {addr_n1[31:28],addr_shj[27:0]};
assign GetBranch = (BranchType == 0)?Zero                 // BEQ
               : ((BranchType == 1)?~Zero                 // BNE
               : ((BranchType == 2)?alu_res[31]           // BLEZ
               : ((BranchType == 3)?~(Zero | alu_res[31]) // BGTZ
               : 1'b0)));
MUX_2to1 #(.size(32)) Mux_PC_Source(
    .data0_i(addr_n1),
    .data1_i(addr_n2),
    .select_i(Branch & GetBranch), // AND gate of branch
    .data_o(addr_nr)
    );
assign addr_jor = Jump?addr_nj:addr_nr;
assign addr_n = JumpReg?reg_rs_out:addr_jor;
endmodule
