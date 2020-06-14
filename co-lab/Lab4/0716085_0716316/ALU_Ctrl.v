// Author: 0716085賴品樺, 0716316洪珩均

module ALU_Ctrl(
        funct_i,
        ALUOp_i,
        ALUCtrl_o,
        JumpReg,
        Shamt
        );

//I/O ports
input      [6-1:0] funct_i;
input      [3-1:0] ALUOp_i;

wire      [4-1:0] ALUOp_i_ex;
assign ALUOp_i_ex[3] = 1'b0;
assign ALUOp_i_ex[2] = ALUOp_i[2];
assign ALUOp_i_ex[1] = ALUOp_i[1];
assign ALUOp_i_ex[0] = ALUOp_i[0];
output     [4-1:0] ALUCtrl_o;
output             JumpReg;
output             Shamt;

assign ALUCtrl_o = (ALUOp_i != 3'b111)?ALUOp_i_ex // i-type
				 : ((funct_i == 6'b000111)?4'b0101 // srav: >> (5)
				 : ((funct_i == 6'b000011)?4'b0101 // sra : >> (5)
				 : ((funct_i == 6'b000000)?4'b1110 // sll : << (14)
				 : ((funct_i == 6'b101010)?4'b0111 // slt: <   (7)
				 : ((funct_i == 6'b100101)?4'b0001 // or: |    (1)
				 : ((funct_i == 6'b100100)?4'b0000 // and: &   (0)
				 : ((funct_i == 6'b100011)?4'b0011 // sub: -   (3)
				 : ((funct_i == 6'b100001)?4'b0010 // addu: +  (2)
				 : ((funct_i == 6'b011000)?4'b1000 // mul: *   (8)
				 : 4'b0110)))))))));

assign JumpReg = (ALUOp_i == 3'b111) && (funct_i == 6'b001000);
assign Shamt = (ALUOp_i == 3'b111) && ((funct_i == 6'b000011) || (funct_i == 6'b000000));
endmodule
