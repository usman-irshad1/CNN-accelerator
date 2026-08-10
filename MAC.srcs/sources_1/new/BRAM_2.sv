`timescale 1ns / 1ps

module BRAM_2 #(
    parameter mem_depth    = 512,
    parameter mem_length   = 10,
    parameter ins_width    = 9,
    parameter kernel_size  = 9,
    parameter depth_val    = 2,
    parameter kernel_total = kernel_size * depth_val
)(
    input  logic                  clock,

    input  logic                  read_enable_port3,
    input  logic                  write_enable_port3,
    input  logic [mem_length-1:0] write_data_port3,
    output logic signed [mem_length-1:0] read_data_port3,
    input  logic [ins_width-1:0]  address_port3,

    input  logic                  read_enable_port4,
    input  logic                  write_enable_port4,
    input  logic [mem_length-1:0] write_data_port4,
    output logic signed [mem_length-1:0] read_data_port4,
    input  logic [ins_width-1:0]  address_port4
);

    logic signed [mem_length-1:0] kernel3 [kernel_total-1:0];
    logic signed [mem_length-1:0] kernel4 [kernel_total-1:0];

    initial
    begin
        $readmemb("Kernel_2.mem", kernel3);
        $readmemb("Kernel_3.mem", kernel4);
    end


    always_ff @(posedge clock)
    begin

        if (write_enable_port3)
        begin
            kernel3[address_port3] <= write_data_port3;
        end


        if (read_enable_port3)
        begin
            read_data_port3 <= kernel3[address_port3];
        end

        if (write_enable_port4)
        begin
            kernel4[address_port4] <= write_data_port4;
        end

        if (read_enable_port4)
        begin
            read_data_port4 <= kernel4[address_port4];
        end

    end

endmodule