`timescale 1ns / 1ps

module DSP #(
    parameter mem_length   = 9,
    parameter accum_length = 27
)(
    input  logic                    clock,
    input  logic                    reset,
    input  logic [mem_length-1:0]   read_data_port1,
    input  logic [mem_length-1:0]   read_data_port2,
    output logic [accum_length-1:0] out,
    output logic mac_done,
    input logic finish,
     input logic clear,
     input logic enable,
     output logic [accum_length-1:0] prev_result
);

    logic [accum_length-1:0] accumulator;
    


    always_ff @(negedge clock or posedge reset )
     begin
        if (reset) begin
            accumulator <= '0;
            mac_done<=0;
            prev_result<=0;
        end else 
        if (enable)
        begin
           
            accumulator <= accumulator + (read_data_port1 * read_data_port2);
            mac_done<=1;
        end
        if (finish)
        begin
        mac_done<=0;
        prev_result<=accumulator;
        end
        if (clear)
        begin
        accumulator<=0;
        mac_done<=0;
        end
        
    end

    assign out = accumulator;

endmodule
