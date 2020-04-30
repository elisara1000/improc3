Q = 25; % Define quality factor

% Define base quantization matrix
Tb = [16 11 10 16 24 40 51 61; 12 12 14 19 26 58 60 55; ...
     14 13 16 24 40 57 69 56; 14 17 22 29 51 87 80 62; ...
     18 22 37 56 68 109 103 77; 24 35 55 64 81 104 113 92; ...
     49 64 78 87 103 121 120 101; 72 92 95 98 112 100 103 99];

% Determine S
if (Q < 50)
    S = 5000/Q;
else
    S = 200 - 2*Q;
end

Ts = floor((S*Tb + 50) / 100);
Ts(Ts == 0) = 1; % Prevent division by 0


im = imread('cameraman.tif');

huff = jpeg(im, Ts);
quant = ijpeg(huff, Ts);

figure; imshow(quant)
err = immse(quant, im); % mean square error
peaksnr = psnr(quant, im); % PSNR
fprintf("Quality %f: err %f snr %f\n", Q, err, peaksnr);

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
