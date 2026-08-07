`timescale 1ns / 1ps

module MAC_TOP #(
    parameter mem_depth    = 512,
    parameter mem_length   = 9,
    parameter ins_width    = 9,
    parameter accum_length = 27
)(
    input  logic                    clock,
    input  logic                    reset,

    input  logic [ins_width-1:0]    address_port1,
    input  logic [ins_width-1:0]    address_port2,

    output logic [mem_length-1:0]   read_data_port1,
    output logic [mem_length-1:0]   read_data_port2,

    output logic [accum_length-1:0] result
);

    logic                  read_enable_port1;
    logic                  write_enable_port1;
    logic                  read_enable_port2;
    logic                  write_enable_port2;
    logic [mem_length-1:0] write_data_port1;
    logic [mem_length-1:0] write_data_port2;

    BRAM #(
        .mem_depth(mem_depth),
        .mem_length(mem_length),
        .ins_width(ins_width)
    ) bram_inst (
        .clock(clock),

        .read_enable_port1(read_enable_port1),
        .write_enable_port1(write_enable_port1),
        .write_data_port1(write_data_port1),
        .read_data_port1(read_data_port1),
        .address_port1(address_port1),

        .read_enable_port2(read_enable_port2),
        .write_enable_port2(write_enable_port2),
        .write_data_port2(write_data_port2),
        .read_data_port2(read_data_port2),
        .address_port2(address_port2)
    );

    DSP #(
        .mem_length(mem_length),
        .accum_length(accum_length)
    ) dsp_inst (
        .clock(clock),
        .reset(reset),
        .read_data_port1(read_data_port1),
        .read_data_port2(read_data_port2),
        .out(result)
    );

    assign read_enable_port1  = 1'b1;
    assign read_enable_port2  = 1'b1;

    assign write_enable_port1 = 1'b0;
    assign write_enable_port2 = 1'b0;

    assign write_data_port1   = '0;
    assign write_data_port2   = '0;

endmodule
