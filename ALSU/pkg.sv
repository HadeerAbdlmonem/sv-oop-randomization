//-----------------------------------------------------------------------------
// Package     : my_pkg
// Description : Opcode enum and the randomized input-generation class used
//               by the alsu testbench.
//-----------------------------------------------------------------------------
package my_pkg;

    typedef enum bit [2:0] {
        Opcode_Or,
        Opcode_Xor,
        Opcode_Add,
        Opcode_Mult,
        Opcode_Shift_by_1,
        Opcode_Rotate_by_1,
        INVALID_6,
        INVALID_7
    } opcode_e;

    localparam bit [2:0] MAXPOS = 3'b011;
    localparam bit [2:0] ZERO   = 3'b000;
    localparam bit [2:0] MAXNEG = 3'b100; // -4 in 2's complement

    class design_inputs;
        rand bit rst, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in;
        rand bit [1:0] cin;
        rand opcode_e opcode;
        rand bit [2:0] A, B;

        // Reset asserted with a low probability.
        constraint reset {
            rst dist {
                1'b0 :/ 80,
                1'b1 :/ 20
            };
        }

        // Constrain the adder/multiplier operands to hit corner cases
        // (ZERO, MAXNEG, MAXPOS) most of the time. Leave A/B unconstrained
        // for shift/rotate opcodes.
        constraint A_corner_case_inputs {
            ((opcode == Opcode_Add) || opcode == Opcode_Mult) ->
            (A dist {
                ZERO   := 2,
                MAXNEG := 2,
                MAXPOS := 2
            });
        }

        constraint B_corner_case_inputs {
            ((opcode == Opcode_Add) || opcode == Opcode_Mult) ->
            (B dist {
                ZERO   := 2,
                MAXNEG := 2,
                MAXPOS := 2
            });
        }

        // When opcode is OR/XOR and red_op_A is high, bias A to have exactly
        // one bit set while B is held low. Same idea for red_op_B below.
        constraint one_bit_of_A_is_high {
            ((opcode == Opcode_Or || opcode == Opcode_Xor) && red_op_A == 1'b1) ->
            (A inside {3'b100, 3'b010, 3'b001} && B == 0);
        }

        constraint one_bit_of_B_is_high {
            ((opcode == Opcode_Or || opcode == Opcode_Xor) && red_op_B == 1'b1) ->
            (B inside {3'b100, 3'b010, 3'b001} && A == 0);
        }

        // Invalid opcodes should occur less frequently than valid ones.
        constraint opcode_constraints {
            opcode dist {
                [INVALID_6:INVALID_7]           := 10,
                [Opcode_Or:Opcode_Rotate_by_1]  := 90
            };
        }

        // bypass_A / bypass_B disabled most of the time.
        constraint bypass_A_bypass_B {
            bypass_A dist {
                0 := 90,
                1 := 10
            };
            bypass_B dist {
                0 := 90,
                1 := 10
            };
        }

    endclass

endpackage
