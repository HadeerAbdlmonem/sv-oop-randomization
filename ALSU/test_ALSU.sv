//-----------------------------------------------------------------------------
// Testbench   : alsu_tb
// Description : Randomized self-checking testbench for the alsu module.
//               A reference (golden) model runs in parallel on the same
//               registered inputs and out/leds are compared against it
//               every cycle.
//-----------------------------------------------------------------------------
import my_pkg::*;

module alsu_tb ();

    // Signals driven into the DUT
    bit clk, rst, red_op_a, red_op_b, bypass_a, bypass_b, direction, serial_in;
    bit [1:0] cin;
    opcode_e opcode;
    bit signed [2:0] a, b;
    bit [15:0] leds;
    bit signed [5:0] out;

    int error_count = 0;

    // Golden-model (reference) values
    bit [5:0]  out_expected;
    bit [15:0] leds_expected;
    reg signed [2:0] a_reg;
    reg signed [2:0] b_reg;
    reg signed [1:0] cin_reg;
    reg              serial_in_reg;
    reg              red_op_a_reg;
    reg              red_op_b_reg;
    reg [2:0]        opcode_reg;
    reg              bypass_a_reg;
    reg              bypass_b_reg;
    reg              direction_reg;

    bit invalid;

    assign invalid = (red_op_a_reg | red_op_b_reg) & (opcode_reg[1] | opcode_reg[2])
                   || (opcode_reg[1] & opcode_reg[2]);

    design_inputs obj;

    alsu dut (
        .clk       (clk),
        .rst       (rst),
        .a         (a),
        .b         (b),
        .cin       (cin),
        .serial_in (serial_in),
        .red_op_a  (red_op_a),
        .red_op_b  (red_op_b),
        .opcode    (opcode),
        .bypass_a  (bypass_a),
        .bypass_b  (bypass_b),
        .direction (direction),
        .leds      (leds),
        .out       (out)
    );

    initial begin
        clk = 0;
        forever begin
            #1;
            clk = ~clk;
        end
    end

    initial begin
        rst = 1'b1; // Reset all inputs initially
        @(posedge clk);
        rst = 1'b0;
        obj = new();
        for (int i = 0; i < 10000; i++) begin
            assert (obj.randomize());
            cin       = obj.cin;
            rst       = obj.rst;
            red_op_a  = obj.red_op_A;
            red_op_b  = obj.red_op_B;
            bypass_a  = obj.bypass_A;
            bypass_b  = obj.bypass_B;
            direction = obj.direction;
            serial_in = obj.serial_in;
            opcode    = obj.opcode;
            a         = obj.A;
            b         = obj.B;
            check_results();
        end

        // Two more directed iterations to close remaining coverage holes
        red_op_a  = 1'b1;
        red_op_b  = 1'b1;
        bypass_a  = 0;
        bypass_b  = 0;
        opcode    = Opcode_Or;
        check_results();

        red_op_a  = 1'b1;
        red_op_b  = 1'b1;
        bypass_a  = 0;
        bypass_b  = 0;
        opcode    = Opcode_Xor;
        check_results();

        $display("Error Count = %0d \n", error_count);
        $stop();
    end

    task check_results();
        @(negedge clk);
        @(negedge clk);
        if (out != out_expected || leds != leds_expected) begin
            error_count++;
            $display("out=%b out_expected=%b leds=%b leds_expected=%b time=%0t \n",
                      out, out_expected, leds, leds_expected, $time);
        end
    endtask

    // Golden-model input registration, mirrors the DUT's input register stage.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_reg         <= 0;
            b_reg         <= 0;
            opcode_reg    <= 0;
            cin_reg       <= 0;
            serial_in_reg <= 0;
            direction_reg <= 0;
            red_op_a_reg  <= 0;
            red_op_b_reg  <= 0;
            bypass_a_reg  <= 0;
            bypass_b_reg  <= 0;
        end
        else begin
            a_reg         <= a;
            b_reg         <= b;
            opcode_reg    <= opcode;
            cin_reg       <= cin;
            serial_in_reg <= serial_in;
            direction_reg <= direction;
            red_op_a_reg  <= red_op_a;
            red_op_b_reg  <= red_op_b;
            bypass_a_reg  <= bypass_a;
            bypass_b_reg  <= bypass_b;
        end
    end

    // Golden-model LED behavior
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            leds_expected <= 0;
        end
        else begin
            if (invalid) leds_expected <= ~leds_expected;
            else leds_expected <= 0;
        end
    end

    // Golden-model output computation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out_expected <= 0;
        end
        else begin
            if ((bypass_a_reg && !bypass_b_reg) || (bypass_b_reg && !bypass_a_reg)) begin
                // Exactly one of bypass_a_reg / bypass_b_reg is high
                out_expected <= (bypass_a_reg) ? a_reg : b_reg;
            end
            else if (bypass_a_reg && bypass_b_reg) begin
                out_expected <= a_reg; // default INPUT_PRIORITY = "A"
            end
            else if (invalid) begin
                out_expected <= 0;
            end
            else begin
                case (opcode_reg)
                    3'b000: begin
                        if (red_op_a_reg == 0 && red_op_b_reg == 0) begin
                            out_expected <= a_reg | b_reg;
                        end
                        else if (red_op_a_reg == 1 && red_op_b_reg == 1) begin
                            out_expected <= |a_reg; // default INPUT_PRIORITY = "A"
                        end
                        else begin
                            out_expected <= (red_op_a_reg == 1) ? |a_reg : |b_reg;
                        end
                    end
                    3'b001: begin
                        if (red_op_a_reg == 0 && red_op_b_reg == 0) begin
                            out_expected <= a_reg ^ b_reg;
                        end
                        else if (red_op_a_reg == 1 && red_op_b_reg == 1) begin
                            out_expected <= ^a_reg; // default INPUT_PRIORITY = "A"
                        end
                        else begin
                            out_expected <= (red_op_a_reg == 1) ? (^a_reg) : (^b_reg);
                        end
                    end
                    3'b010: out_expected <= a_reg + b_reg + cin_reg[0]; // default FULL_ADDER = "ON"
                    3'b011: out_expected <= a_reg * b_reg;
                    3'b100: begin // shift by 1
                        out_expected <= (direction_reg) ? {out_expected[4:0], serial_in_reg}
                                                         : {serial_in_reg, out_expected[5:1]};
                    end
                    3'b101: begin // rotate by 1
                        out_expected <= (direction_reg) ? {out_expected[4:0], out_expected[5]}
                                                         : {out_expected[0], out_expected[5:1]};
                    end
                    default: out_expected <= 0;
                endcase
            end
        end
    end

endmodule
