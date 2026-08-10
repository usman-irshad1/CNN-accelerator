`timescale 1ns / 1ps

module MAC_V1_tb;

parameter mem_length   = 9;
parameter accum_length = 27;

// Clock and control
logic clock;
logic reset;
logic [accum_length-1:0] prev_result;
// BRAM outputs
logic [mem_length-1:0] read_data_port1;
logic [mem_length-1:0] read_data_port2;

// DSP signals
logic [accum_length-1:0] out;
logic mac_done;
logic finish;
logic clear;

// Controller
logic [4:0] count;
logic enable;


// ============================================================
// DSP
// ============================================================

DSP #(
    .mem_length(mem_length),
    .accum_length(accum_length)
) dut_DSP (

    .clock(clock),
    .reset(reset),

    .read_data_port1(read_data_port1),
    .read_data_port2(read_data_port2),

    .out(out),
    .mac_done(mac_done),

    .finish(finish),
    .clear(clear),
    .enable(enable),
    .prev_result(prev_result)
);


// ============================================================
// Controller
// ============================================================

Controller dut_Controller (

    .clock(clock),
    .mac_done(mac_done),

    .finish(finish),
    .reset(reset),

    .clear(clear),
    .count(count)
);


// ============================================================
// Clock
// ============================================================

initial
begin
    clock = 0;

    forever #5 clock = ~clock;
end


// ============================================================
// Test
// ============================================================

initial
begin

    // Initial values
    reset = 1;

    read_data_port1 = 0;
    read_data_port2 = 0;
    enable=1;
    // Hold reset
    #12;

    reset = 0;


    // --------------------------------------------------------
    // MAC #1
    // 1 � 1 = 1
    // --------------------------------------------------------

    read_data_port1 = 1;
    read_data_port2 = 1;

    #10;


    // --------------------------------------------------------
    // MAC #2
    // 2 � 1 = 2
    // --------------------------------------------------------

    read_data_port1 = 2;
    read_data_port2 = 1;

    #10;


    // --------------------------------------------------------
    // MAC #3
    // 3 � 1 = 3
    // --------------------------------------------------------

    read_data_port1 = 3;
    read_data_port2 = 1;

    #10;


    // --------------------------------------------------------
    // MAC #4
    // --------------------------------------------------------

    read_data_port1 = 4;
    read_data_port2 = 1;

    #10;


    // --------------------------------------------------------
    // MAC #5
    // --------------------------------------------------------

    read_data_port1 = 5;
    read_data_port2 = 1;

    #10;


    // --------------------------------------------------------
    // MAC #6
    // --------------------------------------------------------

    read_data_port1 = 6;
    read_data_port2 = 1;

    #10;


    // --------------------------------------------------------
    // MAC #7
    // --------------------------------------------------------

    read_data_port1 = 7;
    read_data_port2 = 1;

    #10;


    // --------------------------------------------------------
    // MAC #8
    // --------------------------------------------------------

    read_data_port1 = 8;
    read_data_port2 = 1;

    #10;


    // --------------------------------------------------------
    // MAC #9
    // --------------------------------------------------------
 
    read_data_port1 = 9;
    read_data_port2 = 1;

    #10;
enable=0;
#10
    $display("======================================");
    $display("Expected Result = 45");
    $display("Accumulator     = %0d", out);
    $display("Previous Result = %0d", dut_DSP.prev_result);
    $display("Finish          = %0d", finish);
    $display("Clear           = %0d", clear);
    $display("======================================");


    #20;

    $finish;

end

endmodule