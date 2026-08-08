`timescale 1ns / 1ps

module Controller #(
    parameter ins_width   = 9,
    parameter row_width   = 5,
    parameter depth_width = 4
)(
    input  logic clock,
    input  logic mac_done,
    output logic finish,
    input  logic reset,
    output logic clear,
    output logic [4:0] count,
    input  logic [row_width-1:0] image_height,
    input  logic [row_width-1:0] image_width,
    output logic [row_width-1:0] column,
    output logic [row_width-1:0] row,
    output logic conv_done
);

always_ff @(posedge clock or posedge reset)
begin
    if (reset)
    begin
        count     <= 0;
        finish    <= 0;
        clear     <= 0;
        column    <= 0;
        row       <= 0;
        conv_done <= 0;
    end
    else
    begin
        finish    <= 0;
        clear     <= 0;
        conv_done <= 0;

        if (mac_done)
        begin
            if (count == 8)
            begin
                finish <= 1;
                clear  <= 1;
                count  <= 0;
                if (column < image_width - 3)
                begin
                    column <= column + 1;
                end
                else
                begin
                    column <= 0;
                    if (row < image_height - 3)
                    begin
                        row <= row + 1;
                    end
                    else
                    begin
                        conv_done <= 1;
                    end
                end
            end
            else
            begin
                count <= count + 1;
            end
        end
    end
end

endmodule