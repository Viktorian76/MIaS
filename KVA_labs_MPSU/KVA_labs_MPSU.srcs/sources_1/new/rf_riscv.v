module  rf_riscv(
    input         clk,
    input         WE,
    
    input   [4:0] A1,
    input   [4:0] A2,
    input   [4:0] A3,
    
    input   [31:0] WD3,
    output  [31:0] RD1,
    output  [31:0] RD2
);

    reg [31:0] RAM[0:31];

    initial begin
        RAM[0] = 32'b0;
    end
    
    assign RD1 = /*(A1 == 5'b0)? 32'b0 :*/ RAM[A1];
    assign RD2 = /*(A2 == 5'b0)? 32'b0 :*/ RAM[A2];

    always @ (posedge clk)
        if (WE && (A3 != 5'b0))
            RAM[A3] <= WD3;
endmodule