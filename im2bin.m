function IMabc_binaria = im2bin(IMabc)
%Pasamos a double para facilitar calculos (del 0 al 1)
im_d = im2double(IMabc); 

%Usando ciertos parámetros hacemos una suma ponderada
IMabc_gris = im2gray(im_d);

%La función graythresh utiliza el método de Otsu para encontrar un valor
%numérico específico (el umbral) que permita separar los píxeles de una 
%imagen en dos grupos: fondo y objeto

%Para ello analiza el histograma buscando la distribución de niveles de
%gris, luego calcula la varianza que hace que dichos niveles sean lo más 
%diferentes entre sí posible y, por último devuelve un valor entre 0 y 1 
%que marca el corte ideal para diferenciar fondo y objeto
umbral = graythresh(IMabc_gris);

%Comparamos cada pixel de la imagen gris con el umbral, si es mayor 1, si
%es menor 0. Que pasa? Que nosotros no queremos que resalte lo blanco (lo
%mas cercano a 1) si no lo negro (lo mas cercano a 0), es por eso que
%usamos ~ para invertir la imagen. De esta forma las letras son 1 y el
%fondo 0, no al revés

IM_temp = IMabc_gris > umbral;

if sum(IM_temp(:)) > (numel(IM_temp) / 2)
    IMabc_binaria = ~IM_temp;
else
    IMabc_binaria = IM_temp; % El fondo ya era negro
end
end