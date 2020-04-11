close all; clear; clc;

im = im2double(imread('cameraman.tif'));
[M, N] = size(im);

tr = zeros(M,N)  % transform of image

% transform rows (iteration 1)
for i = 1: N  
    for k = 1 : N/2
        tr(i,k) = (im(i, 2*k-1) + im(i, 2*k))/2; % average
        tr(i,(N/2)+k) = (im(i, 2*k-1) - im(i, 2*k))/2; 
    end
end

% transform half columns (iteration 2)
for j = 1: M  
    for k = 1 : M/2
        tr(j,k) = (tr(j, 2*k-1) + tr(j, 2*k))/2; % average
        tr(j,(N/2)+k) = (tr(j, 2*k-1) - tr(j, 2*k))/2; 
    end
end

figure, imshow(tr)
% inverse transform



