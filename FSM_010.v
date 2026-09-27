////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Module      : fsm_010
// Description : Moore FSM that detects the (possibly overlapping) sequence
//               "010" on serial input x and counts how many times it has
//               been seen in users_count. y is high for one cycle whenever
//               the sequence completes.
////////////////////////////////////////////////////////////////////////////////
module fsm_010 (
    input            clk,
    input            rst,
    input            x,
    output           y,
    output reg [9:0] users_count
);

    parameter IDLE  = 2'b00;
    parameter ZERO  = 2'b01;
    parameter ONE   = 2'b10;
    parameter STORE = 2'b11;

    reg [1:0] cs, ns;

    // Next-state logic
    always @(*) begin
        case (cs)
            IDLE:    ns = x ? IDLE : ZERO;
            ZERO:    ns = x ? ONE  : ZERO;
            ONE:     ns = x ? IDLE : STORE;
            STORE:   ns = x ? IDLE : ZERO;
            default: ns = IDLE;
        endcase
    end

    // State register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cs <= IDLE;
        end
        else begin
            cs <= ns;
        end
    end

    // Sequence-match counter
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            users_count <= 0;
        end
        else begin
            if (cs == STORE)
                users_count <= users_count + 1;
        end
    end

    assign y = (cs == STORE) ? 1 : 0;

endmodule
