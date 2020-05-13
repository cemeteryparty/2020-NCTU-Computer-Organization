// Author: Pin-Hua Lai, Heng-Jun Hong

module Adder(
    src1_i,
    src2_i,
    sum_o
    );

//I/O ports
input  [32-1:0]  src1_i;
input  [32-1:0]	 src2_i;
output [32-1:0]	 sum_o;

//Internal Signals
wire   [32-1:0]	 sum_o;
wire   [32:0] cin;
assign cin[0] = 1'b0;
genvar i;
generate
    for (i = 0;i < 32;i = i + 1) begin
        assign sum_o[i] = src1_i[i] ^ src2_i[i] ^ cin[i];
        assign cin[i + 1] = (src1_i[i] & src2_i[i]) | (cin[i] & (src1_i[i] ^ src2_i[i]));
    end
endgenerate
endmodule
