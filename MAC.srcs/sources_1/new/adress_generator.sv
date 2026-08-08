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
//this is for the 3x3 kernel

module address_generator#(parameter ins_width  = 9,
parameter row_width  = 5,
parameter depth_width  = 4)
                        (input logic [row_width-1:0]row,
                        input logic[depth_width-1:0] channel,
                        input logic [row_width-1:0]column,
                        input logic [row_width-1:0]image_height,
                        input logic [row_width-1:0]image_width,
                        output logic [ins_width-1:0]address_selected,
                        input logic [4:0] count
                        
                        
    );
    logic [ins_width-1:0]address;
    logic [ins_width-1:0]adress_row0column1;
    logic [ins_width-1:0]adress_row0column2;
    logic [ins_width-1:0]adress_row1column0;
    logic [ins_width-1:0]adress_row1column1;
    logic [ins_width-1:0]adress_row1column2;
    logic [ins_width-1:0]adress_row2column0;
    logic [ins_width-1:0]adress_row2column1;
    logic [ins_width-1:0]adress_row2column2;
 
    always_comb
    begin
    if  (column < image_width - 2 && row < image_height - 2)
    begin
    address=channel*(image_height*image_width)+row*image_width+column;
    adress_row0column1=address+1;
    adress_row0column2=address+2;
    
    adress_row1column0=address+image_width;
    adress_row1column1=address+image_width+1;
    adress_row1column2=address+image_width+2;
    
    adress_row2column0=address+2*image_width;
    adress_row2column1=address+2*image_width+1;
    adress_row2column2=address+2*image_width+2;
    end
    else
    begin
    address=0;
    adress_row0column1=0;
    adress_row0column2=0;
    
    adress_row1column0=0;
    adress_row1column1=0;
    adress_row1column2=0;
    
    adress_row2column0=0;
    adress_row2column1=0;
    adress_row2column2=0;
    end
       case (count)                                                                                                                                     
                5'd0: address_selected = address;                                                                                                       
                5'd1: address_selected = adress_row0column1;                                                                                                       
                5'd2: address_selected = adress_row0column2;                                                                                                       
                5'd3: address_selected = adress_row1column0;                                                                                                       
                5'd4: address_selected = adress_row1column1;                                                                                                       
                5'd5: address_selected = adress_row1column2;                                                                                                       
                5'd6: address_selected = adress_row2column0;                                                                                                       
                5'd7: address_selected = adress_row2column1;                                                                                                       
                5'd8: address_selected = adress_row2column2;                                                                                                       
                default: address_selected = '0;                                                                                                           
            endcase                                   
    end
endmodule
