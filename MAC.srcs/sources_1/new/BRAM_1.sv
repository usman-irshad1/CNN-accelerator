`timescale 1ns / 1ps

module BRAM #(
    parameter mem_depth    = 512,
    parameter mem_length   = 10,
    parameter ins_width    = 9,
    parameter kernel_size  = 9,
    parameter depth_val    = 2,
    parameter kernel_total = kernel_size * depth_val
)(
    input  logic                  clock,

    input  logic                  read_enable_port1,
    input  logic                  write_enable_port1,
    input  logic [mem_length-1:0] write_data_port1,
    output logic signed [mem_length-1:0] read_data_port1,
    input  logic [ins_width-1:0]  address_port1,

    input  logic                  read_enable_port2,
    input  logic                  write_enable_port2,
    input  logic [mem_length-1:0] write_data_port2,
    output logic signed [mem_length-1:0] read_data_port2,
    input  logic [ins_width-1:0]  address_port2
);

    logic signed [mem_length-1:0] data [mem_depth-1:0];
    logic signed [mem_length-1:0] kernel [kernel_total-1:0];

    initial
    begin
        $readmemb("BRAM.mem", data);
        $readmemb("Kernel_1.mem", kernel);
    end


    always_ff @(posedge clock)
    begin

        if (write_enable_port1)
        begin
            data[address_port1] <= write_data_port1;
        end


        if (read_enable_port1)
        begin
            read_data_port1 <= data[address_port1];
        end

        if (write_enable_port2)
        begin
            kernel[address_port2] <= write_data_port2;
        end

        if (read_enable_port2)
        begin
            read_data_port2 <= kernel[address_port2];
        end

    end

endmodule