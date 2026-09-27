//-----------------------------------------------------------------------------
// Module      : alsu
// Description : Arithmetic/Logic/Shift Unit.
//               opcode selects: OR, XOR, ADD (+cin), MULT, shift, rotate.
//               red_op_A/red_op_B request a reduction (|A or ^A / |B or ^B)
//               instead of a two-operand result. bypass_A/bypass_B pass an
//               operand straight to the output. An invalid combination of
//               red_op_A/red_op_B with a shift/rotate/mult opcode forces
//               out to 0 and makes leds toggle every cycle as an alert.
//-----------------------------------------------------------------------------
module alsu (
    input               clk,
    input               rst,
    input        signed [2:0] a,
    input        signed [2:0] b,
    input        signed [1:0] cin,
    input               serial_in,
    input               red_op_a,
    input               red_op_b,
    input        [2:0]  opcode,
    input               bypass_a,
    input               bypass_b,
    input               direction,
    output reg   [15:0] leds,
    output reg signed [5:0] out
);

    parameter INPUT_PRIORITY = "A";  // Which operand wins when both reductions are requested
    parameter FULL_ADDER     = "ON"; // Whether cin is added in for the ADD opcode

    reg red_op_a_reg, red_op_b_reg, bypass_a_reg, bypass_b_reg, direction_reg, serial_in_reg;
    reg signed [1:0] cin_reg;
    reg        [2:0] opcode_reg;
    reg signed [2:0] a_reg, b_reg;

    wire invalid_red_op, invalid_opcode, invalid;

    // Invalid handling: a reduction request combined with a shift/rotate/mult
    // opcode, or opcode == 3'b11x (undefined), is flagged invalid.
    assign invalid_red_op = (red_op_a_reg | red_op_b_reg) & (opcode_reg[1] | opcode_reg[2]);
    assign invalid_opcode = opcode_reg[1] & opcode_reg[2];
    assign invalid        = invalid_red_op | invalid_opcode;

    // Register input signals
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cin_reg       <= 0;
            red_op_b_reg  <= 0;
            red_op_a_reg  <= 0;
            bypass_b_reg  <= 0;
            bypass_a_reg  <= 0;
            direction_reg <= 0;
            serial_in_reg <= 0;
            opcode_reg    <= 0;
            a_reg         <= 0;
            b_reg         <= 0;
        end
        else begin
            cin_reg       <= cin;
            red_op_b_reg  <= red_op_b;
            red_op_a_reg  <= red_op_a;
            bypass_b_reg  <= bypass_b;
            bypass_a_reg  <= bypass_a;
            direction_reg <= direction;
            serial_in_reg <= serial_in;
            opcode_reg    <= opcode;
            a_reg         <= a;
            b_reg         <= b;
        end
    end

    // Alert LEDs: blink while the current input combination is invalid
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            leds <= 0;
        end
        else begin
            if (invalid) leds <= ~leds;
            else leds <= 0;
        end
    end

    // ALSU output processing
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out <= 0;
        end
        else begin
            if (bypass_a_reg && bypass_b_reg) out <= (INPUT_PRIORITY == "A") ? a_reg : b_reg;
            else if (bypass_a_reg) out <= a_reg;
            else if (bypass_b_reg) out <= b_reg;
            else if (invalid) out <= 0;
            else begin
                case (opcode_reg)
                    3'h0: begin // OR / reduction-OR
                        if (red_op_a_reg && red_op_b_reg) out <= (INPUT_PRIORITY == "A") ? |a_reg : |b_reg;
                        else if (red_op_a_reg) out <= |a_reg;
                        else if (red_op_b_reg) out <= |b_reg;
                        else out <= a_reg | b_reg;
                    end
                    3'h1: begin // XOR / reduction-XOR
                        if (red_op_a_reg && red_op_b_reg) out <= (INPUT_PRIORITY == "A") ? ^a_reg : ^b_reg;
                        else if (red_op_a_reg) out <= ^a_reg;
                        else if (red_op_b_reg) out <= ^b_reg;
                        else out <= a_reg ^ b_reg;
                    end
                    3'h2: begin // ADD (with optional carry-in)
                        if (FULL_ADDER == "ON") out <= a_reg + b_reg + cin_reg[0];
                        else out <= a_reg + b_reg;
                    end
                    3'h3: out <= a_reg * b_reg; // MULT
                    3'h4: begin // Shift, direction selects left/right, serial_in fills the vacated bit
                        if (direction_reg) out <= {out[4:0], serial_in_reg};
                        else out <= {serial_in_reg, out[5:1]};
                    end
                    3'h5: begin // Rotate
                        if (direction_reg) out <= {out[4:0], out[5]};
                        else out <= {out[0], out[5:1]};
                    end
                    default: out <= 0;
                endcase
            end
        end
    end

endmodule
