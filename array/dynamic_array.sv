//-----------------------------------------------------------------------------
// Module      : test_dyn_array
// Description : Exercises SystemVerilog dynamic-array construction, sizing,
//               deletion, and the built-in reverse/sort/rsort/shuffle
//               methods.
//-----------------------------------------------------------------------------
module test_dyn_array ();

    int dyn_arr1[];
    int dyn_arr2[];

    initial begin
        dyn_arr2 = {9, 1, 8, 3, 4, 4};

        dyn_arr1 = new[6];
        foreach (dyn_arr1[i]) begin
            dyn_arr1[i] = i;
        end
        for (int i = 0; i < $size(dyn_arr1); i++) begin
            $display("dyn_arr1[%0d] = %0d \n", i, dyn_arr1[i]);
        end
        dyn_arr1.delete();

        // Reverse, sort, reverse-sort and shuffle dyn_arr2, displaying it
        // after each method.
        $display("dyn_arr2 before changing = %p \n", dyn_arr2);
        dyn_arr2.reverse();
        $display("dyn_arr2 reverse = %p \n", dyn_arr2);
        dyn_arr2.sort();
        $display("dyn_arr2 sort = %p \n", dyn_arr2);
        dyn_arr2.rsort();
        $display("dyn_arr2 rsort = %p \n", dyn_arr2);
        dyn_arr2.shuffle();
        $display("dyn_arr2 shuffle = %p \n", dyn_arr2);
    end

endmodule
