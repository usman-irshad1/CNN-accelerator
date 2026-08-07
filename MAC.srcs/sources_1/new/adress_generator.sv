`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/07/2026 01:41:25 PM
// Design Name: 
// Module Name: adress_generator
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


module address_generator#(parameter ins_width  = 9,
parameter row_width  = 5,
parameter depth_width  = 4)
                        (input logic [row_width-1:0]row,
                        input logic[depth_width-1:0] channel,
                        input logic [row_width-1:0]column,
                        input logic [row_width-1:0]image_height,
                        input logic [row_width-1:0]image_width,
                        output logic [ins_width-1:0]address

    );
    assign address=channel*(image_height*image_width)+row*image_width+column;
endmodule
