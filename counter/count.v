////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Module      : counter
// Description : Up/down counter with synchronous active-low reset, active-low
//               parallel load, and count-enable. max_count/zero are combinational
//               flags on the current count value.
////////////////////////////////////////////////////////////////////////////////
module counter (
    input                    clk,
    input                    rst_n,
    input                    load_n,
    input                    up_down,
    input                    ce,
    input      [WIDTH-1:0]   data_load,
    output reg [WIDTH-1:0]   count_out,
    output                   max_count,
    output                   zero
);

    parameter WIDTH = 5;

    always @(posedge clk) begin
        if (!rst_n) count_out <= 0;
        else if (!load_n) count_out <= data_load;
        else if (ce) begin
            if (up_down) count_out <= count_out + 1;
            else count_out <= count_out - 1;
        end
    end

    assign max_count = (count_out == {WIDTH{1'b1}}) ? 1 : 0;
    assign zero      = (count_out == 0) ? 1 : 0;

endmodule
