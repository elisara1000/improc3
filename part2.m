close all; clear; clc;
im = im2double(imread('cameraman.tif'));

%% JPEG
%Quantization matrix specified in JPEG spec for 50% quality
qmat = [16 11 10 16 24 40 51 61; 12 12 14 19 26 58 60 55;...
    14 13 16 24 40 57 69 56; 14 17 22 29 51 87 80 62; ...
    18 22 37 56 68 109 103 77; 24 35 55 64 81 104 113 92;...
    49 64 78 87 103 121 120 101; 72 92 95 98 112 100 103 99];

%jpeg/ijpeg function 
im255 = imread('cameraman.tif');
huff = jpeg(im255, qmat);
q50 = ijpeg(huff, qmat);

figure
subplot(1,2,1);
imshow(im255);
title("original image");
subplot(1,2,2);
imshow(q50);
title("JPEG compressed image Quality 50");

pause;

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


%% Functions
%naive quantization
function xq = quant(x, num_levels)
    xq = floor(num_levels*x)/num_levels;
end

%forward jpeg (image to huffman code of quantized dcts)
function huff = jpeg(im, qmat)
    xq = zeros(size(im));
    
    %isolate 8x8 blocks of x
    for i = (0 : (size(im,1)/8)-1)
        for j = (0 : (size(im,2)/8)-1)
            b_i = i*8+1:(i+1)*8;
            b_j = j*8+1:(j+1)*8;
            block = im(b_i, b_j);
            
            %compute block dct of each 8x8 block
            bdct = dct2(block);
            
            %divide dct coefficients element-wise by quantization matrix
            %bdct = bdct / qmat;
            bdct = rdivide(bdct,qmat);
            
            %round resulting matrix
            bdct = round(bdct);
            
            
            xq(b_i, b_j) = bdct;
        end
    end
    
    %encode blocks as huffman code
    %TEMPORARY: just return concatenated 8x8 DCT blocks
    huff = xq;
end

%inverse jpeg (huffman codes to lossy image)
function im = ijpeg(huff, qmat)
    %retrieve matrix corresponding to concatenated 8x8 DCT blocks
    
    %TEMPORARY: assume that "huff" is already that matrix
    xq = huff;
    
    im = zeros(size(xq));
    
    for i = (0 : (size(im,1)/8)-1)
        for j = (0 : (size(im,2)/8)-1)
            b_i = i*8+1:(i+1)*8;
            b_j = j*8+1:(j+1)*8;
            
            %isolate an 8x8 DCT block
            bdct = xq(b_i,b_j);
            
            %element-wise multiply with quantization matrix to recover
            %lossy 8x8 image block
            bdct = times(bdct,qmat);
            
            %convert DCT block to image block
            block = idct2(bdct);
            
            %place block into place in image
            im(b_i, b_j) = block;
        end
    end
    
    %round to integer pixel values
    im = round(im);
    
    %there are some negative pixel values introduced by the DCT
    %not sure if that's normal but this makes all values positive
    im = abs(im);
    
    %there are also pixel values superior to 255
    im(im>255)=255;
    
    im = cast(im,'uint8');
end

