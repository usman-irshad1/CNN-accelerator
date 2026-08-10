`timescale 1ns / 1ps

module Controller #(
    parameter ins_width   = 9,
    parameter row_width   = 5,
    parameter depth_width = 4,
    parameter kernel_size = 9
)(
    input  logic             clock,
    input  logic             mac_done,
    input  logic             mac_done1,
    input  logic             mac_done2,
    input  logic [depth_width-1:0] depth,

    output logic             finish,
    input  logic             reset,
    output logic             clear,

    output logic [4:0]       count,
    output logic [depth_width-1:0] count_depth, // Exposed for debugging/addressing channel offsets

    input  logic [row_width-1:0] image_height,
    input  logic [row_width-1:0] image_width,

    output logic [row_width-1:0] column,
    output logic [row_width-1:0] row,

    output logic             conv_done,
    output logic             enable,

    output logic             read_enable_port1,
    output logic             read_enable_port2
);

    typedef enum logic [1:0] {
        IDLE,
        RUN,
        DONE
    } state_t;

    state_t state;

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            state             <= IDLE;
            count             <= 0;
            count_depth       <= 0;
            finish            <= 0;
            clear             <= 1;
            column            <= 0;
            row               <= 0;
            conv_done         <= 0;
            enable            <= 0;
            read_enable_port1 <= 1;
            read_enable_port2 <= 1;
        end else begin
            finish <= 0;
            clear  <= 0;

            case (state)
                IDLE: begin
                    count_depth       <= 0;
                    count             <= 0;
                    column            <= 0;
                    row               <= 0;
                    conv_done         <= 0;
                    read_enable_port1 <= 1;
                    read_enable_port2 <= 1;
                    enable            <= 1;
                    state             <= RUN;
                end

                RUN: begin
                    read_enable_port1 <= 1;
                    read_enable_port2 <= 1;
                    enable            <= 1;

                    if (count == kernel_size - 1) begin
                        count <= 0;

                        // Check if we have processed all depth channels for the CURRENT spatial window
                        if (count_depth < depth - 1) begin
                            count_depth <= count_depth + 1;
                        end else begin
                            // All channels finished for this (row, col) window!
                            count_depth <= 0;
                            finish      <= 1; // Trigger result save
                            clear       <= 1; // Clear accumulator for the NEXT spatial window

                            // Now move to the next spatial position
                            if (column < image_width - 3) begin
                                column <= column + 1;
                            end else begin
                                column <= 0;
                                if (row < image_height - 3) begin
                                    row <= row + 1;
                                end else begin
                                    conv_done <= 1;
                                    state     <= DONE;
                                end
                            end
                        end
                    end else begin
                        count <= count + 1;
                    end
                end

                DONE: begin
                    finish            <= 0;
                    clear             <= 0;
                    enable            <= 0;
                    read_enable_port1 <= 0;
                    read_enable_port2 <= 0;
                    conv_done         <= 1;
                    state             <= DONE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule