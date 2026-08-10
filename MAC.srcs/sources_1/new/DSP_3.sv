`timescale 1ns / 1ps

module DSP_3 #(
    parameter mem_length   = 10,
    parameter accum_length = 28
)(
    input  logic                    clock,
    input  logic                    reset,

    input logic signed [mem_length-1:0]   read_data_port1,
    input logic signed [mem_length-1:0]   read_data_port4,

    output logic [accum_length-1:0] out,
    output logic                    mac_done2,

    input  logic                    finish,
    input  logic                    clear,
    input  logic                    enable,

    output logic signed [accum_length-1:0] prev_result_2
);

    logic signed  [accum_length-1:0] accumulator;
    logic signed  [(2*mem_length)-1:0] product;
    logic signed [accum_length-1:0] next_acc;

    assign product     = read_data_port1 * read_data_port4;
    assign next_acc    = accumulator + product;
    assign prev_result_2 = finish ? next_acc : accumulator;

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            accumulator <= '0;
            mac_done2   <= 1'b0;
        end else begin
            if (clear) begin
                accumulator <= '0;
                mac_done2   <= 1'b0;
            end else if (enable) begin
                accumulator <= next_acc;
                mac_done2   <= 1'b1;
            end else begin
                mac_done2   <= 1'b0;
            end
        end
    end

    assign out = accumulator;

endmodule