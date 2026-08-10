`timescale 1ns / 1ps

module CNN_TOP_tb;

    // =========================================================
    // PARAMETERS
    // =========================================================

    parameter mem_depth     = 512;
    parameter mem_length    = 9;
    parameter ins_width     = 9;
    parameter row_width     = 5;
    parameter depth_width   = 4;
    parameter accum_length  = 27;

    parameter image_height  = 5;
    parameter image_width   = 5;

    parameter result_size = 
                (image_height - 2) * 
                (image_width - 2);


    // =========================================================
    // CLOCK / RESET
    // =========================================================

    logic clock;
    logic reset;


    // =========================================================
    // RESULTS & TOP-LEVEL SIGNALS
    // =========================================================

    logic [result_size-1:0][accum_length-1:0] results;
    logic [result_size-1:0][accum_length-1:0] results_1;
    logic [result_size-1:0][accum_length-1:0] results_2;

    logic [row_width-1:0] image_height_sig;
    logic [row_width-1:0] image_width_sig;

    logic mac_done;
    logic mac_done2;
    logic mac_done1;
    logic finish;
    logic clear;
    logic enable;
    logic conv_done;

    logic [4:0] count;
    logic [row_width-1:0] row;
    logic [row_width-1:0] column;

    logic [ins_width-1:0] address_selected;

    logic read_enable_port1;
    logic read_enable_port2;
    logic write_enable_port1;
    logic write_enable_port2;

    logic [mem_length-1:0] write_data_port1;
    logic [mem_length-1:0] write_data_port2;

    logic [ins_width-1:0] address_port1;
    logic [ins_width-1:0] address_port2;

    logic [mem_length-1:0] read_data_port1;
    logic [mem_length-1:0] read_data_port2;
    logic [mem_length-1:0] read_data_port3;
    logic [mem_length-1:0] read_data_port4;

    logic [accum_length-1:0] accumulator_out;
    logic [accum_length-1:0] accumulator_out1;
    logic [depth_width-1:0] depth;

    logic [accum_length-1:0] accumulator_out2;
    logic [accum_length-1:0] prev_result;
    logic [accum_length-1:0] prev_result_1;
    logic [accum_length-1:0] prev_result_2;


    // =========================================================
    // DUT (DESIGN UNDER TEST)
    // =========================================================

    CNN_TOP #(
        .mem_depth(mem_depth),
        .mem_length(mem_length),
        .ins_width(ins_width),
        .row_width(row_width),
        .depth_width(depth_width),
        .accum_length(accum_length),
        .image_height(image_height),
        .image_width(image_width),
        .depth_val(2),
        .result_size(result_size)
    ) dut (
        .clock(clock),
        .reset(reset),
        .depth(depth),
        .results(results),
        .results_1(results_1),
        .results_2(results_2),
        .image_height_sig(image_height_sig),
        .image_width_sig(image_width_sig),
        .mac_done(mac_done),
        .mac_done2(mac_done2),
        .mac_done1(mac_done1),
        .finish(finish),
        .clear(clear),
        .enable(enable),
        .count(count),
        .row(row),
        .column(column),
        .conv_done(conv_done),
        .address_selected(address_selected),
        .read_enable_port1(read_enable_port1),
        .read_enable_port2(read_enable_port2),
        .write_enable_port1(write_enable_port1),
        .write_enable_port2(write_enable_port2),
        .write_data_port1(write_data_port1),
        .write_data_port2(write_data_port2),
        .address_port1(address_port1),
        .address_port2(address_port2),
        .read_data_port1(read_data_port1),
        .read_data_port2(read_data_port2),
        .read_data_port3(read_data_port3),
        .read_data_port4(read_data_port4),
        .accumulator_out(accumulator_out),
        .accumulator_out1(accumulator_out1),
        .accumulator_out2(accumulator_out2),
        .prev_result_1(prev_result_1),
        .prev_result_2(prev_result_2),
        .prev_result(prev_result)
    );


    // =========================================================
    // CLOCK GENERATION
    // =========================================================

    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end


    // =========================================================
    // RESET GENERATION
    // =========================================================

    initial begin
        depth = 4'd2;
        reset = 1;
        #20;
        reset = 0;
    end


    // =========================================================
    // MONITOR & EXTENSIVE DEBUG LOGGING
    // =========================================================

    always @(posedge clock) begin
        if (!reset) begin
            $display(
                "TIME=%0t | ROW=%0d COL=%0d COUNT=%0d | P1=%0d P2=%0d P3=%0d P4=%0d | ACC0=%0d ACC1=%0d ACC2=%0d | PR0=%0d PR1=%0d PR2=%0d | MAC0=%b MAC1=%b MAC2=%b CONV=%b",
                $time,
                row,
                column,
                count,
                read_data_port1,
                read_data_port2,
                read_data_port3,
                read_data_port4,
                accumulator_out,
                accumulator_out1,
                accumulator_out2,
                prev_result,
                prev_result_1,
                prev_result_2,
                mac_done,
                mac_done1,
                mac_done2,
                conv_done
            );
        end
    end


    // =========================================================
    // WAIT FOR CONVOLUTION & FINAL RESULTS SUMMARY
    // =========================================================

    integer i;

    initial begin
        wait(reset == 0);
        wait(conv_done == 1);
        #20;

        $display("");
        $display("======================================");
        $display("CONVOLUTION COMPLETE - MULTI-DSP RESULTS");
        $display("======================================");

        for (i = 0; i < result_size; i = i + 1) begin
            $display("Result_DSP1[%0d] = %0d  |  Result_DSP2[%0d] = %0d  |  Result_DSP3[%0d] = %0d", i, results[i], i, results_1[i], i, results_2[i]);
        end

        $display("======================================");
        $finish;
    end

endmodule