`timescale 1ns/1ps

module tb_accumulator;

    // Entradas del testbench (reg)
    reg clk;
    reg rst;
    reg start;
    reg [3:0] x;

    // Salidas del módulo (wire)
    wire [5:0] acc;
    wire done;

    // Instancia del módulo a probar (UUT)
    accumulator uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .x(x),
        .acc(acc),
        .done(done)
    );

    // Generación del reloj (Periodo = 10ns -> 100MHz)
    always #5 clk = ~clk;

    initial begin
        // Configuración para guardar las ondas para GTKWave
        $dumpfile("accumulator.vcd");
        $dumpvars(0, tb_accumulator);

        // Inicialización de señales
        clk = 0;
        rst = 1;
        start = 0;
        x = 4'd0;

        // Reset inicial
        #15;
        rst = 0;
        #10;

        // --- PRUEBA 1: Acumular x = 5 (4 veces -> Total esperado: 20) ---
        x = 4'd5;
        start = 1;
        #10;
        start = 0; // Desactivar start tras el primer ciclo

        // Esperar a que complete el ciclo
        wait(done);
        #20;

        // --- PRUEBA 2: Acumular x = 3 (4 veces -> Total esperado: 12) ---
        x = 4'd3;
        start = 1;
        #10;
        start = 0;

        wait(done);
        #30;

        $display("Simulación completada con éxito.");
        $finish;
    end

endmodule