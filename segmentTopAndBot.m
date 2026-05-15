function [imagenes_filas, caracteres_por_fila] = segmentTopAndBot(Im_bin)

    % =========================================================
    % 1. DILATACIÓN VERTICAL
    % =========================================================
    % Une partes cercanas verticalmente:
    % puntos de letras, tildes o pequeños cortes.

    se_vertical = strel('rectangle', [5, 1]);

    Im_dilatada = imdilate(Im_bin, se_vertical);

    % =========================================================
    % 2. PROYECCIÓN HORIZONTAL
    % =========================================================
    % Calcula la densidad de píxeles por fila
    % para detectar líneas de texto.

    v_media_filas = mean(Im_dilatada, 2);

    % Umbral adaptativo
    umbral_fila = 0.05 * max(v_media_filas);

    % Filas que contienen texto
    v_filas_buenas = v_media_filas > umbral_fila;

    % Detecta cambios 0->1 y 1->0
    cambios_filas = diff([0; v_filas_buenas; 0]);

    filas_inicio = find(cambios_filas == 1);
    filas_fin    = find(cambios_filas == -1) - 1;

    alturas_filas = filas_fin - filas_inicio;
    altura_media_filas = median(alturas_filas);
    
    filas_inicio_limpias = [];
    filas_fin_limpias = [];
    
    for i = 1:length(filas_inicio)
        % Si la fila mide al menos un 30% de la altura normal, es texto real.
        % Si es una línea de polvo de 3 píxeles, se descarta.
        if alturas_filas(i) > 0.25 * altura_media_filas
            filas_inicio_limpias = [filas_inicio_limpias, filas_inicio(i)];
            filas_fin_limpias = [filas_fin_limpias, filas_fin(i)];
        end
    end
    
    % Sobrescribimos con los vectores ya limpios
    filas_inicio = filas_inicio_limpias;
    filas_fin = filas_fin_limpias;

    % =========================================================
    % 3. RECORTE DE FILAS
    % =========================================================

    num_filas = length(filas_inicio);

    imagenes_filas = cell(num_filas, 1);
    caracteres_por_fila = cell(num_filas, 1);

    for k = 1:num_filas

        % Márgenes pequeños de seguridad
        y1 = max(1, filas_inicio(k) - 1);
        y2 = min(size(Im_bin, 1), filas_fin(k) + 1);

        % Recorte de la fila completa
        Im_horizontal = Im_bin(y1:y2, :);

        % Guardar fila detectada
        imagenes_filas{k} = Im_horizontal;

        % =====================================================
        % 4. PROYECCIÓN VERTICAL
        % =====================================================
        % Busca bloques de caracteres.

        v_media_columnas = mean(Im_horizontal, 1);

        umbral_columna = 0.05 * max(v_media_columnas);

        v_columnas_buenas = v_media_columnas > umbral_columna;

        cambios_columnas = diff([0, v_columnas_buenas, 0]);

        letras_inicio = find(cambios_columnas == 1);
        letras_fin    = find(cambios_columnas == -1) - 1;

        % =====================================================
        % 5. EXTRACCIÓN DE CARACTERES
        % =====================================================

        num_letras_ini = length(letras_inicio);

        caracteres = {};

        anchos_iniciales = letras_fin - letras_inicio;
        ancho_ref = median(anchos_iniciales);

        for i = 1:num_letras_ini

            % Coordenadas del bloque inicial
            x1 = max(1, letras_inicio(i) - 1);
            x2 = min(size(Im_horizontal, 2), letras_fin(i) + 1);

            bloque_a_evaluar = Im_horizontal(:, x1:x2);

            quedan_cortes = true;

            while quedan_cortes

                ancho_b = size(bloque_a_evaluar, 2);
                alto_b  = size(bloque_a_evaluar, 1);

                % =================================================
                % DETECCIÓN DE BLOQUE SOSPECHOSO
                % =================================================
                % Si el bloque es demasiado ancho,
                % probablemente contiene varias letras unidas.

                if ancho_b > (alto_b * 1.45)

                    % =============================================
                    % EROSIÓN
                    % =============================================
                    % La erosión elimina conexiones finas entre
                    % caracteres pegados.
                    %
                    % Ejemplo:
                    % "rn" unido -> separación más visible.

                    se_er = strel('disk', 1);

                    bloque_erosionado = imerode(bloque_a_evaluar, se_er);

                    % =============================================
                    % PROYECCIÓN VERTICAL DEL BLOQUE EROSIONADO
                    % =============================================
                    % Busca columnas con menor densidad:
                    % posibles zonas de separación.

                    densidad = sum(bloque_erosionado, 1);

                    % =============================================
                    % BÚSQUEDA SOLO EN LA ZONA CENTRAL
                    % =============================================
                    % Evita cortar letras naturalmente anchas
                    % como M, W o caracteres inclinados.

                    lim_izq = round(ancho_b * 0.30);
                    lim_der = round(ancho_b * 0.70);

                    lim_izq = max(1, lim_izq);
                    lim_der = min(ancho_b, lim_der);

                    % Mínimo local de densidad
                    [~, idx_min] = min(densidad(lim_izq:lim_der));

                    punto_corte = idx_min + lim_izq - 1;

                    % =============================================
                    % CORTE DEL BLOQUE
                    % =============================================

                    [L, num_objetos] = bwlabel(bloque_a_evaluar);

                    if num_objetos >= 2
                        % Las letras están muy juntas (como T y A) pero no pegadas.
                        % Separamos la "isla" de la izquierda y la de la derecha respetando la forma.
                        parte_izquierda = (L == 1);
                        parte_derecha   = (L >= 2);
                    else
                        % Las letras están fundidas por la tinta. Hacemos el corte recto (Plan B).
                        % Usamos máscaras para no cambiar el tamaño de la matriz de golpe.
                        parte_izquierda = bloque_a_evaluar;
                        parte_izquierda(:, punto_corte + 1:end) = 0; 

                        parte_derecha = bloque_a_evaluar;
                        parte_derecha(:, 1:punto_corte) = 0; 
                    end

                    % Ajustamos las "cajas" para quitar las columnas vacías que hayan quedado
                    % y permitir que el bucle 'while' siga encogiendo la imagen.
                    [~, cols_izq] = find(parte_izquierda);
                    if ~isempty(cols_izq)
                        parte_izquierda = parte_izquierda(:, min(cols_izq):max(cols_izq)); 
                    else
                        parte_izquierda = []; 
                    end

                    [~, cols_der] = find(parte_derecha);
                    if ~isempty(cols_der)
                        parte_derecha = parte_derecha(:, min(cols_der):max(cols_der)); 
                    else
                        parte_derecha = []; 
                    end

                    % Guarda la parte izquierda
                    caracteres{end + 1} = parte_izquierda;

                    % =============================================
                    % REEVALUACIÓN RECURSIVA
                    % =============================================
                    % La parte derecha vuelve a analizarse
                    % por si aún contiene varias letras.

                    if isempty(parte_derecha) || ...
                       size(parte_derecha, 2) < 2

                        quedan_cortes = false;

                    else

                        bloque_a_evaluar = parte_derecha;

                    end

                else

                    % =============================================
                    % BLOQUE VÁLIDO
                    % =============================================
                    % El tamaño parece corresponder
                    % a un único carácter.

                    caracteres{end + 1} = bloque_a_evaluar;

                    quedan_cortes = false;

                end

            end

            if i < num_letras_ini
                distancia_siguiente = letras_inicio(i+1) - letras_fin(i);
                altura_fila = size(Im_horizontal, 1);
                
                % Si el hueco supera el 35% de la altura de la fila, es un espacio
                if distancia_siguiente > (0.325 * altura_fila)
                    
                    % Creamos un bloque negro (fondo) del tamaño de un espacio
                    % false() crea una matriz lógica de 0s.
                    matriz_espacio = false(altura_fila, round(altura_fila * 0.5));
                    
                    caracteres{end + 1} = matriz_espacio; 
                end
            end
        end

        caracteres_por_fila{k} = caracteres;

        % =====================================================
        % 6. VISUALIZACIÓN
        % =====================================================

        % num_letras = length(caracteres);

        % figure('Name', ['Fila ', num2str(k)]);
        % 
        % % -----------------------------------------------------
        % % FILA DETECTADA
        % % -----------------------------------------------------
        % 
        % subplot(2, 1, 1);
        % 
        % imshow(Im_horizontal);
        % 
        % title(['Fila detectada ', num2str(k)]);
        % 
        % % -----------------------------------------------------
        % % CARACTERES SEGMENTADOS
        % % -----------------------------------------------------
        % 
        % subplot(2, 1, 2);
        % 
        % cols_grid  = 8;
        % filas_grid = ceil(num_letras / cols_grid);
        % 
        % montage( ...
        %     caracteres, ...
        %     'Size', [filas_grid cols_grid], ...
        %     'BorderSize', [5 5], ...
        %     'BackgroundColor', 'white' ...
        % );
        % 
        % title(['Caracteres detectados - fila ', num2str(k)]);

    end
    

end