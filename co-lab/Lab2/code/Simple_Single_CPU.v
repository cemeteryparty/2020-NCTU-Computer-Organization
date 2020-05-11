// Author:

module Simple_Single_CPU(
    clk_i,
    rst_i
    );

// Input port
input clk_i;
input rst_i;

wire [32-1:0] addr_n;  // next PC
wire [32-1:0] addr;    // present PC
wire [32-1:0] addr_n1; // PC + 4
wire [32-1:0] addr_n2; // PC + 4 + TARGET * 4
wire [32-1:0] addr_sh; // TARGET * 4

wire [32-1:0] instr;   // Instruction
// decoder output (control) 
wire         RegWrite; // 
wire [3-1:0] ALUOp;    // 
wire         ALUSrc;   //
wire         RegDst;   //
wire         Branch;   //

wire [4-1:0]  ALUCtrl;
wire          Zero;
wire          GetBranch;

wire [5-1:0]  reg_write;
wire [32-1:0] reg_rs_out;
wire [32-1:0] reg_rt_out;
wire [32-1:0] alu_src0;
wire [32-1:0] alu_src;


wire [32-1:0] data_ext; // extend data
wire [32-1:0] alu_res;  // ALU result

ProgramCounter PC(
    .clk_i(clk_i),
    .rst_i (rst_i),
    .pc_in_i(addr_n),
    .pc_out_o(addr)
    );

Adder Adder1( // A1, PC + 4
    .src1_i(addr),
    .src2_i(4),
    .sum_o(addr_n1)
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
    .RDdata_i(alu_res), // data from alu
    .RegWrite_i(RegWrite),
    .RSdata_o(reg_rs_out), // rs out
    .RTdata_o(reg_rt_out)  //rt out
    );

Decoder Decoder(
    .instr_op_i(instr[31:26]), // input OPCODE 6 bits
    .RegWrite_o(RegWrite),
    .ALU_op_o(ALUOp),
    .ALUSrc_o(ALUSrc),
    .RegDst_o(RegDst),
    .Branch_o(Branch)
    );

ALU_Ctrl AC(
    .funct_i(instr[5:0]),
    .ALUOp_i(ALUOp),
    .ALUCtrl_o(ALUCtrl)
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
assign alu_src0 = (ALUCtrl[3] == 1'b0)?reg_rs_out:{17'b00000000000000000, instr[10:6]}; // MUX(rt:shamt)
ALU ALU(
    .src1_i(alu_src0),
    .src2_i(alu_src),
    .ctrl_i(ALUCtrl),
    .result_o(alu_res),
    .zero_o(Zero)
    );

Adder Adder2( // A2, PC = target
    .src1_i(addr_n1),
    .src2_i(addr_sh),
    .sum_o(addr_n2)
    );

Shift_Left_Two_32 Shifter(
    .data_i(data_ext),
    .data_o(addr_sh)
    );

assign GetBranch = Branch && ((instr[26] == 1'b0)?Zero:~Zero); // AND(Branch,MUX(Zero:~Zero))
MUX_2to1 #(.size(32)) Mux_PC_Source(
    .data0_i(addr_n1),
    .data1_i(addr_n2),
    .select_i(GetBranch),
    .data_o(addr_n)
    );

endmodule
