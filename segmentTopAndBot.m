function Im_horizontal = segmentTopAndBot(Im_bin)
%Calculamos el promedio de cada fila, dejando un vector columna con el
%promedio de cada fila.
v_media_filas = mean(Im_bin,2);

%Ahora haremos un umbral para eliminar ruido o pequeñas variaciones, como?
%Pues te aseguras de que el umbral sea proporcional a la cantidad de texto que hay
%Si el pico más alto es 100 píxeles, cualquier fila que promedie menos de 15 se ignora por ser ruido
umbral = 0.15*max(v_media_filas);

%Usamos el umbral y dejamos un vector de solo 1 y 0.
v_filas_buenas = v_media_filas > umbral;
cambios = diff([0; v_filas_buenas; 0]);

filas_inicio = find(cambios == 1); 
y1 = filas_inicio(1); % Cogemos el primer inicio detectado

filas_fin = find(cambios == -1) - 1;
y2 = filas_fin(end); % Cogemos el último final detectado

Im_horizontal = Im_bin(y1:y2,:);

figure; 
plot(v_filas_buenas); 
title('Proyección Vertical (Detección de Filas)');
end