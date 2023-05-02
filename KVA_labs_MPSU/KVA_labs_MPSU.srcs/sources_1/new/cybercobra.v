module CYBERcobra (
    input       clk_i,
    input       rst_i,
    input   [15:0]  sw_i,
    output  [31:0]  out_o
);

reg  [31:0] PC;
wire [31:0] PC_in;
wire [31:0] instruct;
wire [31:0] res1;
wire [31:0] res2;
wire [31:0] alu_res;
wire        flag;
reg  [31:0] WD;
wire [31:0] sum_in;

always @ (posedge clk_i) 
    if (rst_i)
        PC <= 32'b0;
    else
        PC <= PC_in;
        
assign sum_in = ( (flag & instruct[30]) | instruct[31] ) ? ({ {22{instruct[12]}} , instruct[12:5], 2'b0}) : 32'd4;
        
fulladder32 summator(
    .A(PC[31:0]),
    .B(sum_in), // temp=============================
    .Pin(1'b0),
    .S(PC_in[31:0])
);      

instr_mem instr_mem(
    .addr(PC),
    .read_data(instruct)
);

always @(*) begin
    case (instruct[29:28])
            2'b00:   WD = { {9{instruct[27]}} , instruct[27:5]}; ///concat===========================================
            2'b01:   WD = alu_res;
            2'b10:   WD = { {16{sw_i[15]}} , sw_i}; ///concat===========================================
            default: WD = 32'd0;
        endcase
end

rf_riscv reg_file(
    .clk(clk_i),
    .WE(~(instruct[31] | instruct[30])),
    
    .A1(instruct[22:18]),
    .A2(instruct[17:13]),
    .A3(instruct[4:0]),
    
    .WD3(WD),
    .RD1(res1[31:0]),
    .RD2(res2[31:0])
);


assign out_o = res1;

alu_riscv  alu(
    .A(res1[31:0]),
    .B(res2[31:0]),
    .ALUOp(instruct[27:23]),
    .Flag(flag),
    .Result(alu_res)
);


endmodule