close all; clear; clc;

im = im2double(imread('cameraman.tif'));
figure, imshow(im) 
title('Original Image')


%% DCT
dctIm = dct2(im);

%number of quantization levels
num_quant_levels = 10;

%quantize samples in DCT basis
qdctIm = quant(dctIm,num_quant_levels);

%visually compare complete vs quantized DCT
figure;
subplot(2,2,1);
imshow(dctIm);
title("Complete DCT");

subplot(2,2,2);
imshow(qdctIm);
title(["DCT with " num2str(num_quant_levels) "quantization levels"]);

%retrieve image from quantized samples
qim = idct2(qdctIm);

% calc
err = immse(qim, im); % mean square error
peaksnr = psnr(qim, im); % PSNR

subplot(2,2,3);
imshow(im);
title("original image");

subplot(2,2,4);
imshow(qim);
title(["image resulting from quantized DCT. PSNR:" num2str(peaksnr) "dB, MSE:" num2str(err)]);

%fprintf("     Mean-squared error  |  Peak Signal to Noise Ratio\n");
%fprintf("DCT:       %0.4f               %0.4f\n", err, peaksnr);

pause;

%% Quantization

% CHANGE SO NOT MIN AND MAX

for numLevels = 1 : 4
    thresh = multithresh(im, pow2(numLevels)); % split into levels
    % max of each quantized section is assigned to that section
    valuesMax = [thresh max(im(:))];
    [quant8_I_max, index] = imquantize(im,thresh);%,valuesMax);
   
    % same with min
    valuesMin = [min(im(:)) thresh]; 
    quant8_I_min = valuesMin(index);

    % show
    figure, imshowpair(quant8_I_min,quant8_I_max,'montage') 
    title('Minimum Interval Value           Maximum Interval Value')
    
    % calc
    err = immse(quant8_I_min, im); % mean square error
    peaksnr = psnr(quant8_I_min, im); % PSNR
    fprintf("Q %2.0d:       %0.4f               %0.4f\n", pow2(numLevels), err, peaksnr);

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

%% Test
imshow(cat(2, im, quant(im,1000)));

function xq = quant(x, num_levels)
    xq = floor(num_levels*x)/num_levels;
end