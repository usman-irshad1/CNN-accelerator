`timescale 1ns / 1ps

module CNN_TOP #(
    parameter mem_depth    = 512,
    parameter mem_length   = 9,
    parameter ins_width    = 9,
    parameter row_width    = 5,
    parameter depth_width  = 4,
    parameter accum_length = 27,

    parameter image_height = 5,
    parameter image_width  = 5,

    parameter result_size = (image_height-2)*(image_width-2)
)(
    input logic clock,
    input logic reset,

    output logic [result_size-1:0][accum_length-1:0] results
);

    // =========================================================
    // IMAGE SIZE SIGNALS
    // =========================================================

    logic [row_width-1:0] image_height_sig;
    logic [row_width-1:0] image_width_sig;

    assign image_height_sig = image_height;
    assign image_width_sig  = image_width;


    // =========================================================
    // CONTROLLER SIGNALS
    // =========================================================

    logic mac_done;
    logic finish;
    logic clear;
    logic enable;

    logic [4:0] count;

    logic [row_width-1:0] row;
    logic [row_width-1:0] column;

    logic conv_done;


    // =========================================================
    // ADDRESS GENERATOR
    // =========================================================

    logic [ins_width-1:0] address_selected;


    // =========================================================
    // BRAM SIGNALS
    // =========================================================

    logic read_enable_port1;
    logic read_enable_port2;

    logic write_enable_port1;
    logic write_enable_port2;

    logic [mem_length-1:0] read_data_port1;
    logic [mem_length-1:0] read_data_port2;

    logic [mem_length-1:0] write_data_port1;
    logic [mem_length-1:0] write_data_port2;

    logic [ins_width-1:0] address_port1;
    logic [ins_width-1:0] address_port2;


    // =========================================================
    // DSP SIGNALS
    // =========================================================

    logic [accum_length-1:0] accumulator_out;
    logic [accum_length-1:0] prev_result;


    // =========================================================
    // CONTROLLER
    // =========================================================

    Controller #(
        .ins_width(ins_width),
        .row_width(row_width),
        .depth_width(depth_width)
    ) controller_inst (

        .clock(clock),
        .mac_done(mac_done),

        .finish(finish),
        .reset(reset),
        .clear(clear),

        .count(count),

        .image_height(image_height_sig),
        .image_width(image_width_sig),

        .column(column),
        .row(row),

        .conv_done(conv_done)
    );


    // =========================================================
    // ADDRESS GENERATOR
    // =========================================================

    address_generator #(
        .ins_width(ins_width),
        .row_width(row_width),
        .depth_width(depth_width)
    ) address_generator_inst (

        .row(row),
        .channel(4'd0),
        .column(column),

        .image_height(image_height_sig),
        .image_width(image_width_sig),

        .address_selected(address_selected),

        .count(count)
    );


    // =========================================================
    // BRAM CONNECTIONS
    // Port 1: Image Pixels (address_selected from AGU)
    // Port 2: Kernel Weights (weight offset + count)
    // =========================================================

    assign address_port1 = address_selected;
    assign address_port2 = (image_height * image_width) + count;

    assign read_enable_port1 = 1'b1;
    assign read_enable_port2 = 1'b1;

    assign write_enable_port1 = 1'b0;
    assign write_enable_port2 = 1'b0;

    assign write_data_port1 = '0;
    assign write_data_port2 = '0;


    // =========================================================
    // BRAM
    // =========================================================

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


    // =========================================================
    // DSP
    // =========================================================

    assign enable = 1'b1;

    DSP #(
        .mem_length(mem_length),
        .accum_length(accum_length)
    ) dsp_inst (

        .clock(clock),
        .reset(reset),

        .read_data_port1(read_data_port1),
        .read_data_port2(read_data_port2),

        .out(accumulator_out),

        .mac_done(mac_done),

        .finish(finish),
        .clear(clear),
        .enable(enable),

        .prev_result(prev_result)
    );


    // =========================================================
    // RESULT MEMORY
    // =========================================================

    result_mem #(
        .mem_length(mem_length),
        .accum_length(accum_length),
        .result_size(result_size)
    ) result_mem_inst (

        .prev_result(prev_result),

        .clock(clock),
        .finish(finish),
        .reset(reset),

        .save(results)
    );


endmodule