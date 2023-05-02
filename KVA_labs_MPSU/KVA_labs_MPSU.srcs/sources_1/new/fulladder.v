module fulladder(
    input a, b, Pin,
    output S, Pout
);

assign S = (a ^ b) ^ (Pin);
assign Pout = ((a & b) | (a & Pin))|(b & Pin);


endmodule
