`timescale 1ns / 1ps

module AGU_test();

parameter ins_width   = 9;
parameter row_width   = 5;
parameter depth_width = 4;

logic [row_width-1:0]   row;
logic [depth_width-1:0] channel;
logic [row_width-1:0]   column;
logic [row_width-1:0]   image_height;
logic [row_width-1:0]   image_width;
logic [ins_width-1:0]   address;

address_generator #(
    .ins_width(ins_width),
    .row_width(row_width),
    .depth_width(depth_width)
) dut (
    .row(row),
    .channel(channel),
    .column(column),
    .image_height(image_height),
    .image_width(image_width),
    .address(address)
);

initial begin

    // Image dimensions: 3 channels × 4 rows × 4 columns
    image_height = 4;
    image_width  = 4;

    // Test 1
    channel = 0;
    row     = 0;
    column  = 0;
    #10;

    // Test 2
    channel = 0;
    row     = 2;
    column  = 3;
    #10;

    // Test 3
    channel = 1;
    row     = 0;
    column  = 0;
    #10;

    // Test 4
    channel = 1;
    row     = 2;
    column  = 3;
    #10;

    // Test 5
    channel = 2;
    row     = 3;
    column  = 3;
    #10;

    $finish;

end

endmodule