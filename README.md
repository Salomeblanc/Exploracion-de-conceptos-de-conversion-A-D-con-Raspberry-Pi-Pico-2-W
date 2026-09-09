# Exploracion-de-conceptos-de-conversion-A-D-con-Raspberry-Pi-Pico-2-W

Práctica de laboratorio de **Comunicaciones Digitales** — Programa de Ingeniería en Telecomunicaciones, Universidad Militar Nueva Granada (UMNG).

Autores: **Harol Felipe Riveros Sierra** (1401660) · **Salome Bohorquez Blanco** (1401654)
Docente: Ing. José de Jesús Rugeles Uribe

## Descripción

Este repositorio contiene el desarrollo completo de la práctica de laboratorio sobre conversión analógico-digital (ADC) usando una **Raspberry Pi Pico 2 W** (microcontrolador RP2350, resolución nominal de 12 bits). La práctica se divide en dos partes:

- **Parte I — Muestreo de una señal senoidal.** Se adquiere una señal senoidal por el pin `GP26` y se genera un pulso digital en `GP15` en cada instante de muestreo, permitiendo medir experimentalmente la frecuencia de muestreo `Fs`, la frecuencia de la señal de entrada `f_in` y el número de muestras por período `Ns = Fs/f_in`.
- **Parte II — Caracterización estadística del ADC.** Se aplican distintos niveles de tensión DC a la entrada `GP26/ADC0` y se toman 10 000 mediciones por ensayo, calculando media, varianza, desviación estándar y distribución de los códigos digitales de 12 bits, para analizar repetibilidad, exactitud y ruido de cuantización.

## Estructura del repositorio

```
primer laboratorio segundo corte/
├── ADC_LAB.pdf                          # Guía de laboratorio
├── 5 INFORME COMUNICACION DIGITAL (...).docx/.pdf   # Informe final
├── analisis_ADC.m                       # Script MATLAB de post-procesamiento (Parte II)
├── resumen_resultados_matlab.csv        # Resumen numérico generado por analisis_ADC.m
│
├── 2 parte/                             # Parte I: muestreo de la señal senoidal
│   ├── sampling_1.py                    # Código MicroPython (RP2350)
│   ├── datos.csv                        # 10 000 muestras (Sample, Time_us, Raw_u16, Voltage_V)
│   └── ...capturas del osciloscopio (.bmp)
│
├── 1 parte/, 4 PARTE/, 6 parte/, 9 parte/   # Capturas de osciloscopio de cada etapa de la Parte I
│
├── parte 2 lab/                         # Parte II: caracterización estadística del ADC
│   ├── sampling_2.py                    # Código MicroPython (RP2350)
│   ├── 0,5v/ 1,5V/ 2V/ 2,5V/             # Un directorio por nivel de tensión DC ensayado
│   │   ├── samples_test_X.csv           # 10 000 lecturas crudas (Sample, Raw_u16)
│   │   ├── histogram_test_X.csv         # Distribución de códigos nominales de 12 bits
│   │   └── Captura de pantalla ...png   # Consola con los estadísticos reportados por el firmware
│   └── ...
│
└── fig_*_serie.png, fig_*_histV.png, fig_*_histCode.png   # Gráficas generadas por analisis_ADC.m
```

## Requisitos

**Hardware**
- Raspberry Pi Pico 2 W
- Osciloscopio (2 canales) con puntas y cursores
- Generador de funciones
- Multímetro
- Fuente DC / potenciómetro (Parte II)

**Software**
- [MicroPython](https://micropython.org/download/RPI_PICO2_W/) instalado en la Raspberry Pi Pico 2 W
- Thonny (u otro IDE compatible con MicroPython) para cargar y ejecutar los scripts `.py`
- MATLAB (o Octave) para ejecutar `analisis_ADC.m`
- Python 3 con `pandas`/`matplotlib` (opcional, para graficar `datos.csv`)

## Cómo reproducir la práctica

### Parte I — Muestreo

1. Cargar `2 parte/sampling_1.py` en la Raspberry Pi Pico 2 W.
2. Conectar la señal senoidal a `GP26` y a CH1 del osciloscopio; conectar `GP15` a CH2.
3. Ejecutar el script. Al finalizar se genera `datos.csv` con las columnas `Sample, Time_us, Raw_u16, Voltage_V`.
4. Medir `Fs` con los cursores del osciloscopio sobre CH2 y comparar con el valor reportado en consola (`Software-estimated Fs`).

### Parte II — Análisis estadístico

1. Cargar `parte 2 lab/sampling_2.py` en la Raspberry Pi Pico 2 W.
2. Conectar `GP26/ADC0` a la tensión DC de prueba (0 – 3.3 V) y medirla con el multímetro.
3. Ejecutar el script; ingresar el número de ensayo y el valor medido con el multímetro cuando se solicite.
4. El script genera `samples_test_X.csv` (10 000 lecturas) e `histogram_test_X.csv` (distribución de códigos de 12 bits) y reporta en consola la media, desviación estándar y estadísticos asociados (algoritmo de Welford).
5. Repetir para cada nivel de tensión DC.
6. Ejecutar `analisis_ADC.m` en MATLAB para recalcular los estadísticos a partir de los CSV, generar las gráficas (`fig_*_serie.png`, `fig_*_histV.png`, `fig_*_histCode.png`) y el resumen `resumen_resultados_matlab.csv`.

## Resultados principales

| Magnitud | Resultado |
|---|---|
| Fs nominal | 1000 Hz |
| Fs (software) | 1000.02 Hz (error 0.002 %) |
| Fs (osciloscopio) | 996.01 Hz (error 0.399 %) |
| f_in medida | 100 Hz |
| Ns (muestras/período) | ≈ 10 |
| LSB ideal (12 bits, VREF = 3.3 V) | 0.806 mV |
| Desviación estándar del ADC (4 ensayos DC) | 5.11 – 5.92 mV (≈ 6.3 – 7.3 LSB) |
| Error sistemático ADC vs. multímetro | −23.6 a −73.6 mV |

El detalle completo de procedimiento, cálculos, gráficas y discusión se encuentra en el informe (`5 INFORME COMUNICACION DIGITAL (...).pdf`).

## Referencias

- Raspberry Pi Ltd, *Raspberry Pi Pico 2 W Datasheet*, 2024.
- Raspberry Pi Ltd, *RP2350 Datasheet*, 2024.
- MicroPython Documentation, *machine.ADC — analog to digital conversion*.
- Guía de laboratorio ADC_LAB.pdf — Universidad Militar Nueva Granada, Programa de Ingeniería en Telecomunicaciones.
