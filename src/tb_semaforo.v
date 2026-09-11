`timescale 1ns/1ps

module tb_semaforo;

    reg clk;
    reg rst;
    wire green;
    wire yellow;
    wire red;

    // Instancia del módulo
    semaforo uut (
        .clk(clk),
        .rst(rst),
        .green(green),
        .yellow(yellow),
        .red(red)
    );

    // Generador de reloj (10ns de período)
    always #5 clk = ~clk;

    initial begin
        // Instrucciones para guardar las señales para GTKWave
        $dumpfile("semaforo.vcd");
        $dumpvars(0, tb_semaforo);

        // Estado inicial
        clk = 0;
        rst = 1;

        // Liberar reset a los 20ns
        #20 rst = 0;

        // Correr la simulación por 200ns
        #200;

        $finish;
    end

endmodule