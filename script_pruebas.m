IMabc = imread("Prueba.png"); 
IMabc_Binario = im2bin(IMabc);

% 1. Ejecutas la función y recoges los datos
[filas_texto, info_filas] = segment_rows(IMabc_Binario);

% 2. ZONA DE GENERACIÓN DE IMÁGENES PARA LA MEMORIA
% Creamos una figura invisible si no queremos que salte la ventana
f = figure('Name', 'Proyección de filas', 'Visible', 'off'); 

% Dibujamos la proyección
plot(info_filas.proyeccion, 'LineWidth', 1.5);
hold on;
% Añadimos la línea del umbral calculada en la función
yline(info_filas.umbral, 'r--', 'Umbral (5%)', 'LineWidth', 1.5);
title('Proyección horizontal para segmentar filas');
xlabel('Filas de la imagen');
ylabel('Suma de píxeles');

% Exportamos directamente a nuestro directorio
exportgraphics(f, 'imagenes_memoria/02_proyeccion_filas.png', 'Resolution', 300);

%Se hace una sola vez para que sea mas eficiente
f_cols = figure('Name', 'Proyeccion de columnas', 'Visible','off');

for i = 1 : length(filas_texto)
    [columnas_texto, info_columnas] = segment_characters(filas_texto{i});
    
    % Limpiamos la figura en cada iteración para pintar la nueva
    clf(f_cols); 
    
    plot(info_columnas.proyeccion, 'LineWidth', 1.5);
    hold on;
    yline(info_columnas.umbral, 'r--', 'Umbral (5%)', 'LineWidth', 1.5);
    title(sprintf('Proyección vertical - Fila %d', i));
    xlabel('Columnas de la imagen');
    ylabel('Suma de píxeles');
    
    % Usamos sprintf para formatear el nombre del archivo
    nombre_archivo = sprintf('imagenes_memoria/02_proyeccion_columnas_fila_%d.png', i);
    exportgraphics(f_cols, nombre_archivo, 'Resolution', 300);
end

% Cogemos la Fila 5 (donde está POST MOLESTAM SENECTUTEM)
fila_problematica = filas_texto{5}; 

% Extraemos los caracteres con tu función actualizada
[letras_extraidas, ~] = segment_characters(fila_problematica);

ta = figure('Name', 'Letras extraídas de la Fila 5');
num_letras = length(letras_extraidas);

for i = 1:num_letras
    subplot(2, ceil(num_letras/2), i); % Crea una cuadrícula
    imshow(letras_extraidas{i});
    title(sprintf('#%d', i));
end

exportgraphics(ta, 'imagenes_memoria/extraccion_linea_con_TA.png', 'Resolution', 300);


