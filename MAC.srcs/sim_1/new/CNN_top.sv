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

        .results(results)

    );


    // =========================================================
    // BRAM INITIALIZATION
    // Port 1 reads Pixels (addresses 0 to 24)
    // Port 2 reads Weights (addresses 25 to 33)
    // =========================================================

    integer i;

    initial
    begin
        // Initialize Image Pixels (Address 0 to 24 for 5x5 image)
        for (i = 0; i < 25; i = i + 1) begin
            dut.bram_inst.data[i] = i + 1; // Pixels: 1, 2, 3, ..., 25
        end

        // Initialize 3x3 Kernel Weights (Address 25 to 33)
        // All weights set to 1 for 3x3 spatial filter/sum test
        for (i = 0; i < 9; i = i + 1) begin
            dut.bram_inst.data[WEIGHT_OFFSET + i] = 9'd1;
        end
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
    // MONITOR
    // =========================================================

    always @(posedge clock)
    begin

        $display(
            "TIME=%0t | ROW=%0d COL=%0d COUNT=%0d | ADDR_PX=%0d ADDR_WT=%0d | PX=%0d WT=%0d | ACC=%0d | MAC_DONE=%b FINISH=%b CLEAR=%b CONV_DONE=%b",

            $time,

            dut.row,
            dut.column,
            dut.count,

            dut.address_selected,
            dut.address_port2,

            dut.read_data_port1,
            dut.read_data_port2,

            dut.accumulator_out,

            dut.mac_done,
            dut.finish,
            dut.clear,
            dut.conv_done
        );

    end


    // =========================================================
    // WAIT FOR CONVOLUTION
    // =========================================================

    initial
    begin

        wait(reset == 0);

        wait(dut.conv_done == 1);

        #20;

        $display("");
        $display("======================================");
        $display("CONVOLUTION COMPLETE");
        $display("======================================");

        for (i = 0; i < result_size; i = i + 1) begin
            $display("Result %0d = %0d", i, results[i]);
        end

        $display("======================================");

        $finish;

    end

endmodule