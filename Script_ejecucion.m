load base_datos.mat

IMabc = imread("Preuba AVA5 .png"); 
IMabc_Binario = im2bin(IMabc); %Tarea 1 (Pasarlo a binario)

[filas, letras_por_fila] = segmentTopAndBot(IMabc_Binario);
    
caracteres_fila_1 = letras_por_fila{1};

for i = 1:length(filas)
    caracteres_fila_actual = letras_por_fila{i};
    
    fila_actual_procesada = Preprocesado(caracteres_fila_actual);
    filas_procesadas{i} = fila_actual_procesada;
end







