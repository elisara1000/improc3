clear all; close all; clc;

global dict;

im_uint8 = imread('cameraman.tif');

figure
imshow(im_uint8);
title("original image");
figure

% bloc = [1,1, 1, 4, 200, 200, 35, 4;...
%     1,100, 123, 4, 230, 240, 30, 4;...
%     1,1, 1, 4, 20, 200, 35, 65;...
%     1,1, 1, 4, 230, 200, 35, 65;...
%     1,1, 1, 4, 250, 200, 35, 234;...
%     1,1, 1, 4, 220, 200, 35, 143;...
%     11,11, 41, 44, 200, 200, 35, 0;...
%     14,12, 11, 44, 24, 20, 35, 34];
% hdecode = huffmanEncoding(bloc(:).');
% if(hdecode == bloc)
%     fprintf("YAY");
% else
%     fprintf("nooo");
% end

%% Define several quantization matrices
%Quantization matrix specified in JPEG spec for 50% quality
qmat50 = [16 11 10 16 24 40 51 61; 12 12 14 19 26 58 60 55;...
    14 13 16 24 40 57 69 56; 14 17 22 29 51 87 80 62; ...
    18 22 37 56 68 109 103 77; 24 35 55 64 81 104 113 92;...
    49 64 78 87 103 121 120 101; 72 92 95 98 112 100 103 99];
qmat_const_50 = round(ones([8 8]) * (sum(qmat50(:))/numel(qmat50(:))));

%make a lower quality quant matrix
qmat25 = make_qmat(25,qmat50);
qmat_const_25 = round(ones([8 8]) * (sum(qmat25(:))/numel(qmat25(:))));

%make a higher quality quant matrix
qmat98 = make_qmat(98,qmat50);
qmat_const_98 = round(ones([8 8]) * (sum(qmat98(:))/numel(qmat98(:))));

%% jpeg/inverse jpeg using quality 25 quantization matrix & constant equivalent
huff = jpeg(im_uint8, qmat25);
q25 = ijpeg(huff, qmat25);

err = immse(q25, im_uint8); % mean square error
peaksnr = psnr(q25, im_uint8); % PSNR
fprintf("Quality 25: err %f snr %f\n", err, peaksnr);

subplot(3,2,1);
imshow(q25,'Border','tight');
title(["Quality 25, SNR:" num2str(peaksnr)]);

huff = jpeg(im_uint8, qmat_const_25);
q_const_25 = ijpeg(huff, qmat_const_25);

err = immse(q_const_25, im_uint8); % mean square error
peaksnr = psnr(q_const_25, im_uint8); % PSNR
fprintf("Const 25: err %f snr %f\n", err, peaksnr);

subplot(3,2,2);
imshow(q_const_25,'Border','tight');
title(["Q25 constant equivalent, SNR:" num2str(peaksnr)]);




%% jpeg/inverse jpeg using quality 50 quantization matrix & constant equivalent
huff = jpeg(im_uint8, qmat50);
q50 = ijpeg(huff, qmat50);

err = immse(q50, im_uint8); % mean square error
peaksnr = psnr(q50, im_uint8); % PSNR
fprintf("Quality 50: err %f snr %f\n", err, peaksnr);

subplot(3,2,3);
imshow(q50,'Border','tight');
title(["Quality 50, SNR:" num2str(peaksnr)]);

huff = jpeg(im_uint8, qmat_const_50);
q_const_50 = ijpeg(huff, qmat_const_50);

err = immse(q_const_50, im_uint8); % mean square error
peaksnr = psnr(q_const_50, im_uint8); % PSNR
fprintf("Const 50: err %f snr %f\n", err, peaksnr);

subplot(3,2,4);
imshow(q_const_50,'Border','tight');
title(["Q50 constant equivalent, SNR:" num2str(peaksnr)]);


%% jpeg/inverse jpeg using quality 98 quantization matrix & constant equivalent
huff = jpeg(im_uint8, qmat98);
q98 = ijpeg(huff, qmat98);

err = immse(q98, im_uint8); % mean square error
peaksnr = psnr(q98, im_uint8); % PSNR
fprintf("Quality 98: err %f snr %f\n", err, peaksnr);

subplot(3,2,5);
imshow(q98,'Border','tight');
title(["Quality 98, SNR:" num2str(peaksnr)]);

huff = jpeg(im_uint8, qmat_const_98);
q_const_98 = ijpeg(huff, qmat_const_98);

err = immse(q_const_98, im_uint8); % mean square error
peaksnr = psnr(q_const_98, im_uint8); % PSNR
fprintf("Const 98: err %f snr %f\n", err, peaksnr);

subplot(3,2,6);
imshow(q_const_98,'Border','tight');
title(["Q98 constant equivalent, SNR:" num2str(peaksnr)]);

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
            
            %huffman decoding
            bdct = huffmanDecoding(bdct);
            
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
                        
            %encode 8x8 blocks using huffman encoding
            huff_bdct = huffmanEncoding(bdct(:).');
            
            xq(b_i, b_j) = huff_bdct;
        end
    end
    
    %encode blocks as huffman code
    %TEMPORARY: just return concatenated 8x8 DCT blocks
    huff = xq;
end

function arr_hcode = huffmanEncoding(bloc)
    global dict;
    
    s = [0:255]; % symbols
    
    totalCount = numel(bloc);
    prob = zeros(1,256);
    
    % compute cumulative prob
    for i = 0:255
        k = bloc == i;
        prob(i+1) = sum(k(:))/ totalCount; % num of time i occurs/total
    end
    
    if (sum(prob)~= 1)
        fprintf("\nprob=%f\n" , sum(prob))
    end
    
    % dictionary
    dict = huffmandict(s, prob);
    
    % Huffman encoding
    hcode = huffmanenco(bloc, dict);
    arr_hcode = vect2arr(hcode, 8, 8);
    
    % Huffman Decoding  -- just for checking
    hDecode = huffmandeco(hcode,dict);    
    hDecode = vect2arr(hDecode, 8, 8);
end

function arr_hdecode = huffmanDecoding(bloc)
    global dict;

    % Huffman Decoding  -- just for checking
    hDecode = huffmandeco(bloc,dict);    
    hDecode = vect2arr(hDecode, 8, 8);

end

%vector to array conversion
function arr = vect2arr(vec, m, n) 
    arr_row = 1;
    arr_col = 1;
    vec_si = 1;
    for x = 1:m
        for y = 1:n
            arr(x,y)=vec(vec_si);
            arr_col = arr_col+1;
            vec_si = vec_si + 1;
        end
        arr_row = arr_row+1;
    end

    arr = arr.';
end


function qmat = make_qmat(Q, qmat)
    % Determine S
    if (Q < 50)
        S = 5000/Q;
    else
        S = 200 - 2*Q;
    end
    
    Tb = qmat;

    Ts = floor((S*Tb + 50) / 100);
    Ts(Ts == 0) = 1; % Prevent division by 0
    
    qmat = Ts;
end
