//-----------------------------------------------------------------------------
// Package     : counter_pkg
// Description : Counter width parameter and the randomized control-signal
//               stimulus class used by the counter testbench.
//-----------------------------------------------------------------------------
package counter_pkg;

    parameter WIDTH = 4;

    class counter_stimulus;
        rand bit rst_n, load_n, ce;

        constraint reset_constraint {
            rst_n dist { 1'b1 :/ 20, 1'b0 :/ 80 };
        }
        constraint load_signal_constraint {
            load_n dist { 1'b0 :/ 30, 1'b1 :/ 70 };
        }
        constraint enable_constraint {
            ce dist { 1'b0 :/ 30, 1'b1 :/ 70 };
        }
    endclass

endpackage
