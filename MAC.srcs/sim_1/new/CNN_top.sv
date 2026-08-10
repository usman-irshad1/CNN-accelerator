`timescale 1ns / 1ps

module CNN_TOP_tb;

    // =========================================================
    // PARAMETERS
    // =========================================================

    parameter image_height = 5;
    parameter image_width  = 5;

    parameter accum_length = 27;

    parameter result_size =
                (image_height - 2) *
                (image_width - 2);

    parameter WEIGHT_OFFSET = 25; // 5x5 image uses addresses 0..24, weights stored at 25..33


    // =========================================================
    // CLOCK / RESET
    // =========================================================

    logic clock;
    logic reset;


    // =========================================================
    // RESULTS
    // =========================================================

    logic [result_size-1:0][accum_length-1:0] results;


    // =========================================================
    // EXPOSED TOP-LEVEL DEBUG SIGNALS
    // =========================================================

    logic mac_done;
    logic finish;
    logic clear;
    logic conv_done;

    logic [4:0] count;
    logic [4:0] row;
    logic [4:0] column;

    logic [8:0] address_selected;
    logic [8:0] address_port1;
    logic [8:0] address_port2;

    logic [8:0] read_data_port1;
    logic [8:0] read_data_port2;

    logic [accum_length-1:0] accumulator_out;
    logic [accum_length-1:0] prev_result;


    // =========================================================
    // DUT
    // =========================================================

    CNN_TOP #(
        .image_height(image_height),
        .image_width(image_width),
        .result_size(result_size)
    )
    dut (

        .clock(clock),
        .reset(reset),

        .results(results),

        // Exposed debugging outputs connected directly from top
        .mac_done(mac_done),
        .finish(finish),
        .clear(clear),
        .conv_done(conv_done),

        .count(count),
        .row(row),
        .column(column),

        .address_selected(address_selected),
        .address_port1(address_port1),
        .address_port2(address_port2),

        .read_data_port1(read_data_port1),
        .read_data_port2(read_data_port2),

        .accumulator_out(accumulator_out),
        .prev_result(prev_result)

    );


    // =========================================================
    // BRAM INITIALIZATION & DEBUG SETUP
    // Port 1 reads Pixels (addresses 0 to 24)
    // Port 2 reads Weights (addresses 25 to 33)
    // =========================================================

    integer i;

    initial begin
        // BRAM initializes automatically via $readmemb("BRAM.mem", data) inside BRAM_1.sv
        $display("=======================================================");
        $display("BRAM INITIALIZED: Pixels [0..24], Weights [25..33]");
        $display("=======================================================");
    end


    // =========================================================
    // CLOCK GENERATION
    // =========================================================

    initial
    begin
        clock = 0;
        forever
            #5 clock = ~clock;
    end


    // =========================================================
    // RESET
    // =========================================================

    initial
    begin
        reset = 1;
        #20;
        reset = 0;
    end


    // =========================================================
    // MONITOR & EXTENSIVE DEBUG LOGGING
    // =========================================================

    always @(posedge clock)
    begin
        if (!reset) begin
            $display(
                "TIME=%0t | ROW=%0d COL=%0d COUNT=%0d | ADDR_SEL=%0d ADDR_P1=%0d ADDR_P2=%0d | PX(P1)=%0d WT(P2)=%0d | ACC=%0d PREV=%0d | MAC_DONE=%b FINISH=%b CLEAR=%b CONV_DONE=%b",
                $time,
                row,
                column,
                count,
                address_selected,
                address_port1,
                address_port2,
                read_data_port1,
                read_data_port2,
                accumulator_out,
                prev_result,
                mac_done,
                finish,
                clear,
                conv_done
            );
        end
    end


    // =========================================================
    // WAIT FOR CONVOLUTION & FINAL RESULTS SUMMARY
    // =========================================================

    initial
    begin
        wait(reset == 0);

        wait(conv_done == 1);

        #50;

        $display("");
        $display("======================================");
        $display("CONVOLUTION COMPLETE - FINAL RESULTS");
        $display("======================================");

        for (i = 0; i < result_size; i = i + 1) begin
            $display("Result[%0d] = %0d", i, results[i]);
        end

        $display("======================================");

        $finish;
    end

endmodule