function [chars_cell, debug_info] = segment_characters(row)
    % Dilatamos también horizontalmente un poco para asegurar que las letras son bloques
    % Im_horiz_dilatada = imdilate(row, strel('disk', 1));
    v_media_columnas = mean(row, 1);

    umbral_columna = 0.05 * max(v_media_columnas);
    v_columnas_buenas = v_media_columnas > umbral_columna;

    cambios_columnas = diff([0, v_columnas_buenas, 0]);
    letras_inicio = find(cambios_columnas == 1);
    letras_fin = find(cambios_columnas == -1) - 1;

    % 4. EXTRACCIÓN DE CARACTERES

    anchos = letras_fin - letras_inicio;
    ancho_medio = median(anchos);

    inicio_corregido = [];
    fin_corregido = [];

    for i = 1: length(letras_inicio)
        if (anchos(i) > 1.5*ancho_medio)
            caracter_seccionado = v_media_columnas(letras_inicio(i):letras_fin(i));
            [~, indice_minimo_local] = min(caracter_seccionado);

            punto_de_corte = letras_inicio(i) + indice_minimo_local - 1;
            inicio_corregido = [inicio_corregido, letras_inicio(i), punto_de_corte + 1];
            fin_corregido = [fin_corregido, punto_de_corte, letras_fin(i)];
        else
            inicio_corregido = [inicio_corregido, letras_inicio(i)];
            fin_corregido = [fin_corregido, letras_fin(i)];
        end
    end

    num_letras = length(inicio_corregido);
    chars_cell = cell(1, num_letras); 
    
    for i = 1:num_letras
        x1 = max(1, inicio_corregido(i) - 1); 
        x2 = min(size(row, 2), fin_corregido(i) + 1);
        letras_sucias = row(:, x1:x2); 

        letra_limpia = bwareafilt(letras_sucias, 1);
        
        chars_cell{i} = letra_limpia;
    end

    debug_info.proyeccion = v_media_columnas;
    debug_info.umbral = umbral_columna;
end