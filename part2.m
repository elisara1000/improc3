close all; clear; clc;
im = im2double(imread('cameraman.tif'));

%% DCT
dctIm = dct2(im);

%number of quantization levels
num_quant_levels = 10;

%quantize samples in DCT basis
qdctIm = quant(dctIm,num_quant_levels);

%visually compare complete vs quantized DCT
figure;
subplot(2,2,1);
imshow(dctIm);("Complete DCT");

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

pause;

%% Daubehchis Wavelet transform
[dA,dH,dV,dD] = dwt2(im,'db2');

%number of quantization levels
num_quant_levels = 10;

%quantize samples in DWT basis
qdctIm_dA = quant(dA,num_quant_levels);
qdctIm_dH = quant(dH,num_quant_levels);
qdctIm_dV = quant(dV,num_quant_levels);
qdctIm_dD = quant(dD,num_quant_levels);

%retrieve image from quantized samples
qim = idwt2(qdctIm_dA, qdctIm_dH, qdctIm_dV, qdctIm_dD, 'db2');

% calc
err = immse(qim, im); % mean square error
peaksnr = psnr(qim, im); % PSNR

%visually compare original vs DWT and quantized result
figure;
subplot(1,2,1);
imshow(im);
title("original image");

subplot(1,2,2);
imshow(qim);
title(["image resulting from quantized DWT. PSNR:" num2str(peaksnr) "dB, MSE:" num2str(err)]);


%% Haar Wavelet Transform
[hA,hH,hV,hD] = dwt2(im,'haar');

%number of quantization levels
num_quant_levels = 10;

%quantize samples in DWT basis
qdctIm_hA = quant(hA,num_quant_levels);
qdctIm_hH = quant(hH,num_quant_levels);
qdctIm_hV = quant(hV,num_quant_levels);
qdctIm_hD = quant(hD,num_quant_levels);

%retrieve image from quantized samples
qim = idwt2(qdctIm_hA, qdctIm_hH, qdctIm_hV, qdctIm_hD, 'haar');

% calc
err = immse(qim, im); % mean square error
peaksnr = psnr(qim, im); % PSNR

%visually compare original vs DWT and quantized result
figure;
subplot(1,2,1);
imshow(im);
title("original image");

subplot(1,2,2);
imshow(qim);
title(["image resulting from quantized Haar. PSNR:" num2str(peaksnr) "dB, MSE:" num2str(err)]);

%% Test
%imshow(cat(2, im, quant(im,1000)));

function xq = quant(x, num_levels)
    xq = floor(num_levels*x)/num_levels;
end