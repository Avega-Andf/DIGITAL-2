# Lab ab00 — Introducción a Verilog, Simulación y Máquinas de Estados Finitos (FSM)

**Curso:** [nombre del curso]
**Autor(es):** [tu nombre / integrantes del grupo]
**Universidad Nacional de Colombia — Sede Bogotá**

---

## 1. Objetivos

- Instalar y verificar el correcto funcionamiento de **Icarus Verilog** y **GTKWave**.
- Comprender la diferencia entre lógica combinacional y lógica secuencial.
- Diseñar e implementar **Máquinas de Estados Finitos (FSM)** sencillas en Verilog.
- Implementar sistemas que operan a lo largo de varios ciclos de reloj.
- Validar el comportamiento de los diseños mediante testbench y visualización de señales en GTKWave.

## 2. Entorno de trabajo

| Herramienta | Uso |
|---|---|
| Icarus Verilog (`iverilog`, `vvp`) | Compilación y simulación de los módulos HDL |
| GTKWave | Visualización de formas de onda (`.vcd`) |
| Visual Studio Code | Edición del código fuente |

**Smoke test:** antes de iniciar los ejercicios se compiló y simuló un módulo combinacional simple (`smoke_andor.v`), generando su `.vcd` y verificando las señales en GTKWave, con el fin de confirmar que el entorno de trabajo (Icarus Verilog + GTKWave) estaba correctamente instalado.

Comandos generales usados para compilar y simular cada ejercicio:

```bash
# Compilar
iverilog -o <nombre_tb>.vvp <testbench>.v <modulo>.v

# Simular (genera el .vcd)
vvp <nombre_tb>.vvp

# Visualizar ondas
gtkwave <archivo>.vcd
```

## 3. Estructura del repositorio

```
├── README.md
└── src/
    ├── semaforo.v
    ├── tb_semaforo.v
    ├── accumulator.v
    ├── tb_accumulator.v
    ├── serial_tx.v
    ├── tb_serial_tx.v
    └── waves/            # capturas de GTKWave
```

---

# Laboratorio: Diseños Secuenciales y FSMs en Verilog

## Punto 3.1: FSM de Control – Semáforo Simple (`semaforo.v`)

### 1. Descripción Técnica y Arquitectura HDL
El módulo **Semáforo** implementa una Máquina de Estados Finitas (FSM) de control para la gestión de tráfico vehicular. La transición de estados se realiza de forma automática mediante un contador interno de ciclos de reloj.

#### Estructura del Módulo HDL:
* **Registro de Estado y Reset**: Implementado mediante un bloque secuencial (`always @(posedge clk or posedge rst)`) con señal de reset activo en alto. Al activarse `rst = 1`, la FSM se fuerza inmediatamente al estado inicial `S0_GREEN` y reinicia el contador `count = 0`.
* **Lógica de Siguiente Estado**: Bloque combinacional que evalúa el estado actual (`state`) y el valor acumulado del contador (`count`) para determinar la siguiente transición.
* **Contador Interno**: Registro de 3 bits (`count`) que incrementa en cada flanco de subida del reloj para sostener la temporización requerida por cada luz antes de la transición.
* **Lógica de Salidas**: Salidas decodificadas según el estado actual. Se garantiza que solo una luz está activa a la vez:
  * `S0_GREEN`  $\rightarrow$ `green = 1`, `yellow1 = 0`, `red = 0`, `yellow2 = 0`
  * `S1_YELLOW1` $\rightarrow$ `green = 0`, `yellow1 = 1`, `red = 0`, `yellow2 = 0`
  * `S2_RED`     $\rightarrow$ `green = 0`, `yellow1 = 0`, `red = 1`, `yellow2 = 0`
  * `S3_YELLOW2` $\rightarrow$ `green = 0`, `yellow1 = 0`, `red = 0`, `yellow2 = 1`

#### Tabla de Estados y Temporización
| Estado | Código | Luz Activa | Duración (Ciclos) | Condición de Salida | Estado Siguiente |
| :--- | :---: | :---: | :---: | :---: | :---: |
| `S0_GREEN` | `2'b00` | `green` | 5 | `count == 4` | `S1_YELLOW1` |
| `S1_YELLOW1` | `2'b01` | `yellow1` | 2 | `count == 1` | `S2_RED` |
| `S2_RED` | `2'b10` | `red` | 4 | `count == 3` | `S3_YELLOW2` |
| `S3_YELLOW2` | `2 me` | `yellow2` | 2 | `count == 1` | `S0_GREEN` |

---

### 2. Diagrama de Estados
<img width="740" height="512" alt="image" src="https://github.com/user-attachments/assets/4b43fda9-54c7-47b4-9ced-243016bb14a8" />

---

### 3. Arquitectura del Testbench (`tb_semaforo.v`)
El banco de pruebas verifica la correcta secuencia y la duración de cada estado en ciclos de reloj mediante las siguientes etapas:
1. **Generación de Reloj**: Genera un reloj con un período constante de 10 ns (conmutación cada 5 ns: `#5 clk = ~clk`).
2. **Aplicación de Reset**: Se aplica un pulso inicial en alto (`rst = 1`) durante 20 ns para asegurar que la FSM comience en el estado `S0_GREEN` con `count = 0`, desactivándolo posteriormente (`rst = 0`).
3. **Sondeo de Estados**: Permite el funcionamiento continuo de la FSM durante 200 ns para verificar la secuencia repetitiva completa: $S0 \rightarrow S1 \rightarrow S2 \rightarrow S3 \rightarrow S0$.
4. **Generación de Archivo de Formas de Onda**: Utiliza las directivas `$dumpfile("semaforo.vcd")` y `$dumpvars(0, tb_semaforo)` para registrar todos los cambios de señales y permitir su análisis gráfico.

---

### 4. Evidencia de Simulación (GTKWave)
<img width="760" height="158" alt="image" src="https://github.com/user-attachments/assets/451e2780-a1ce-4014-9dcf-833095b469ae" />

#### Análisis de Resultados en Formas de Onda:
* **Reset**: En la ventana $0-20\text{ ns}$, con `rst = 1`, la salida activa es `green` y `count = 0`.
* **Estado Verde (`green`)**: Sostiene la luz verde activa durante 5 flancos de reloj (`count` de `000` a `100`).
* **Estado Amarillo 1 (`yellow1`)**: Permanece activo durante 2 flancos de reloj (`count` de `000` a `001`).
* **Estado Rojo (`red`)**: Permanece activo durante 4 flancos de reloj (`count` de `000` a `011`).
* **Estado Amarillo 2 (`yellow2`)**: Permanece activo durante 2 flancos de reloj (`count` de `000` a `001`) antes de reiniciar el ciclo completo a verde.

---

### 5. Comandos de Compilación y Ejecución

```bash
# Entrar al directorio de código fuente
cd src/

# Compilar el código RTL y el testbench
iverilog -o sim_semaforo.out tb_semaforo.v semaforo.v

# Ejecutar la simulación para generar el archivo VCD
vvp sim_semaforo.out

# Abrir el visor de ondas
gtkwave semaforo.vcd
```

## Ejercicio 2 — FSM con datapath: Acumulador secuencial

### Descripción


## Conclusiones


## Recursos



