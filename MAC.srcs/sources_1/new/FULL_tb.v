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
            "TIME=%0t | ROW=%0d COL=%0d COUNT=%0d | ADDR=%0d | X=%0d W=%0d | ACC=%0d | MAC_DONE=%b FINISH=%b CLEAR=%b CONV_DONE=%b",

            $time,

            dut.row,
            dut.column,
            dut.count,

            dut.address_selected,

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

        $display("Result 0 = %0d", results[0]);
        $display("Result 1 = %0d", results[1]);
        $display("Result 2 = %0d", results[2]);
        $display("Result 3 = %0d", results[3]);
        $display("Result 4 = %0d", results[4]);
        $display("Result 5 = %0d", results[5]);
        $display("Result 6 = %0d", results[6]);
        $display("Result 7 = %0d", results[7]);
        $display("Result 8 = %0d", results[8]);

        $display("======================================");

        $finish;

    end

endmodule