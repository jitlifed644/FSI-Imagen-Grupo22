IMabc = imread("Abecedario.png"); 
IMabc_Binario = im2bin(IMabc); %Tarea 1 (Pasarlo a binario)
Im_horizontal_bin = segmentTopAndBot(IMabc_Binario);
%Le quitamos todo lo que este por encima y por debajo de la fila de letras





