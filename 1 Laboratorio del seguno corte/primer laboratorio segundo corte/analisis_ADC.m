
clear; clc; close all;

%% ---------------- Parametros del ADC ----------------
VREF   = 3.3;                 % Voltaje de referencia del ADC [V]
NBITS  = 12;                  % Resolucion nominal del ADC
LSB_ideal_V  = VREF / (2^NBITS - 1);   % LSB ideal en voltios
LSB_ideal_mV = LSB_ideal_V * 1000;     % LSB ideal en milivoltios

fprintf('LSB ideal (12 bits, VREF = %.2f V) = %.4f mV\n\n', VREF, LSB_ideal_mV);

base = fullfile('primer laboratorio segundo corte', 'parte 2 lab');

ensayos = struct( ...
    'nombre',   {'Test 1 (0.5 V)', 'Test 2 (1.5 V)', 'Test 3 (2 V)', 'Test 4 (2.5 V)'}, ...
    'carpeta',  {'0,5v', '1,5V', '2V', '2,5V'}, ...
    'archivo',  {'samples_test_1.csv', 'samples_test_1.csv', 'samples_test_2.csv', 'samples_test_1.csv'}, ...
    'VDMM',     {0.5, 1.5, 2.0, 2.5}, ...
    'fw_mean',  {0.561121, 1.520765, 1.975820, 2.426417}, ...
    'fw_std_mV',{5.577,    5.953,    5.722,    5.920} ...
);

Ntest = numel(ensayos);
resumen = table();

%% ---------------- Procesamiento de cada ensayo ----------------
for k = 1:Ntest

    e = ensayos(k);
    archivo = fullfile(base, e.carpeta, e.archivo);

    T = readtable(archivo);         % columnas: Sample, Raw_u16
    raw = double(T.Raw_u16);

    % --- Conversion raw16 -> voltaje y codigo nominal de 12 bits ---
    V      = raw * VREF / 65535;    % igual formula usada en sampling_2.py
    code12 = bitshift(uint32(raw), -4);  % code12 = raw16 >> 4

    % --- a) Estadistica recalculada en MATLAB ---
    V_media  = mean(V);
    V_std    = std(V);              % std muestral (N-1) por defecto en MATLAB
    V_min    = min(V);
    V_max    = max(V);
    V_rango  = V_max - V_min;
    std_mV   = V_std * 1000;
    std_LSB  = std_mV / LSB_ideal_mV;

    % --- b) Comparacion con lo reportado por sampling_2.py ---
    diff_media_mV = (V_media - e.fw_mean) * 1000;
    diff_std_mV   = std_mV - e.fw_std_mV;

    % --- Error del promedio del ADC contra el multimetro ---
    err_dmm_mV  = (V_media - e.VDMM) * 1000;
    err_dmm_pct = 100 * (V_media - e.VDMM) / e.VDMM;

    % --- Codigos de 12 bits distintos observados ---
    codigos_unicos = numel(unique(code12));

    fprintf('--------------------------------------------------------\n');
    fprintf('%s\n', e.nombre);
    fprintf('--------------------------------------------------------\n');
    fprintf('Media V (MATLAB)        : %.6f V\n', V_media);
    fprintf('Media V (firmware)      : %.6f V\n', e.fw_mean);
    fprintf('Diferencia media        : %+.3f mV\n', diff_media_mV);
    fprintf('Desv. estandar (MATLAB) : %.3f mV  (%.3f LSB)\n', std_mV, std_LSB);
    fprintf('Desv. estandar (fw)     : %.3f mV\n', e.fw_std_mV);
    fprintf('Minimo / Maximo / Rango : %.4f / %.4f / %.4f V\n', V_min, V_max, V_rango);
    fprintf('Codigos de 12 bits distintos observados: %d\n', codigos_unicos);
    fprintf('Error medio ADC vs DMM  : %+.3f mV  (%+.3f %%)\n\n', err_dmm_mV, err_dmm_pct);

    fila = table({e.nombre}, e.VDMM, V_media, e.fw_mean, std_mV, e.fw_std_mV, ...
                  V_min, V_max, V_rango, std_LSB, err_dmm_mV, err_dmm_pct, codigos_unicos, ...
        'VariableNames', {'Ensayo','VDMM_V','Media_MATLAB_V','Media_firmware_V', ...
                           'Std_MATLAB_mV','Std_firmware_mV','Min_V','Max_V','Rango_V', ...
                           'Std_en_LSB','Error_vs_DMM_mV','Error_vs_DMM_pct','Codigos12bits_distintos'});
    resumen = [resumen; fila]; %#ok<AGROW>

    %% ---- c) Grafica: lecturas Vi vs numero de muestra ----
    figure('Name', [e.nombre ' - Serie temporal'], 'Position', [100 100 800 350]);
    plot(T.Sample, V, '-', 'LineWidth', 0.5, 'Color', [0.15 0.35 0.75]);
    hold on;
    yline(V_media, 'r--', sprintf('Media = %.4f V', V_media), 'LineWidth', 1.2);
    xlabel('Numero de muestra');
    ylabel('Voltaje (V)');
    title(sprintf('%s - Lecturas V_i vs. numero de muestra', e.nombre));
    grid on;
    saveas(gcf, sprintf('fig_%d_serie.png', k));

    %% ---- d) Histograma de las mediciones en voltios ----
    figure('Name', [e.nombre ' - Histograma en V'], 'Position', [100 100 700 350]);
    histogram(V, 40, 'FaceColor', [0.2 0.5 0.8]);
    xlabel('Voltaje (V)');
    ylabel('Frecuencia');
    title(sprintf('%s - Histograma de mediciones (V)', e.nombre));
    grid on;
    saveas(gcf, sprintf('fig_%d_histV.png', k));

    %% ---- e) Histograma de codigos nominales de 12 bits ----
    figure('Name', [e.nombre ' - Histograma codigos 12 bits'], 'Position', [100 100 700 350]);
    histogram(double(code12), 'BinMethod', 'integers', 'FaceColor', [0.85 0.5 0.2]);
    xlabel('Codigo nominal de 12 bits');
    ylabel('Frecuencia');
    title(sprintf('%s - Histograma de codigos de 12 bits', e.nombre));
    grid on;
    saveas(gcf, sprintf('fig_%d_histCode.png', k));

end

%% ---------------- Tabla resumen final ----------------
disp(resumen);
writetable(resumen, 'resumen_resultados_matlab.csv');

fprintf('\nListo. Figuras guardadas como fig_#_serie.png, fig_#_histV.png, fig_#_histCode.png\n');
fprintf('Tabla resumen guardada como resumen_resultados_matlab.csv\n');
