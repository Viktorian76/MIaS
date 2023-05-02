module data_mem(
    input       clk,
    input       WE,
    input   [31:0] addr,
    input   [31:0] write_data,
    input   [31:0] read_data
);
    reg [7:0] RAM[0:1023];
    
    assign read_data = {RAM[addr + 3], RAM[addr + 2], RAM[addr + 1], RAM[addr]};
    
    always @ (posedge clk)
        if (WE)
            {RAM[addr + 3], RAM[addr + 2], RAM[addr + 1], RAM[addr]} = write_data;

endmodule