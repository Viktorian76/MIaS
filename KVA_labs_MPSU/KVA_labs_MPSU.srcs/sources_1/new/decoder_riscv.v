//`define LOW_BITS_OPCODE 7'b000_0011
`include "defines_riscv.v"

module decoder_riscv (
    input       [31:0]  fetched_instr_i,    // Инструкция для декодирования, считанная из памяти инструкций
    output  reg [1:0]   ex_op_a_sel_o,      // Управляющий сигнал мультиплексора для выбора первого операнда АЛУ
    output  reg [2:0]   ex_op_b_sel_o,      // Управляющий сигнал мультиплексора для выбора второго операнда АЛУ
    output  reg [4:0]   alu_op_o,           // Операция АЛУ
    output  reg         mem_req_o,          // Запрос на доступ к памяти (часть интерфейса памяти)
    output  reg         mem_we_o,           // Сигнал разрешения записи в память, «write enable» (при равенстве нулю происходит чтение)
    output  reg [2:0]   mem_size_o,         // Управляющий сигнал для выбора размера слова при чтении-записи в память (часть интерфейса памяти)
    output  reg         gpr_we_a_o,         // Сигнал разрешения записи в регистровый файл
    output  reg         wb_src_sel_o,       // Управляющий сигнал мультиплексора для выбора данных, записываемых в регистровый файл
    output  reg         illegal_instr_o,    // Сигнал о некорректной инструкции (на схеме не отмечен)
    output  reg         branch_o,           // Сигнал об инструкции условного перехода
    output  reg         jal_o,              // Сигнал об инструкции безусловного перехода jal
    output  reg         jalr_o              // Сигнал об инструкции безусловного перехода jalr
);

wire  [1:0] low_opcode  = fetched_instr_i[1:0];
wire  [4:0] high_opcode = fetched_instr_i[6:2];
wire  [6:0] rd      = fetched_instr_i[11:7];
wire  [2:0] func3   = fetched_instr_i[14:12];
wire  [6:0] func7   = fetched_instr_i[31:25];
wire  [11:0] func7_storage   = fetched_instr_i[31:20];

always @ * begin
    ex_op_a_sel_o   = `OP_A_RS1;
    ex_op_b_sel_o   = `OP_B_RS2;
    alu_op_o    = `ALU_ADD;
    mem_req_o   = 1'b0;
    mem_we_o    = 1'b0;
    mem_size_o  = `LDST_B;
    gpr_we_a_o  = 1'b0;
    wb_src_sel_o    = 1'b0;
    illegal_instr_o = 1'b0;
    branch_o    = 1'b0;
    jal_o   = 1'b0;
    jalr_o  = 1'b0;
    
    if (low_opcode != 2'b11)
        illegal_instr_o = 1'b1;
    else
        case (high_opcode)
            `OP_OPCODE: begin
                case (func3)
                    3'b000:
                        case (func7)
                            7'b000_0000: alu_op_o   = `ALU_ADD;
                            7'b010_0000: alu_op_o   = `ALU_SUB;
                            default: illegal_instr_o = 1'b1;
                        endcase
                    3'b001:
                        case (func7)
                            7'b000_0000:alu_op_o    = `ALU_SLL;
                            default: illegal_instr_o = 1'b1;
                        endcase
                    3'b010:
                        case (func7)
                            7'b000_0000:alu_op_o    = `ALU_SLTS;
                            default: illegal_instr_o = 1'b1;
                        endcase
                    3'b011:
                        case (func7)
                            7'b000_0000:alu_op_o    = `ALU_SLTU;
                            default: illegal_instr_o = 1'b1;
                        endcase
                    3'b100:
                        case (func7)
                            7'b000_0000:alu_op_o    = `ALU_XOR;
                            default: illegal_instr_o = 1'b1;
                        endcase
                    3'b101:
                        case (func7)
                            7'b000_0000:alu_op_o    = `ALU_SRL;
                            7'b010_0000: alu_op_o   = `ALU_SRA;
                            default: illegal_instr_o = 1'b1;
                        endcase   
                    3'b110:
                        case (func7)
                            7'b000_0000:alu_op_o    = `ALU_OR;
                            default: illegal_instr_o = 1'b1;
                        endcase
                    3'b111:
                        case (func7)
                            7'b000_0000:alu_op_o    = `ALU_AND;
                            default: illegal_instr_o = 1'b1;
                        endcase
                endcase
                gpr_we_a_o  = !illegal_instr_o;
            end
            
            `OP_IMM_OPCODE: begin
                ex_op_b_sel_o = `OP_B_IMM_I;
                case (func3)
                    3'b000:
                        alu_op_o   = `ALU_ADD;
                    3'b001:
                        case (func7)
                            7'b000_0000:alu_op_o    = `ALU_SLL;
                            default: illegal_instr_o = 1'b1;
                        endcase
                    3'b010:
                        alu_op_o    = `ALU_SLTS;
                    3'b011:
                        alu_op_o    = `ALU_SLTU;
                    3'b100:
                        alu_op_o    = `ALU_XOR;
                    3'b101:
                        case (func7)
                            7'b000_0000:alu_op_o    = `ALU_SRL;
                            7'b010_0000: alu_op_o   = `ALU_SRA;
                            default: illegal_instr_o = 1'b1;
                        endcase   
                    3'b110:
                        alu_op_o    = `ALU_OR;
                    3'b111:
                        alu_op_o    = `ALU_AND;
                endcase
                gpr_we_a_o = !illegal_instr_o;
            end
            
            `LUI_OPCODE: begin // Hmmmmmm...
                ex_op_a_sel_o   = `OP_A_ZERO;
                ex_op_b_sel_o   = `OP_B_IMM_U;
                gpr_we_a_o  = 1'b1;
            end
            
            `LOAD_OPCODE: begin
                ex_op_a_sel_o   = `OP_A_RS1;
                ex_op_b_sel_o   = `OP_B_IMM_I;
                wb_src_sel_o    = 1'b1;
                
                case (func3)
                    3'b000:
                        mem_size_o = `LDST_B;
                    3'b001:
                        mem_size_o = `LDST_H;
                    3'b010:
                        mem_size_o = `LDST_W;
                    3'b100:
                        mem_size_o = `LDST_BU;
                    3'b101:
                        mem_size_o = `LDST_HU;
                    default:
                        illegal_instr_o = 1'b1;
                endcase
                mem_req_o   = !illegal_instr_o;
                gpr_we_a_o  = !illegal_instr_o;
            end
            
            `STORE_OPCODE: begin
                ex_op_a_sel_o   = `OP_A_RS1;
                ex_op_b_sel_o   = `OP_B_IMM_S;
                case (func3)
                    3'b000:
                        mem_size_o = `LDST_B;
                    3'b001:
                        mem_size_o = `LDST_H;
                    3'b010:
                        mem_size_o = `LDST_W;
                    default:
                        illegal_instr_o = 1'b1;
                endcase
                mem_req_o   = !illegal_instr_o;
                mem_we_o    = !illegal_instr_o;
           end
           
           `BRANCH_OPCODE: begin
                ex_op_a_sel_o   = `OP_A_RS1;
                ex_op_b_sel_o   = `OP_B_RS2;
                case (func3)
                    3'b000:
                        alu_op_o = `ALU_EQ;
                    3'b001:
                        alu_op_o = `ALU_NE;
                    3'b100:
                        alu_op_o = `ALU_LTS;
                    3'b101:
                        alu_op_o = `ALU_GES;
                    3'b110:
                        alu_op_o = `ALU_LTU;
                    3'b111:
                        alu_op_o = `ALU_GEU;
                    default:
                        illegal_instr_o = 1'b1;
                endcase
                branch_o = !illegal_instr_o;
            end
            
            `JAL_OPCODE: begin
                ex_op_a_sel_o   = `OP_A_CURR_PC;
                ex_op_b_sel_o   = `OP_B_INCR;
                jal_o = 1'b1;              
                gpr_we_a_o = 1'b1;
            end
            
            `JALR_OPCODE: begin
                if (func3 == 3'b000) begin
                    ex_op_a_sel_o   = `OP_A_CURR_PC;
                    ex_op_b_sel_o   = `OP_B_INCR;
                    jalr_o = 1'b1;              
                end else
                    illegal_instr_o = 1'b1;
                    
                gpr_we_a_o = !illegal_instr_o;
            end
            
            `AUIPC_OPCODE: begin
                ex_op_a_sel_o   = `OP_A_CURR_PC;
                ex_op_b_sel_o   = `OP_B_IMM_U;
                alu_op_o    = `ALU_ADD;
                gpr_we_a_o  = 1'b1;
            end
            
            `MISC_MEM_OPCODE: begin
                case (func3)
                    3'b000: illegal_instr_o = 1'b0;
                    default:
                        illegal_instr_o = 1'b1;
                endcase
            end
            
            `SYSTEM_OPCODE: begin
                if (fetched_instr_i[19:7] == 13'b0)
                    case (func7_storage)
                        12'b0000_0000_0000: illegal_instr_o = 1'b0;
                        12'b0000_0000_0001: illegal_instr_o = 1'b0;
                        default:
                            illegal_instr_o = 1'b1;
                    endcase
                else
                    illegal_instr_o = 1'b1;
            end
            default:
                 illegal_instr_o = 1'b1;
        endcase
end

endmodule