function letras_finales = Preprocesado(caracteres, N)
    letras_finales = {}; 
    
    for i = 1:length(caracteres)
        letra_actual = caracteres{i};
        
        if isempty(letra_actual) || ischar(letra_actual) || ... % Quitamos los espacios
           ((isnumeric(letra_actual) || islogical(letra_actual)) && sum(letra_actual(:)) == 0)
            
            continue; 
        end
        
        [filas_blancas, columnas_blancas] = find(letra_actual);
        
        if isempty(filas_blancas)
            continue;
        end
        
        letra_recortada = letra_actual(min(filas_blancas):max(filas_blancas), min(columnas_blancas):max(columnas_blancas));

        letra_recortada = padarray(letra_recortada, [1 1], false, 'both');
        
        letras_finales{end+1} = imresize(letra_recortada, [N, N]); % Reescalamos
    end
end