load base_datos.mat

IMabc = imread("Preuba AVA5 .png"); 
IMabc_Binario = im2bin(IMabc); %Tarea 1 (Pasarlo a binario)

[filas, letras_por_fila] = segmentTopAndBot(IMabc_Binario);
    
caracteres_fila = letras_por_fila{1};

for i = 1:length(filas)
    caracteres_fila_actual = letras_por_fila{i};
    
    fila_actual_procesada = preprocesado_reconocimiento(caracteres_fila_actual, 16);
    filas_procesadas{i} = fila_actual_procesada;
end

