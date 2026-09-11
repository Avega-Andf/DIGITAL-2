`timescale 1ns/1ps

module tb_serial_tx;

    parameter CLKS_PER_BIT = 8;

    // Entradas del UUT (reg)
    reg clk;
    reg rst;
    reg start;
    reg [7:0] data_in;

    // Salidas del UUT (wire)
    wire tx;
    wire busy;
    wire done;

    // Instancia del transmisor
    serial_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(data_in),
        .tx(tx),
        .busy(busy),
        .done(done)
    );

    // Generador de Reloj (Periodo = 10ns)
    always #5 clk = ~clk;

    initial begin
        // Archivo de ondas para GTKWave
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_serial_tx);

        // Inicialización
        clk = 0;
        rst = 1;
        start = 0;
        data_in = 8'h00;

        // Reset inicial
        #20;
        rst = 0;
        #20;

        // --- PRUEBA 1: Transmitir 8'hA5 (10100101b) ---
        data_in = 8'hA5;
        start = 1;
        #10;          // Pulso de start de exactamente 1 ciclo
        start = 0;

        wait(done);
        #30;

        // --- PRUEBA 2: Transmitir 8'h3C (00111100b) ---
        data_in = 8'h3C;
        start = 1;
        #10;          // Pulso de start de exactamente 1 ciclo
        start = 0;

        wait(done);
        #50;

        $display("Simulación completada exitosamente.");
        $finish;
    end

endmodule