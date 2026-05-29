// Scan Chain Verification Testbench
// Tests: (1) scan shift mode — 13-cycle latency  (2) functional mode post-scan
// Run: iverilog -o sim tb_mac_scan.v mac_scan_manual.v <path>/osu018_stdcells.v && vvp sim

`timescale 1ns/1ps

module tb_mac_scan;

    reg              clk;
    reg              rst;
    reg              en;
    reg              clr;
    reg              shift;

    reg  signed [31:0] a, b;

    reg  [4:0] sin;
    wire [4:0] sout;

    wire signed [63:0] result;
    wire               valid;

    // DUT — scan-inserted MAC (5 chains × 13 FFs)
    mac uut (
        .clk    (clk),
        .rst    (rst),
        .en     (en),
        .clr    (clr),
        .a      (a),
        .b      (b),
        .result (result),
        .valid  (valid),
        .shift  (shift),
        .sin    (sin),
        .sout   (sout)
    );

    always #5 clk = ~clk;

    integer i;

    initial begin
        $dumpfile("scan.vcd");
        $dumpvars(0, tb_mac_scan);

        // Initialization
        clk = 0; rst = 1; en = 0; clr = 0; shift = 0; sin = 0; a = 0; b = 0;
        #20;
        rst = 0;

        // ---- SCAN SHIFT TEST ----
        // Expected: data applied to sin[i] appears at sout[i] exactly 13 cycles later
        shift = 1;
        $display("---- SCAN SHIFT TEST (13-cycle latency expected) ----");
        for (i = 0; i < 20; i = i + 1) begin
            sin = i;
            #10;
            $display("Cycle %2d | sin=%b | sout=%b", i, sin, sout);
        end

        // ---- FUNCTIONAL TEST ----
        // Confirms scan mux did not break original combinational data path
        $display("\n---- FUNCTIONAL TEST ----");
        shift = 0;
        en    = 1;
        a     = 10;
        b     = 5;
        #50;
        $display("Result = %0d (Expected ~500 after ~5 accumulations)", result);

        #50;
        $finish;
    end

endmodule
