close all; clear; clc;

%im = im2double(imread('cameraman.tif'));
im = im2double(imread('peppers.png')); 

% forward transform
num_pass = 2;  % num of iterations
h = im;
[m, n, cnl] = size(im);
W = hmat([m, n]);
for pass = 1 : num_pass
    h_r = W * h(:,: ,1) * W.';   % = w*A*wT
    h_g = W * h(:,: ,2) * W.';
    h_b = W * h(:,: ,3) * W.';
end
subplot(2,2, 1)
imshow(h_r);

subplot(2, 2, 2)
imshow(h_g);

subplot(2, 2, 3)
imshow(h_b);

h(:,:,1) = h_r;
h(:,:,2) = h_g;
h(:,:,3) = h_b;

subplot(2, 2, 4)
imshow(h);

% inverse transform
for pass = 1 : num_pass
    h_r = pow2(num_pass)*W.'*h(:,:,1)*W;
    h_g = pow2(num_pass)*W.'*h(:,:,2)*W;
    h_b = pow2(num_pass)*W.'*h(:,:,3)*W;
end

figure;
subplot(2,2, 1)
imshow(h_r);

subplot(2, 2, 2)
imshow(h_g);

subplot(2, 2, 3)
imshow(h_b);

h(:,:,1) = h_r;
h(:,:,2) = h_g;
h(:,:,3) = h_b;

subplot(2, 2, 4)
imshow(h);



function Wn = hmat(N)
    Wn = zeros(N);
    for i = 1 : N/2
        Wn(i, 2*i - 1) = 1/2;
        Wn(i, 2*i) = 1/2;
        
        Wn(i + N/2, 2*i - 1) = -1/2;
        Wn(i + N/2, 2*i) = 1/2;
    end
end
