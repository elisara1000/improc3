close all; clear; clc;

im = im2double(imread('cameraman.tif'));
[M, N] = size(im);

tr = im;  % transform of image

% transform rows (iteration 1)
for i = 1: N  
    for k = 1 : N/2
        tr(i,k) = (tr(i, 2*k-1) + tr(i, 2*k))/2; % average
        tr(i,(N/2)+k) = (tr(i, 2*k-1) - tr(i, 2*k))/2; 
    end
end

% transform half columns (iteration 2)
for j = 1: M
    for k = 1 : M/2
        tr(k, j) = (tr(j, 2*k-1) + tr(j, 2*k))/2; % average
        tr((M/2)+k, j) = (tr(j, 2*k-1) - tr(j, 2*k))/2; 
    end
end

figure, imshow(tr)

inv = tr;

% inverse
for j = 1 : M
    pos = 1;
    for k = 1 : M/2      
        s = tr(k, j);
        d = tr((M/2)+k, j);
        
        inv(pos, j) = s + d;
        inv(pos+1, j) = s + d;
        
        pos = pos + 2;
    end
end

% rows
for i = 1 : N
    pos = 1;
    for k = 1 : N/2      
        s = tr(i, k);
        d = tr(i, (N/2)+k);
        
        inv(i, pos) = s + d;
        inv(i, pos+1) = s + d;
        
        pos = pos + 2;
    end
end

figure, imshow(inv)
% inverse transform


W8 = hmat(8)

function Wn = hmat(N)
    Wn = zeros(N);
    for i = 1 : N/2
        Wn(i, 2*i - 1) = 1/2;
        Wn(i, 2*i) = 1/2;
        
        Wn(i + N/2, 2*i - 1) = -1/2;
        Wn(i + N/2, 2*i) = 1/2;
    end
end



