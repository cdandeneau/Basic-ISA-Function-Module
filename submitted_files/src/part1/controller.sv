module controller #(parameter WIDTH = 16,
            parameter INSTR_LEN = 20,
            parameter ADDR = 5) (
    input  logic        clk,
    input  logic        reset,
    input logic         go,
    input  logic [INSTR_LEN-1:0] instruction,
    input  logic        done,
    output logic        enable,
    output logic [ADDR-1:0]  pc,
    output logic [3:0]  opcode,
    output logic [7:0]  a, b,
    output logic invalid_opcode
);

// Your code here

    typedef enum logic [3:0] {
        IDLE, HALT, FETCH, LATCH_INSTR, DECODE, EXECUTE
    } state_type;

    state_type state_r, next_state;
    logic [INSTR_LEN-1:0] ir;
    logic [ADDR-1:0] pc_reg;

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin
            state_r <= IDLE;
            pc_reg <= '0;
            ir <= '0;
        end else begin
            state_r <= next_state;

            if (state_r == LATCH_INSTR) begin
                ir <= instruction;
            end   
            if ((state_r == EXECUTE || state_r == HALT) && done) begin
                pc_reg <= pc_reg + 1'b1;
            end
        end
    end

    always_comb begin
        next_state = state_r;

        enable = 1'b0;
        invalid_opcode = 1'b0;

        pc = pc_reg;
        opcode = ir[19:16];
        a = ir[15:8];
        b = ir[7:0];

        case(state_r)

        IDLE: begin
            if (go) begin
                next_state = FETCH;
            end
        end

        FETCH: begin
            next_state = LATCH_INSTR;
        end

        LATCH_INSTR: begin
                next_state = DECODE;
            end

        DECODE: begin
            if (opcode == 4'b1111) begin
                next_state = HALT;
            end else begin
                next_state = EXECUTE;
            end
        end

        HALT: begin
            enable = 1'b1;
            if (done) begin
                next_state = IDLE;
            end
        end

        EXECUTE: begin
            enable = 1'b1;

            if (opcode != 4'b0001 && opcode != 4'b0010 && opcode != 4'b0011 && opcode != 4'b1011 && opcode != 4'b1111) begin
                invalid_opcode = 1'b1;
            end
            if (done) begin
                next_state = IDLE;
            end else begin
                next_state = EXECUTE;
            end
        end

        endcase
        
    end



endmodule










