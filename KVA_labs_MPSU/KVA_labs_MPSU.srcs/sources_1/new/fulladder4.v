module fulladder4(
    input [3:0] A, B,
    input Pin,
    output [3:0] S,
    output Pout
);

    wire [2:0] P;
    
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
        .Pout(Pout)
    );
    

endmodule