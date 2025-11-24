`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.08.2025 12:07:40
// Design Name: 
// Module Name: delay
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
/*module delay(clk,reset,x,d );
input logic clk,reset;
input logic [31:0]x;
output reg [31:0]d;
always@(posedge clk or posedge reset)begin
    if(reset)
        d<=32'b0;
    else 
        d<=x;
end
endmodule*/
module delay #(parameter WIDTH = 32) (
    input  logic clk,
    input  logic reset,
    input  logic [WIDTH-1:0] x,
    output logic [WIDTH-1:0] d
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            d <= '0;
        else
            d <= x;
    end
endmodule
