module fulladder8(
    input [7:0] A, B,
    input Pin,
    output [7:0] S,
    output Pout
);

    wire [6:0] P;
    
    fulladder a0(
        .a(A[0]),
        .b(B[0]),
        .Pin(Pin),
        .S(S[0]),
        .Pout(P[0])
    );
    
    fulladder a1(
        .a(A[1]),
        .b(B[1]),
        .Pin(P[0]),
        .S(S[1]),
        .Pout(P[1])
    );
    
    fulladder a2(
        .a(A[2]),
        .b(B[2]),
        .Pin(P[1]),
        .S(S[2]),
        .Pout(P[2])
    );
    
    fulladder a3(
        .a(A[3]),
        .b(B[3]),
        .Pin(P[2]),
        .S(S[3]),
        .Pout(P[3])
    );
    
    fulladder a4(
        .a(A[4]),
        .b(B[4]),
        .Pin(P[3]),
        .S(S[4]),
        .Pout(P[4])
    );
    
    fulladder a5(
        .a(A[5]),
        .b(B[5]),
        .Pin(P[4]),
        .S(S[5]),
        .Pout(P[5])
    );
    
    fulladder a6(
        .a(A[6]),
        .b(B[6]),
        .Pin(P[5]),
        .S(S[6]),
        .Pout(P[6])
    );
    
    fulladder a7(
        .a(A[7]),
        .b(B[7]),
        .Pin(P[6]),
        .S(S[7]),
        .Pout(Pout)
    );

endmodule