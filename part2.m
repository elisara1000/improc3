close all; clear; clc;

im = imread('cameraman.tif');
figure, imshow(im) 
title('Original Image')

%% Quantization
for numLevels = 1 : 4
    thresh = multithresh(im, pow2(numLevels)); % split into levels
    % max of each quantized section is assigned to that section
    valuesMax = [thresh max(im(:))];
    [quant8_I_max, index] = imquantize(im,thresh,valuesMax);
   
    % same with min
    valuesMin = [min(im(:)) thresh]; 
    quant8_I_min = valuesMin(index);

    % show
    figure, imshowpair(quant8_I_min,quant8_I_max,'montage') 
    title('Minimum Interval Value           Maximum Interval Value')
end

pause;

%% Daubehchis Wavelet transform
[dA,dH,dV,dD] = dwt2(im,'db2');
figure, title('Daubechis'), subplot(2,2,1)
imagesc(dA)
colormap gray
title('Approximation')

subplot(2,2,2)
imagesc(dH)
colormap gray
title('Horizontal')

subplot(2,2,3)
imagesc(dV)
colormap gray
title('Vertical')

subplot(2,2,4)
imagesc(dD)
colormap gray
title('Diagonal')
pause;

%% Haar Wavelet Transform
[hA,hH,hV,hD] = dwt2(im,'haar');
figure, title('Haar'),subplot(2,2,1)
imagesc(hA)
colormap gray
title('Approximation')

subplot(2,2,2)
imagesc(hH)
colormap gray
title('Horizontal')

subplot(2,2,3)
imagesc(hV)
colormap gray
title('Vertical')

subplot(2,2,4)
imagesc(hD)
colormap gray
title('Diagonal')