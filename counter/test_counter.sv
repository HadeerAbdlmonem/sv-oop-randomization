//-----------------------------------------------------------------------------
// Testbench   : counter_tb
// Description : Randomized self-checking testbench for the counter module.
//               A reference (golden) model tracks the expected count_out,
//               max_count and zero values and compares them every cycle.
//-----------------------------------------------------------------------------
import counter_pkg::*;

module counter_tb ();

    parameter WIDTH = counter_pkg::WIDTH;

    reg                clk;
    reg                rst_n;
    reg                load_n;
    reg                up_down;
    reg                ce;
    reg  [WIDTH-1:0]   data_load;
    wire [WIDTH-1:0]   count_out;
    wire               max_count;
    wire               zero;

    int error_count = 0;
    bit [WIDTH-1:0] count_out_expected = 0;
    bit zero_expected, max_count_expected;

    counter dut (.*);

    initial begin
        clk = 0;
        forever begin
            #1;
            clk = ~clk;
        end
    end

    initial begin
        counter_stimulus obj = new();

        assert_reset();
        @(posedge clk);
        rst_n = 1'b1;
        if (count_out != 0) begin
            $display("ERROR: count_out did not clear on rst_n \n");
            error_count++;
        end

        for (int i = 0; i < 1000; i++) begin
            obj.randomize();
            up_down   = $random;
            data_load = $random;
            load_n    = obj.load_n;
            ce        = obj.ce;
            rst_n     = obj.rst_n;
            check_count_outputs();
        end

        $display(" ---> error count = %0d", error_count);
        $stop();
    end

    task assert_reset();
        rst_n = 0;
    endtask

    task check_count_outputs();
        @(negedge clk);
        if ((count_out != count_out_expected) || max_count != max_count_expected || zero != zero_expected) begin
            error_count++;
        end
    endtask

    // Golden model: mirrors the DUT's counting behavior
    always @(posedge clk) begin
        if (!rst_n) begin
            count_out_expected = 0;
            max_count_expected = 0;
            zero_expected      = 1;
        end
        else if (!load_n) count_out_expected = data_load;
        else if (ce) begin
            if (up_down) count_out_expected = count_out_expected + 1;
            else count_out_expected = count_out_expected - 1;
        end

        max_count_expected = (count_out_expected == {WIDTH{1'b1}}) ? 1 : 0;
        zero_expected      = (count_out_expected == 0) ? 1 : 0;
    end

endmodule
