function letras_finales = preprocesado_reconocimiento(caracteres, N)
    letras_finales = {}; % No podemos prealojar el tamano por si acaso entra una TU o algo asi que tengamos que cortar
    for i = 1:length(caracteres)
        letra_actual = caracteres{i};
        
        % Miramos si es un espacio
        if isempty(letra_actual) || ischar(letra_actual) || ...
           ((isnumeric(letra_actual) || islogical(letra_actual)) && sum(letra_actual(:)) == 0)
            letras_finales{end+1} = false(N, N); 
            continue; 
        end
        
        
        [filas_blancas, columnas_blancas] = find(letra_actual);
        if isempty(filas_blancas)
            letras_finales{end+1} = false(N, N);
            continue;
        end

        % Miramos para recortar en el caso de que haya alguna letra doble 
        letra_recortada = letra_actual(min(filas_blancas):max(filas_blancas), min(columnas_blancas):max(columnas_blancas));
        
        alto = size(letra_recortada, 1);
        ancho = size(letra_recortada, 2);
        
        if ancho > 1.45 * alto % El umbral fue un poco a ojo en funcion de como iba con las pruebas que hicimos
            mitad = round(ancho / 2);
            trozo1 = letra_recortada(:, 1:mitad);
            trozo2 = letra_recortada(:, mitad+1:end);
            
            trozo1 = padarray(trozo1, [1 1], false, 'both');
            letras_finales{end+1} = imresize(trozo1, [N, N]);
            
            trozo2 = padarray(trozo2, [1 1], false, 'both');
            letras_finales{end+1} = imresize(trozo2, [N, N]);
        else
            letra_recortada = padarray(letra_recortada, [1 1], false, 'both');
            letras_finales{end+1} = imresize(letra_recortada, [N, N]);
        end
    end
end