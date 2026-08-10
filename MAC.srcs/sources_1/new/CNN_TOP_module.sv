`timescale 1ns / 1ps

module CNN_TOP #(
    parameter mem_depth    = 512,
    parameter mem_length   = 9,
    parameter ins_width    = 9,
    parameter row_width    = 5,
    parameter depth_width  = 4,
    parameter accum_length = 27,
    parameter kernel_size  = 9,
    parameter depth_val    = 2,
    parameter kernel_total = kernel_size * depth_val,

    parameter image_height = 5,
    parameter image_width  = 5,

    parameter result_size =
              (image_height-2) *
              (image_width-2)
)(
    input logic clock,
    input logic reset,
    input logic [depth_width-1:0] depth,

    output logic [result_size-1:0][accum_length-1:0] results,
    output logic [result_size-1:0][accum_length-1:0] results_1,
    output logic [result_size-1:0][accum_length-1:0] results_2,

    output logic [row_width-1:0] image_height_sig,
    output logic [row_width-1:0] image_width_sig,

    output logic mac_done,
    output logic mac_done2,
    output logic mac_done1,
    output logic finish,
    output logic clear,
    output logic enable,

    output logic [4:0] count,
    output logic [depth_width-1:0] count_depth,

    output logic [row_width-1:0] row,
    output logic [row_width-1:0] column,

    output logic conv_done,

    output logic [ins_width-1:0] address_selected,

    output logic read_enable_port1,
    output logic read_enable_port2,

    output logic write_enable_port1,
    output logic write_enable_port2,

    output logic [mem_length-1:0] write_data_port1,
    output logic [mem_length-1:0] write_data_port2,

    output logic [ins_width-1:0] address_port1,
    output logic [ins_width-1:0] address_port2,

    output logic [mem_length-1:0] read_data_port1,
    output logic [mem_length-1:0] read_data_port2,
    output logic [mem_length-1:0] read_data_port3,
    output logic [mem_length-1:0] read_data_port4,

    output logic [accum_length-1:0] accumulator_out,
    output logic [accum_length-1:0] accumulator_out1,
    output logic [accum_length-1:0] accumulator_out2,
    output logic [accum_length-1:0] prev_result_1,
    output logic [accum_length-1:0] prev_result_2,
    output logic [accum_length-1:0] prev_result
);


    // =========================================================
    // IMAGE DIMENSIONS
    // =========================================================

    assign image_height_sig = image_height;
    assign image_width_sig  = image_width;


    // =========================================================
    // CONTROLLER
    // =========================================================

    Controller #(
        .ins_width(ins_width),
        .row_width(row_width),
        .depth_width(depth_width),
        .kernel_size(kernel_size)
    ) controller_inst (

        .clock(clock),
        .mac_done(mac_done),
        .mac_done2(mac_done2),
        .mac_done1(mac_done1),
        .depth(depth),
        .finish(finish),
        .reset(reset),
        .clear(clear),

        .count(count),
        .count_depth(count_depth),

        .image_height(image_height_sig),
        .image_width(image_width_sig),

        .column(column),
        .row(row),

        .conv_done(conv_done),
        .enable(enable),

        .read_enable_port1(read_enable_port1),
        .read_enable_port2(read_enable_port2)
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
        .channel(count_depth),
        .column(column),

        .image_height(image_height_sig),
        .image_width(image_width_sig),

        .address_selected(address_selected),

        .count(count)
    );



    assign address_port1 = address_selected;

    assign address_port2 = count;


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
    BRAM_2 #(
        .mem_depth(mem_depth),
        .mem_length(mem_length),
        .ins_width(ins_width)
    ) bram2_inst (

        .clock(clock),

        .read_enable_port3(read_enable_port2),
        .write_enable_port3(write_enable_port1),
        .write_data_port3(write_data_port1),
        .read_data_port3(read_data_port3),
        .address_port3(address_port2),

        .read_enable_port4(read_enable_port2),
        .write_enable_port4(write_enable_port2),
        .write_data_port4(write_data_port2),
        .read_data_port4(read_data_port4),
        .address_port4(address_port2)
    );



    // =========================================================
    // DSP
    // =========================================================

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
    
        DSP_2 #(
        .mem_length(mem_length),
        .accum_length(accum_length)
    ) dsp2_inst (

        .clock(clock),
        .reset(reset),

        .read_data_port1(read_data_port1),
        .read_data_port3(read_data_port3),

        .out(accumulator_out1),

        .mac_done1(mac_done1),

        .finish(finish),
        .clear(clear),
        .enable(enable),

        .prev_result_1(prev_result_1)
    );

        DSP_3 #(
        .mem_length(mem_length),
        .accum_length(accum_length)
    ) dsp3_inst (

        .clock(clock),
        .reset(reset),

        .read_data_port1(read_data_port1),
        .read_data_port4(read_data_port4),

        .out(accumulator_out2),

        .mac_done2(mac_done2),

        .finish(finish),
        .clear(clear),
        .enable(enable),

        .prev_result_2(prev_result_2)
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
        .prev_result_1(prev_result_1),
        .prev_result_2(prev_result_2),
        .clock(clock),
        .finish(finish),
        .reset(reset),

        .save(results),
        .save1(results_1),
        .save2(results_2)
    );

endmodule