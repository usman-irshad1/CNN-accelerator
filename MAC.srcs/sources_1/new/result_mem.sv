`timescale 1ns / 1ps

module result_mem #(
    parameter mem_length   = 10,
    parameter accum_length = 28,
    parameter result_size  = 10
)(
    input logic signed [accum_length-1:0] prev_result,
    input logic signed [accum_length-1:0] prev_result_1,
    input logic signed [accum_length-1:0] prev_result_2,
    input logic clock,
    input logic finish,
    input logic reset,
    output logic signed [result_size-1:0][accum_length-1:0] save,
    output logic signed [result_size-1:0][accum_length-1:0] save1,
    output logic signed [result_size-1:0][accum_length-1:0] save2
);

    logic [accum_length-1:0] mem [0:result_size-1];
    logic [accum_length-1:0] mem1 [0:result_size-1];
    logic [accum_length-1:0] mem2 [0:result_size-1];
    logic [$clog2(result_size):0] count;

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            count <= 0;
            mem   <= '{default: '0};
            mem1  <= '{default: '0};
            mem2  <= '{default: '0};
        end else if (finish) begin
            if (count < result_size) begin
                mem[count]  <= (prev_result   >= 0) ? prev_result   : '0;
                mem1[count] <= (prev_result_1 >= 0) ? prev_result_1 : '0;
                mem2[count] <= (prev_result_2 >= 0) ? prev_result_2 : '0;
                count       <= count + 1;
            end
        end
    end

    generate
        genvar g;
        for (g = 0; g < result_size; g++) begin : gen_out
            assign save[g]  = mem[g];
            assign save1[g] = mem1[g];
            assign save2[g] = mem2[g];
        end
    endgenerate

endmodule