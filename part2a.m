clear all; close all; clc;

im_uint8 = imread('cameraman.tif');

figure
imshow(im_uint8);
title("original image");
figure

hdecode = huffmanEncoding(im_uint8);
if(hdecode == im_uint8)
    fprintf("YAY");
else
    fprintf("nooo");
end

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

function hDecode = huffmanEncoding(im_uint8)

    s = [0:255]; % symbols
    
    % prob
    [m,n] = size(im_uint8);
    Totalcount = m*n;
    cnt = 1;
    sigma = 0;
    
    %compute cumulative prob
    for i = 0:255
        k=im_uint8==i;
        count(cnt)=sum(k(:))
        %pro array is having the probabilities
        pro(cnt)=count(cnt)/Totalcount;
        sigma=sigma+pro(cnt);
        cumpro(cnt)=sigma;
        cnt=cnt+1;
    end
    
    
    % dictionary
    dict = huffmandict(s, pro);
    
    %function which converts array to vector
    vec_size = 1;
    for p = 1:m
        for q = 1:n
            newvec(vec_size) = im_uint8(p,q);
            vec_size = vec_size+1;
        end
    end
    
    % huffman encoding
    hcode = huffmanenco(newvec, dict);
    
    %Huffman Decoding
    dhsig1 = huffmandeco(hcode,dict);
    
    %convertign dhsig1 double to dhsig uint8
    dhsig = uint8(dhsig1);
    
    
    %vector to array conversion
    dec_row=sqrt(length(dhsig));
    dec_col=dec_row;
    %variables using to convert vector 2 array
    arr_row = 1;
    arr_col = 1;
    vec_si = 1;
    for x = 1:m
        for y = 1:n
            hDecode(x,y)=dhsig(vec_si);
            arr_col = arr_col+1;
            vec_si = vec_si + 1;
        end
    arr_row = arr_row+1;
    end

    
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
