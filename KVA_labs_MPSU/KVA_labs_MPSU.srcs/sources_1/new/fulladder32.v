module fulladder32(
    input [31:0] A, B,
    input Pin,
    output Pout,
    output [31:0] S
);

    wire P[2:0];
    
    fulladder8 b0(
        .A(A[7:0]),
        .B(B[7:0]),
        .Pin(Pin),
        .S(S[7:0]),
        .Pout(P[0])
    );
    
    fulladder8 b1(
        .A(A[15:8]),
        .B(B[15:8]),
        .Pin(P[0]),
        .S(S[15:8]),
        .Pout(P[1])
    );
    
    fulladder8 b2(
        .A(A[23:16]),
        .B(B[23:16]),
        .Pin(P[1]),
        .S(S[23:16]),
        .Pout(P[2])
    );
    
    fulladder8 b3(
        .A(A[31:24]),
        .B(B[31:24]),
        .Pin(P[2]),
        .S(S[31:24]),
        .Pout(Pout)
    );

endmodule
