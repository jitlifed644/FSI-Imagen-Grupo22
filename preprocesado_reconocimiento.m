function letras_finales = preprocesado_reconocimiento(caracteres, N)
    letras_finales = cell(1, length(caracteres));

    for i = 1:length(caracteres)
        letra_actual = caracteres{i};
        
        if isempty(letra_actual) || ischar(letra_actual) || ...
           ((isnumeric(letra_actual) || islogical(letra_actual)) && sum(letra_actual(:)) == 0)
            letras_finales{i} = false(N, N); % Genera una imagen toda negra que sera nuestro espacio
            continue; 
        end
        
        [filas_blancas, columnas_blancas] = find(letra_actual);
        
        if isempty(filas_blancas)
            continue;
        end
        
        letra_recortada = letra_actual(min(filas_blancas):max(filas_blancas), min(columnas_blancas):max(columnas_blancas));
        
        letras_finales{end+1} = imresize(letra_recortada, [N, N]);
    end
end