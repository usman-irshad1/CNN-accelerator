module result_mem #(
    parameter mem_length   = 9,
    parameter accum_length = 27,
    parameter result_size  = 4
)(
    input logic [accum_length-1:0] prev_result,
    input logic clock,
    input logic finish,
    input logic reset,
    output logic [result_size-1:0][accum_length-1:0] save
);

    logic [$clog2(result_size)-1:0] count;

    

    always_ff @(posedge clock or posedge reset)
    begin
        if (reset)
        begin
            count <= 0;
        end
        else if (finish)
        begin
            save[count] <= prev_result;

            if (count == result_size-1)
                count <= 0;
            else
                count <= count + 1;
        end
    end

endmodule