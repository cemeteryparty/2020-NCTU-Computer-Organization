// Author: 0716316洪珩均, 0716085賴品樺

module Sign_Extend(
    data_i,
    data_o
    );

//I/O ports
input   [16-1:0] data_i;
output  [32-1:0] data_o;

//Internal Signals
//reg     [32-1:0] data_o;

//Sign extended
assign data_o[32-1:16] = data_i[16-1] ? 16'b1111111111111111 : 16'b0000000000000000;
assign data_o[16-1:0] = data_i[16-1:0];

endmodule
