// Author: Pin-Hua Lai, Heng-Jun Hong

module Shift_Left_Two_32(
    data_i,
    data_o
    );

//I/O ports
input [32-1:0] data_i;
output [32-1:0] data_o;

genvar i;
generate
    for (i = 0;i < 32;i = i + 1) begin
    	assign data_o[i] = (i == 0 || i == 1)?1'b0:data_i[i - 2];
    end
endgenerate
endmodule
