module semaforo (
    input wire clk,
    input wire rst,
    output reg green,
    output reg yellow,
    output reg red
);

    // Codificación de los 3 estados
    localparam S0_GREEN  = 2'b00;
    localparam S1_YELLOW = 2'b01;
    localparam S2_RED    = 2'b10;

    reg [1:0] state, next_state;
    reg [2:0] count, next_count;

    // 1. Memoria/Registros (Lógica secuencial)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S0_GREEN;
            count <= 3'd0;
        end else begin
            state <= next_state;
            count <= next_count;
        end
    end

    // 2. Transiciones de estado (Lógica combinacional)
    always @(*) begin
        next_state = state;
        next_count = count + 1'b1;

        case (state)
            S0_GREEN: begin
                if (count == 3'd4) begin // 5 ciclos (0 a 4)
                    next_state = S1_YELLOW;
                    next_count = 3'd0;
                end
            end
            S1_YELLOW: begin
                if (count == 3'd1) begin // 2 ciclos (0 a 1)
                    next_state = S2_RED;
                    next_count = 3'd0;
                end
            end
            S2_RED: begin
                if (count == 3'd3) begin // 4 ciclos (0 a 3)
                    next_state = S0_GREEN;
                    next_count = 3'd0;
                end
            end
            default: begin
                next_state = S0_GREEN;
                next_count = 3'd0;
            end
        endcase
    end

    // 3. Salidas tipo Moore
    always @(*) begin
        green  = (state == S0_GREEN);
        yellow = (state == S1_YELLOW);
        red    = (state == S2_RED);
    end

endmodule
