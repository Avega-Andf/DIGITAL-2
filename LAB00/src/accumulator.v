module accumulator (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [3:0] x,
    output reg [5:0] acc,
    output reg done
);

    // Definición de Estados de la FSM
    localparam S0_IDLE = 2'b00;
    localparam S1_LOAD = 2'b01;
    localparam S2_ADD  = 2'b10;
    localparam S3_DONE = 2'b11;

    reg [1:0] state, next_state;
    reg [1:0] cnt; // Contador interno de ciclos (0 a 3)

    // 1. Registro de Estado (Lógica Secuencial)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S0_IDLE;
        end else begin
            state <= next_state;
        end
    end

    // 2. Lógica del Próximo Estado (Lógica Combinacional)
    always @(*) begin
        case (state)
            S0_IDLE: next_state = (start) ? S1_LOAD : S0_IDLE;
            S1_LOAD: next_state = S2_ADD;
            S2_ADD:  next_state = (cnt == 2'd3) ? S3_DONE : S2_ADD;
            S3_DONE: next_state = S0_IDLE;
            default: next_state = S0_IDLE;
        endcase
    end

    // 3. Datapath y Salidas (Lógica Secuencial y de Control)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            acc  <= 6'd0;
            cnt  <= 2'd0;
            done <= 1'b0;
        end else begin
            case (state)
                S0_IDLE: begin
                    done <= 1'b0;
                end
                S1_LOAD: begin
                    acc  <= 6'd0;
                    cnt  <= 2'd0;
                    done <= 1'b0;
                end
                S2_ADD: begin
                    acc  <= acc + x;
                    cnt  <= cnt + 2'd1;
                    done <= 1'b0;
                end
                S3_DONE: begin
                    done <= 1'b1;
                end
            endcase
        end
    end

endmodule