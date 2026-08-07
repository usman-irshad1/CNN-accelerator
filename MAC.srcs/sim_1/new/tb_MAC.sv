`timescale 1ns / 1ps

module tb_MAC;

    parameter MEM_DEPTH    = 512;
    parameter MEM_LENGTH   = 9;
    parameter INS_WIDTH    = 9;
    parameter ACCUM_LENGTH = 27;

    logic                    clock;
    logic                    reset;

    logic                    read_enable_port1;
    logic                    write_enable_port1;
    logic [MEM_LENGTH-1:0]   write_data_port1;
    logic [MEM_LENGTH-1:0]   read_data_port1;
    logic [INS_WIDTH-1:0]    address_port1;

    logic                    read_enable_port2;
    logic                    write_enable_port2;
    logic [MEM_LENGTH-1:0]   write_data_port2;
    logic [MEM_LENGTH-1:0]   read_data_port2;
    logic [INS_WIDTH-1:0]    address_port2;

    logic [ACCUM_LENGTH-1:0] dsp_out;

    BRAM #(
        .mem_depth(MEM_DEPTH),
        .mem_length(MEM_LENGTH),
        .ins_width(INS_WIDTH)
    ) u_bram (
        .clock(clock),
        .read_enable_port1(read_enable_port1),
        .write_enable_port1(write_enable_port1),
        .write_data_port1(write_data_port1),
        .read_data_port1(read_data_port1),
        .address_port1(address_port1),
        .write_enable_port2(write_enable_port2),
        .read_enable_port2(read_enable_port2),
        .write_data_port2(write_data_port2),
        .read_data_port2(read_data_port2),
        .address_port2(address_port2)
    );

    DSP #(
        .mem_length(MEM_LENGTH),
        .accum_length(ACCUM_LENGTH)
    ) u_dsp (
        .clock(clock),
        .reset(reset),
        .read_data_port1(read_data_port1),
        .read_data_port2(read_data_port2),
        .out(dsp_out)
    );

    always #5 clock = ~clock;

    initial begin
        clock              = 0;
        reset              = 0;
        read_enable_port1  = 0;
        write_enable_port1 = 0;
        write_data_port1   = 0;
        address_port1      = 0;

        read_enable_port2  = 0;
        write_enable_port2 = 0;
        write_data_port2   = 0;
        address_port2      = 0;

        #2;
        reset = 1;
        #20;
        reset = 0;

        @(posedge clock);
        address_port1 = 9'd1;
        address_port2 = 9'd2;
        read_enable_port1 = 1;
        read_enable_port2 = 1;

        @(posedge clock);
        address_port1 = 9'd3;
        address_port2 = 9'd4;

        @(posedge clock);
        address_port1 = 9'd5;
        address_port2 = 9'd6;

        @(posedge clock);
        read_enable_port1 = 0;
        read_enable_port2 = 0;

        @(posedge clock);
        read_enable_port1  = 0;
        read_enable_port2  = 0;
        address_port1      = 9'd100;
        write_data_port1   = 9'd123;
        write_enable_port1 = 1;

        @(posedge clock);
        write_enable_port1 = 0;
        read_enable_port1  = 1;
        address_port1      = 9'd100;

        @(posedge clock);

        #10;
        reset = 1;
        #10;
        reset = 0;

        #20;
        $finish;
    end

endmodule
