// Author: 0716316洪珩鈞, 0716085賴品樺

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
/*assign result_o = (ctrl_i == 0 ? src1_i & src2_i :                   // &
                  (ctrl_i == 1 ? src1_i | src2_i :                   // |
                  (ctrl_i == 2 ? src1_i + src2_i :                   // +
                  (ctrl_i == 3 ? src1_i - src2_i :                   // -
                  (ctrl_i == 4 ? src1_i < src2_i :                   // <u
                  (ctrl_i == 5 ? $signed(src2_i) >>> src1_i :        // >>
                  (ctrl_i == 14 ? src2_i << src1_i :                 // <<
                  (ctrl_i == 7 ? $signed(src1_i) < $signed(src2_i) : // <
                  (ctrl_i == 8 ? src1_i * src2_i :                   // *
                  (ctrl_i == 6 ? src2_i << 16 :                      // lui
                  32'b00000000000000000000000000000000))))))))));*/
reg [32-1:0] result_o;
always @(*) begin
    case (ctrl_i)
        0: result_o = src1_i & src2_i;
        1: result_o = src1_i | src2_i;
        2: result_o = src1_i + src2_i;
        3: result_o = src1_i - src2_i;
        4: result_o = src1_i < src2_i;
        5: result_o = $signed(src2_i) >>> src1_i;
        14: result_o = src2_i << src1_i;
        7: result_o = $signed(src1_i) < $signed(src2_i);
        8: result_o = src1_i * src2_i;
        6: result_o = src2_i << 16;
        default: result_o = 0;
    endcase
end
assign zero_o = (result_o == 32'b00000000000000000000000000000000);
endmodule
