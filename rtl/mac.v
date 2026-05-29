// MAC Unit — Asynchronous Reset Version
// Used for: RTL simulation, synthesis, STA
// Note: Async reset causes X-propagation in ATPG; see mac_sync.v for DFT version

module mac #(parameter n = 32) (
    input  wire                  clk,
    input  wire                  rst,    // Asynchronous reset
    input  wire                  en,
    input  wire                  clr,
    input  wire signed [n-1:0]   a,
    input  wire signed [n-1:0]   b,
    output reg  signed [2*n-1:0] result,
    output reg                   valid
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result <= 0;
            valid  <= 1'b0;
        end
        else if (clr) begin
            result <= 0;
            valid  <= 1'b0;
        end
        else if (en) begin
            result <= result + (a * b);
            valid  <= 1'b1;
        end
        else begin
            valid  <= 1'b0;
        end
    end

endmodule
