`timescale 1ns / 1ps

module MAC_TOP_tb;

    parameter mem_length   = 9;
    parameter ins_width    = 9;
    parameter accum_length = 27;

    logic                    clock;
    logic                    reset;
    logic [ins_width-1:0]    address_port1;
    logic [ins_width-1:0]    address_port2;
    logic [mem_length-1:0]   read_data_port1;
    logic [mem_length-1:0]   read_data_port2;
    logic [accum_length-1:0] result;

    MAC_TOP #(
        .mem_length(mem_length),
        .ins_width(ins_width),
        .accum_length(accum_length)
    ) dut (
        .clock(clock),
        .reset(reset),
        .address_port1(address_port1),
        .address_port2(address_port2),
        .read_data_port1(read_data_port1),
        .read_data_port2(read_data_port2),
        .result(result)
    );

    initial begin
        clock = 1'b0;
        forever #5 clock = ~clock;
    end

    initial begin
        reset         = 1'b1;
        address_port1 = '0;
        address_port2 = '0;

        #10;
        reset = 1'b0;

        address_port1 = 9'd0;
        address_port2 = 9'd1;
        #10;

        address_port1 = 9'd1;
        address_port2 = 9'd2;
        #10;

        address_port1 = 9'd2;
        address_port2 = 9'd3;
        #10;

        address_port1 = 9'd3;
        address_port2 = 9'd4;
        #10;

        address_port1 = 9'd4;
        address_port2 = 9'd5;
        #10;

        #1;
        $display("--------------------------------------");
        $display("FINAL MAC RESULT = %0d", result);
        $display("EXPECTED RESULT  = 40");
        $display("--------------------------------------");

        #10;
        $finish;
    end

endmodule
