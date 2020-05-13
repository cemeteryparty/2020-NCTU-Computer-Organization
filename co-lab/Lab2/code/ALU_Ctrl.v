// Author: Pin-Hua Lai, Heng-Jun Hong

module ALU_Ctrl(
        funct_i,
        ALUOp_i,
        ALUCtrl_o
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

assign ALUCtrl_o = (ALUOp_i != 3'b111)?ALUOp_i_ex // i-type
				 : ((funct_i == 6'b000111)?4'b0101 // srav: SR
				 : ((funct_i == 6'b000011)?4'b1101 // sra : SR 
				 : ((funct_i == 6'b101010)?4'b0111 // slt: SLT
				 : ((funct_i == 6'b100101)?4'b0001 // or: OR
				 : ((funct_i == 6'b100100)?4'b0000 // and: AND
				 : ((funct_i == 6'b100011)?4'b0011 // sub: SUB
				 : ((funct_i == 6'b100001)?4'b0010 // add: ADD
				 : 4'b0110))))))); // sla: SL

endmodule
