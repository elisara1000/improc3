close all; clear; clc;

im = im2double(imread('cameraman.tif'));

% forward transform
num_pass = 2;  % num of iterations
h = im;
W = hmat(size(im));
for pass = 1 : num_pass
    h = W * h;
    h = h * W.';    % = w*A*wT
end
imshow(h);


% inverse transform
for pass = 1 : num_pass
    h = pow2(num_pass)*W.'*h*W;
end

figure, imshow(h);


function Wn = hmat(N)
    Wn = zeros(N);
    for i = 1 : N/2
        Wn(i, 2*i - 1) = 1/2;
        Wn(i, 2*i) = 1/2;
        
        Wn(i + N/2, 2*i - 1) = -1/2;
        Wn(i + N/2, 2*i) = 1/2;
    end
end
