close('all');   % close all open figures so we start with a clean slate!

% Image links
I=im2double(imread('https://raw.githubusercontent.com/bhargavichinni/comp572/main/A6/turtle.JPG'));

% Interactively draw the foreground mask as a polygon

[poly_x, poly_y] = getPolygonForMask(I);
disp("Copy the values of the vectors poly_x and poly_y from the " + ...
    "Command Window below and hard code them inside your code for " + ...
    "submission via the Grader website.");
poly_x        % display x coords of polygon
poly_y        % display y coords of polygon
% Once you have these coordinates, comment out the call to getPolygonForMask() 
% and hard code the coordinates instead.


mask = poly2mask(poly_x, poly_y, size(I, 1), size(I, 2));

% Define the bokeh filter shape
% A simple disk filter is provided as default
% For extra credit you may optionally define a different shape, e.g., hexagon, starburst, heart etc.

radius = 20;            % choose this carefully for each image
bokeh_shape = fspecial('disk', radius);

result2a = method1(I, mask, bokeh_shape);
result2b = method2(I, mask, bokeh_shape);
result2 = method3(I, mask, bokeh_shape);

figure; montage({I, result2a, result2b, result2});



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This are the functions that implement bokeh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function result = method1(I, mask, filter)
    I_blur = imfilter(I, filter, 'replicate');
    result = I_blur .* (1 - mask) + I .* mask;
end

function result = method2(I, mask, filter)
    bg = I .* (1 - mask);
    bg_blur = imfilter(bg, filter, 'replicate');
    result = bg_blur .* (1 - mask) + I .* mask;
end

function result = method3(I, mask, filter)
    B = I .* repmat(1 - mask, [1 1 size(I,3)]);
    num = imfilter(B, filter, 'replicate');
    denom = imfilter(1 - mask, filter, 'replicate');
    den  = repmat(denom, [1 1 size(I,3)]);
    
    H = zeros(size(I));
    nonzero = den ~= 0;
    H(nonzero) = num(nonzero) ./ den(nonzero);

    result = H .* repmat(1 - mask, [1 1 size(I,3)]) + I .* repmat(mask, [1 1 size(I,3)]);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Below are helper functions.  You DO NOT NEED TO MODIFY
% any of the code below.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [poly_x, poly_y] = getPolygonForMask(im)
    % Asks user to draw polygon around input image.  
    disp('Draw polygon around source object in clockwise order, q to stop');
    fig=figure; hold off; imagesc(im); axis image;
    poly_x = [];
    poly_y = [];
    while 1
        figure(fig)
        [x, y, b] = ginput(1);
        if b=='q'
            break;
        end
        poly_x(end+1) = x;
        poly_y(end+1) = y;
        hold on; plot(poly_x, poly_y, '*-');
    end
    close(fig);
end