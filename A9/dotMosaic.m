close all;
% All of the images used in this assignment are my own images!!
% NOTE: For some reason, my figures were not showing when I ran this code on Matlab locally.  I would get 6 blank figure windows.
% I tried a bunch of things to get my figures to appear locally, but I could not get them to show.  I tested and picked size values
% purely based off of what I see in this Matlab Grader window.  If possible, please judge my results based off of what you see here
% as I have no idea what my images look like when I run this script locally.

% Image 1: grayscale dot mosaic
im = im2double(rgb2gray(imread('https://raw.githubusercontent.com/bhargavichinni/comp572/main/A9/mountain.JPG')));
% resize if necessary
mosaic = dot_mosaic_gray(im, 45);  % Choose Size carefully!
figure; montage({im, mosaic});

% Image 2: grayscale dot mosaic
im = im2double(rgb2gray(imread('https://raw.githubusercontent.com/bhargavichinni/comp572/main/A9/pumpkin.JPG')));
% resize if necessary
mosaic = dot_mosaic_gray(im, 55);  % Choose Size carefully!
figure; montage({im, mosaic});

% Image 3: grayscale dot mosaic
im = im2double(rgb2gray(imread('https://raw.githubusercontent.com/bhargavichinni/comp572/main/A9/neo.JPG')));
% resize if necessary
mosaic = dot_mosaic_gray(im, 60);  % Choose Size carefully!
figure; montage({im, mosaic});

% Image 4: color dot mosaic
im = im2double(imread('https://raw.githubusercontent.com/bhargavichinni/comp572/main/A9/bhar.JPG'));
% resize if necessary
mosaic = dot_mosaic_color(im, 50);  % Choose Size carefully!
figure; montage({im, mosaic});

% Image 5: color dot mosaic
im = im2double(imread('https://raw.githubusercontent.com/bhargavichinni/comp572/main/A9/flowers.JPG'));
% resize if necessary
mosaic = dot_mosaic_color(im, 40);  % Choose Size carefully!
figure; montage({im, mosaic});

% Image 6: color dot mosaic
im = im2double(imread('https://raw.githubusercontent.com/bhargavichinni/comp572/main/A9/palace.JPG'));
% resize if necessary
mosaic = dot_mosaic_color(im, 55);  % Choose Size carefully!
figure; montage({im, mosaic});


function result = dot_mosaic_gray(im, Size)
    % 1) shrink so the shorter dim equals Size pixels
    [H,W] = size(im);
    s = Size / min(H,W);
    small = imresize(im, s, 'bilinear');              % low-res guide image
    [h,w] = size(small);

    % 2) pick odd grid size k so dots fit nicely
    k = max(3, floor(min(H,W) / Size));               % initial guess
    if mod(k,2)==0, k = k-1; end                      % force odd
    radiusMax = (k-1)/2;

    % 3) allocate output (white background)
    result = ones(h*k, w*k);

    % 4) draw per-pixel black disk with area ∝ (1 - p)
    for i = 1:h
        for j = 1:w
            p = small(i,j);                           % brightness in [0,1]
            r = radiusMax * sqrt(max(0, 1 - p));     % area proportionality
            block = ones(k,k);                        % white k×k tile
            if r > 0
                m = circle_mask(k, r);                % logical disk
                block(m) = 0;                         % black ink
            end
            % paste into final image
            rr = (i-1)*k + (1:k);
            cc = (j-1)*k + (1:k);
            result(rr,cc) = block;
        end
    end
end

function result = dot_mosaic_color(im, Size)
    [H,W,~] = size(im);
    s = Size / min(H,W);
    small = imresize(im, s, 'bilinear');              % h×w×3
    [h,w,~] = size(small);

    k = max(3, floor(min(H,W) / Size));
    if mod(k,2)==0, k = k-1; end
    radiusMax = (k-1)/2;

    result = ones(h*k, w*k, 3);                       % white background

    for i = 1:h
        for j = 1:w
            block = ones(k,k,3);                      % start white
            for c = 1:3
                p = small(i,j,c);                     % channel brightness
                r = radiusMax * sqrt(max(0, 1 - p)); % bigger r for darker ch.
                if r > 0
                    m = circle_mask(k, r);
                    % channel "ink": drop channel to 0 where the disk is
                    tmp = block(:,:,c);
                    tmp(m) = 0;
                    block(:,:,c) = tmp;
                end
            end
            rr = (i-1)*k + (1:k);
            cc = (j-1)*k + (1:k);
            result(rr,cc,:) = block;
        end
    end
end

function M = circle_mask(k, r)
% Returns a logical k×k mask with a filled circle of radius r centered.
    c = (k+1)/2;
    [X,Y] = meshgrid(1:k, 1:k);
    M = (X-c).^2 + (Y-c).^2 <= r.^2;
end
