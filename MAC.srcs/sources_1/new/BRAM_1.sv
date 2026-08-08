`timescale 1ns / 1ps

module BRAM #(
    parameter mem_depth  = 512,
    parameter mem_length = 9,
    parameter ins_width  = 9
)(
    input  logic                  clock,
    input  logic                  read_enable_port1,
    input  logic                  write_enable_port1,
    input  logic [mem_length-1:0] write_data_port1,
    output logic [mem_length-1:0] read_data_port1,
    input  logic [ins_width-1:0]  address_port1,
    input  logic                  read_enable_port2,
    input  logic                  write_enable_port2,
    input  logic [mem_length-1:0] write_data_port2,
    output logic [mem_length-1:0] read_data_port2,
    input  logic [ins_width-1:0]  address_port2
   
);

    logic [mem_length-1:0] data [mem_depth-1:0];

    initial begin
        $readmemb("BRAM.mem", data);
    end
    
    always_ff @(posedge clock) begin 
        if (write_enable_port1 && write_enable_port2) begin
            if (address_port1 == address_port2) begin
                $display("error");
            end
        end

        if (write_enable_port1) begin
            data[address_port1] <= write_data_port1;
        end

        if (read_enable_port1) begin
            read_data_port1 <= data[address_port1];
        end

        if (write_enable_port2) begin
            data[address_port2] <= write_data_port2;
        end

        if (read_enable_port2) begin
            read_data_port2 <= data[address_port2];
        end
    end

endmodule
