// Testbench for MAC Unit
// Tests: basic accumulation, single multiply, signed negative operands
// Run: iverilog mac.v tb_mac.v && vvp a.out

`timescale 1ns/1ps

module tb_mac;

    parameter n = 32;

    reg                  clk;
    reg                  rst;
    reg                  en;
    reg                  clr;
    reg  signed [n-1:0]  a;
    reg  signed [n-1:0]  b;
    wire signed [2*n-1:0] result;
    wire                 valid;

    // DUT instantiation
    mac #(n) dut (
        .clk    (clk),
        .rst    (rst),
        .en     (en),
        .clr    (clr),
        .a      (a),
        .b      (b),
        .result (result),
        .valid  (valid)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    initial begin
        $dumpfile("mac.vcd");
        $dumpvars(0, tb_mac);
        $sdf_annotate("mac.sdf", dut);

        // Initialization
        clk = 0; rst = 1; en = 0; clr = 0; a = 0; b = 0;
        #10;
        rst = 0;
        #10;

        // ---- Test 1: 3*4 + 2*5 = 22 ----
        clr = 1; #10; clr = 0;
        en = 1;
        a = 3; b = 4; #10;
        a = 2; b = 5; #10;
        en = 0; #10;
        $display("Test 1 — Got: %0d (Expected: 22)", result);
        if (result == 22) $display("PASS\n");
        else              $display("FAIL\n");
        #10;

        // ---- Test 2: 1*1 = 1 ----
        clr = 1; #10; clr = 0;
        en = 1;
        a = 1; b = 1; #10;
        en = 0; #10;
        $display("Test 2 — Got: %0d (Expected: 1)", result);
        if (result == 1) $display("PASS\n");
        else             $display("FAIL\n");
        #10;

        // ---- Test 3: (-1)*(-5) = 5 ----
        clr = 1; #10; clr = 0;
        en = 1;
        a = -1; b = -5; #10;
        en = 0; #10;
        $display("Test 3 — Got: %0d (Expected: 5)", result);
        if (result == 5) $display("PASS\n");
        else             $display("FAIL\n");
        #10;

        $finish;
    end

endmodule
