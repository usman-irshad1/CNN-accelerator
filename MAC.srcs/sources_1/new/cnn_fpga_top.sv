`timescale 1ns / 1ps

// Defaults match the existing 5x5x2 input and three 3x3x2 filters.
module cnn_fpga_top (
    input  logic        clock,
    input  logic        reset,
    input  logic [3:0]  result_index,
    input  logic [1:0]  filter_select,
    output logic [26:0] result_data,
    output wire         conv_done
);
    wire [8:0][26:0] results_0, results_1, results_2;

    CNN_TOP accelerator (
        .clock(clock),
        .reset(reset),
        .depth(4'd2),
        .results(results_0),
        .results_1(results_1),
        .results_2(results_2),
        .conv_done(conv_done)
    );

    // Read the completed tensor by filter (0..2) and spatial index (0..8).
    // Invalid selections return zero.
    always_comb begin
        result_data = 27'd0;
        if (result_index < 9) begin
            case (filter_select)
                2'd0: result_data = results_0[result_index];
                2'd1: result_data = results_1[result_index];
                2'd2: result_data = results_2[result_index];
                default: result_data = 27'd0;
            endcase
        end
    end
endmodule
