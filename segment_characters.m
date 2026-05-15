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

    necesita_limpieza = [];

    for i = 1: length(letras_inicio)
        inicio_actual = letras_inicio(i);
        fin_actual = letras_fin(i);
        ancho_actual = fin_actual - inicio_actual;
        
        if (anchos(i) > 1.6*ancho_medio)
            
            num_letras_bloque = round(ancho_actual/ancho_medio);

            for j = 1:(num_letras_bloque - 1)
                corte_teorico = inicio_actual + round(ancho_actual / num_letras_bloque); 

                rango_busqueda = (corte_teorico - 5) : (corte_teorico + 5);
                rango_busqueda = max(inicio_actual, min(rango_busqueda, fin_actual)); 
                
                [~, idx_min] = min(v_media_columnas(rango_busqueda));
                punto_de_corte = rango_busqueda(1) + idx_min - 1;
                
                inicio_corregido = [inicio_corregido, inicio_actual];
                fin_corregido = [fin_corregido, punto_de_corte];
                necesita_limpieza = [necesita_limpieza, true];
                
                inicio_actual = punto_de_corte + 1;
                ancho_actual = fin_actual - inicio_actual;

            end

            % caracter_seccionado = v_media_columnas(letras_inicio(i):letras_fin(i));
            % [~, indice_minimo_local] = min(caracter_seccionado);
            % 
            % punto_de_corte = letras_inicio(i) + indice_minimo_local - 1;
            inicio_corregido = [inicio_corregido, letras_inicio(i), punto_de_corte + 1];
            fin_corregido = [fin_corregido, punto_de_corte, letras_fin(i)];

            necesita_limpieza = [necesita_limpieza, true, true];
        else
            inicio_corregido = [inicio_corregido, letras_inicio(i)];
            fin_corregido = [fin_corregido, letras_fin(i)];

            necesita_limpieza = [necesita_limpieza, false];
        end
    end

    num_letras = length(inicio_corregido);
    chars_cell = cell(1, num_letras); 
    
    for i = 1:length(letras_inicio)
        x1 = max(1, letras_inicio(i) - 1); 
        x2 = min(size(row, 2), letras_fin(i) + 1);
        bloque = row(:, x1:x2); 

        % EVALUACIÓN: ¿Es ancho? (Puede ser TA, AVA, o simplemente una M/W/U)
        if anchos(i) > 1.6 * ancho_medio
            
            cc = bwconncomp(bloque);
            
            if cc.NumObjects > 1
                % Son letras solapadas (TA, AVA). Las separamos elegantemente.
                propiedades = regionprops(cc, 'BoundingBox', 'Image');
                cajas = cat(1, propiedades.BoundingBox);
                [~, orden] = sort(cajas(:, 1));
                
                for k = 1:length(orden)
                    idx = orden(k);
                    chars_cell{end+1} = propiedades(idx).Image; 
                end
            else
                if anchos(i) > 2.1 * ancho_medio
                    % CASO 2: Monstruo fundido (Guillotina Dinámica)
                    % Calculamos cuántas letras forman este enjambre
                    num_letras_bloque = round(anchos(i) / ancho_medio);
                    proj_local = mean(bloque, 1);
                    ancho_local = size(bloque, 2);
                    inicio_trozo = 1;

                    for k = 1:(num_letras_bloque - 1)
                        % Buscamos el corte teórico y miramos +/- 5 píxeles para el valle
                        corte_teorico = round(k * (ancho_local / num_letras_bloque));
                        rango = max(1, corte_teorico - 5) : min(ancho_local, corte_teorico + 5);
                        [~, idx_min] = min(proj_local(rango));
                        punto_corte = rango(1) + idx_min - 1;

                        % Extraemos y limpiamos los restos
                        trozo = bloque(:, inicio_trozo:punto_corte);
                        chars_cell{end+1} = bwareafilt(trozo, 1);
                        
                        inicio_trozo = punto_corte + 1;
                    end
                    % El último trozo restante
                    trozo = bloque(:, inicio_trozo:end);
                    chars_cell{end+1} = bwareafilt(trozo, 1);
                    
                else
                    % CASO 3: Es una M, W o U normal. Ni se toca.
                    chars_cell{end+1} = bloque;
                end
            end
            
        else
            % LETRA NORMAL (H, O, L, A...). Pasa directa.
            chars_cell{end+1} = bloque;
        end
    end

    debug_info.proyeccion = v_media_columnas;
    debug_info.umbral = umbral_columna;
end