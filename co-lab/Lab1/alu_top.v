`timescale 1ns/1ps
// Pin-Hua Lai 0716085
module alu_top(
    src1,       //1 bit source 1 (input)
    src2,       //1 bit source 2 (input)
    less,       //1 bit less     (input)
    A_invert,   //1 bit A_invert (input)
    B_invert,   //1 bit B_invert (input)
    cin,        //1 bit carry in (input)
    operation,  //operation      (input)
    result,     //1 bit result   (output)
    cout       //1 bit carry out(output)
    );

input src1;
input src2;
input less;
input A_invert;
input B_invert;
input cin;
input [2-1:0] operation;

output result;
output cout;

reg result;

wire A,B;
assign A = A_invert?~src1:src1;
assign B = B_invert?~src2:src2;

always@( * ) begin // execute always when any signal modify
    if(operation == 2'b00) // AND
        result = A & B;
    else if(operation == 2'b01) //OR
        result = A | B;
    else if(operation == 2'b10) // SUM
        result = A ^ B ^ cin;
    else // LESS
        result = less;
end

assign cout = (A & B) | (cin & (A ^ B)); // CARRY

endmodule
