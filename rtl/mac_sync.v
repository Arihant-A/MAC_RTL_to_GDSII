// MAC Unit — Synchronous Reset Version (DFT-Friendly)
// Used for: DFT, ATPG, scan chain insertion
// Reason: Async reset causes unknown ('X') propagation during ATPG.
//         Synchronous reset makes all flip-flops fully controllable.

`timescale 1ns/1ps

module mac #(parameter n = 32) (
    input  wire                  clk,
    input  wire                  rst,    // Synchronous reset
    input  wire                  en,
    input  wire                  clr,
    input  wire signed [n-1:0]   a,
    input  wire signed [n-1:0]   b,
    output reg  signed [2*n-1:0] result,
    output reg                   valid
);

    always @(posedge clk) begin
        if (rst || clr) begin
            result <= 0;
            valid  <= 0;
        end
        else if (en) begin
            result <= result + (a * b);
            valid  <= 1;
        end
        else begin
            valid  <= 0;
        end
    end

endmodule
