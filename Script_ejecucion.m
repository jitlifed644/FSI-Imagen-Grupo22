load('base_datos.mat'); % Carga las variables de la base de datos

IMabc = imread("Prueba.png"); 
IMabc_Binario = im2bin(IMabc); 
IMabc_Binario = bwareaopen(IMabc_Binario, 30);

elemento_estructural = strel('square', 2); 
% Erosionamos (comemos los bordes blancos)
IMabc_Binario = imerode(IMabc_Binario, elemento_estructural);


% Extraemos las filas y las letras de la imagen con la funcion creada
[filas, letras_por_fila] = segmentTopAndBot(IMabc_Binario);
    
fprintf('\n--- OCR Grupo 22 ---\n\n');

for i = 1:length(filas)
    caracteres_fila_actual = letras_por_fila{i};
    
    % Preprocesamos la fila i de la imagen, usamos el el de reconocimiento
    % puesto que es el que reconoce los espacios
    fila_procesada = preprocesado_reconocimiento(caracteres_fila_actual, 16);
    
    % Reconocemos cada letra con este bucle   
    for k = 1:length(fila_procesada)
        letra_incognita = fila_procesada{k};
        
        % Si es una caja totalmente negra se va porque se identifica como
        % un espacio
        if sum(letra_incognita(:)) == 0
            fprintf(' '); 
            continue;     
        end
        
        % Si tiene algo blanco, se contrasta con las imagenes de la DB
        similitudes = zeros(1, 27);
        for j = 1:27
            % corr2 nos da un % de similitud entre la incógnita y la letra
            % a la que corresponde esta iteracion
            similitudes(j) = corr2(letra_incognita, abecedario{j});
        end
        
        % Buscamos cuál de las 27 ha tenido mas similitudes
        [max_score, indice_ganador] = max(similitudes);
        
        
        fprintf('%c', etiquetas(indice_ganador));
    end
    
    fprintf('\n');
end

fprintf('\n-------------------------\n');