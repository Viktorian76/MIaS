`include "defines_riscv.v"

module alu_riscv (
    input [31:0] A,
    input [31:0] B,
    input [4:0] ALUOp,
    output reg      Flag,
    output reg [31:0] Result
);

wire [31:0] sum_w;
wire   [31:0] sub_w;

//fulladder32 summator(
//    .A(A[31:0]),
//    .B(B[31:0]),
//    .Pin(1'b0),
//    .S(sum_w[31:0])
//);
    
fulladder32 sum(
    .A(A[31:0]),
    .B(ALUOp[3]?~B[31:0] : B[31:0]),
    .Pin(ALUOp[3]),
    .S(sum_w[31:0])
);
    
// My code
always @(*) begin
// For Result, Flag = 0
case (ALUOp)
        `ALU_ADD:   Result = sum_w;
        `ALU_SUB:   Result = sum_w;
        `ALU_SLL:   Result = A << B[4:0];
        `ALU_SLTS:  Result = $signed(A) < $signed(B);
        `ALU_SLTU:  Result = A < B;
        `ALU_XOR:   Result = A ^ B;
        `ALU_SRL:   Result = A >> B[4:0];
        `ALU_SRA:   Result = $signed(A) >>> B[4:0];
        `ALU_OR:    Result = A | B;
        `ALU_AND:   Result = A & B;
        default:    Result = 32'b0;
    endcase
    // For For, Result = 0;
    case (ALUOp)
        `ALU_EQ:    Flag = A == B;
        `ALU_NE:    Flag = A != B;
        `ALU_LTS:   Flag = $signed(A) < $signed(B);
        `ALU_GES:   Flag = $signed(A) >= $signed(B);
        `ALU_LTU:   Flag = A < B;
        `ALU_GEU:   Flag = A >= B;
        default:    Flag = 1'b0;
    endcase

end

endmodule

