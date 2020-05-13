// Author: Pin-Hua Lai, Heng-Jun Hong

module ALU(
    src1_i,
    src2_i,
    ctrl_i,
    result_o,
    zero_o
    );

//I/O ports
input  [32-1:0]  src1_i;
input  [32-1:0]	 src2_i;
input  [4-1:0]   ctrl_i;

output [32-1:0]	 result_o;
output           zero_o;

//Internal signals
wire             zero_o;
assign result_o = (ctrl_i == 0 ? src1_i & src2_i :
                  (ctrl_i == 1 ? src1_i | src2_i : 
                  (ctrl_i == 2 ? src1_i + src2_i :
                  (ctrl_i == 3 ? src1_i - src2_i :
                  (ctrl_i == 4 ? src1_i < src2_i :
                  (ctrl_i == 5 || ctrl_i == 13 ? src2_i >> src1_i :
                  (ctrl_i == 6 ? src2_i << 16 :
                  (ctrl_i == 7 ? $signed(src1_i) < $signed(src2_i) :
                  32'b00000000000000000000000000000000))))))));
assign zero_o = (result_o == 32'b00000000000000000000000000000000);
endmodule
