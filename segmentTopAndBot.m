function imagenes_filas = segmentTopAndBot(Im_bin)

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

    % =========================================================
    % 3. RECORTE DE FILAS
    % =========================================================

    num_filas = length(filas_inicio);

    imagenes_filas = cell(num_filas, 1);

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

                if ancho_b > (alto_b * 1.15)

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

                    parte_izquierda = bloque_a_evaluar(:, 1:punto_corte);

                    parte_derecha = ...
                        bloque_a_evaluar(:, punto_corte + 1:end);

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

        end

        % =====================================================
        % 6. VISUALIZACIÓN
        % =====================================================

        num_letras = length(caracteres);

        figure('Name', ['Fila ', num2str(k)]);

        % -----------------------------------------------------
        % FILA DETECTADA
        % -----------------------------------------------------

        subplot(2, 1, 1);

        imshow(Im_horizontal);

        title(['Fila detectada ', num2str(k)]);

        % -----------------------------------------------------
        % CARACTERES SEGMENTADOS
        % -----------------------------------------------------

        subplot(2, 1, 2);

        cols_grid  = 8;
        filas_grid = ceil(num_letras / cols_grid);

        montage( ...
            caracteres, ...
            'Size', [filas_grid cols_grid], ...
            'BorderSize', [5 5], ...
            'BackgroundColor', 'white' ...
        );

        title(['Caracteres detectados - fila ', num2str(k)]);

    end

end