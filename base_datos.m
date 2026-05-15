function [abecedario, etiquetas] = base_datos()
    im1 = imread("Abecedario.png");
    im1gray = im2bin(im1); 
    
    [filas, letras_por_fila] = segmentTopAndBot(im1gray);
    
    caracteres_fila_1 = letras_por_fila{1};
    
    abecedario = Preprocesado(caracteres_fila_1, 16);
    
    etiquetas = 'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ';
    save('base_datos.mat', 'abecedario', 'etiquetas');
end