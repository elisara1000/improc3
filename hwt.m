close all; clear; clc;

%im = im2double(imread('cameraman.tif'));
im = im2double(imread('peppers.png')); 

% forward transform
num_pass = 2;  % num of iterations
h = im;
[m, n, cnl] = size(im);
W = hmat([m, n]);
for pass = 1 : num_pass
    h(:,: ,1) = W * h(:,: ,1) * W.';   % = w*A*wT
    h(:,: ,2) = W * h(:,: ,2) * W.';
    h(:,: ,3) = W * h(:,: ,3) * W.';
end
subplot(2,2, 1)
imshow(h(:,: ,1)), title("Red component");

subplot(2, 2, 2)
imshow(h(:,: ,2)), title("Green component");

subplot(2, 2, 3)
imshow(h(:,: ,3)), title("Blue component");

subplot(2, 2, 4)
imshow(h), title("Together");

% inverse transform
for pass = 1 : num_pass
    h(:,: ,1) = pow2(num_pass)*W.'*h(:,:,1)*W;
    h(:,: ,2) = pow2(num_pass)*W.'*h(:,:,2)*W;
    h(:,: ,3) = pow2(num_pass)*W.'*h(:,:,3)*W;
end

figure;
subplot(2,2, 1)
imshow(h(:,: ,1)), title("Red component");

subplot(2, 2, 2)
imshow(h(:,: ,2)), title("Green component");

subplot(2, 2, 3)
imshow(h(:,: ,3)), title("Blue component");

subplot(2, 2, 4)
imshow(h), title("Together");



function Wn = hmat(N)
    Wn = zeros(N);
    for i = 1 : N/2
        Wn(i, 2*i - 1) = 1/2;
        Wn(i, 2*i) = 1/2;
        
        Wn(i + N/2, 2*i - 1) = -1/2;
        Wn(i + N/2, 2*i) = 1/2;
    end
end
