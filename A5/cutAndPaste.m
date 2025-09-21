USE_INTERACTIVE = true;
close('all');   % close all open figures so we start with a clean slate!


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RESULT 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% your own images
im_bg = im2double(imread('https://raw.githubusercontent.com/bhargavichinni/comp572/main/A5/result5/waterfall.JPG'));        % background image
im_obj = im2double(imread('https://raw.githubusercontent.com/bhargavichinni/comp572/main/A5/result5/godzilla.JPG'));       % source image

% % Get source region mask (extracted object) from the user
% %  First draw a polygon on the source image for applying the mask

[poly_x, poly_y] = getPolygonForMask(im_obj);
disp("Copy the values of the vectors poly_x and poly_y from the " + ...
    "Command Window below and hard code them inside your code for " + ...
    "submission via the Grader website.");
poly_x        % display x coords of polygon
poly_y        % display y coords of polygon
% Once you have these coordinates, comment out the call to getPolygonForMask() 
% and hard code the coordinates instead.

objmask = poly2mask(poly_x, poly_y, size(im_obj, 1), size(im_obj, 2));
 
% % Get the bottom center location on the target image by using the function
% % getBottomCenterLoc interactively

[center_x, bottom_y] = getBottomCenterLoc(im_bg);
disp("Copy the values of center_x and bottom_y from the " + ...
    "Command Window below and hard code them inside your code for " + ...
    "submission via the Grader website.");
center_x        % display x coord where center of object should be placed
bottom_y        % display y coord where bottom of object should be placed
% Once you have these coordinates, comment out the call to getBottomCenterLoc()
% and hard code the coordinates instead.

padding = 64;   % You may want to play with this parameter
[im_s, mask_s] = alignSource(im_obj, objmask, im_bg, center_x, bottom_y, padding);
mask_s = im2double(mask_s);

% % Apply your blending method
result2 = cut_and_paste(im_bg, im_s, mask_s);

% Display:  target image, source image, mask, then blended result
figure; montage({im_bg, im_obj, mask_s, result2});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is your function that implements the blending method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function im_cut_and_paste = cut_and_paste(im_bg, im_s, mask_s)
    mask = mask_s > 0.5;
    
    % Make sure mask has 3 channels to match the images
    if size(im_bg,3) > 1
        mask = repmat(mask, [1 1 size(im_bg,3)]);
    end
    
    % Simple overlay: keep background where mask=0, take source where mask=1
    im_cut_and_paste = im_bg .* (~mask) + im_s .* mask;

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


function [center_x, bottom_y] = getBottomCenterLoc(im_t)
    disp('choose target bottom-center location');
    fig=figure; hold off; imagesc(im_t); axis image;
    figure(fig)
    [center_x, bottom_y, ~] = ginput(1);
    close(fig);
end


function [im_s2, mask2] = alignSource(im_s, mask, im_t, center_x, bottom_y, padding)
    % Inputs:  source image, mask, target/background image, ...
    % center_x, bottom_y are the coordinates of the bottom center location on the target image
    % padding is the number of extra rows/coumns to include around the
    % object to allow for feathering/blending.

    % Outputs: an aligned source image and also an aligned blending mask.
    
    % find the bounding box of the mask, and enlarge it by the amount of
    % padding
    [y, x] = find(mask);
    y1 = min(y)-1-padding; y2 = max(y)+1+padding; 
    x1 = min(x)-1-padding; x2 = max(x)+1+padding;
    im_s2 = zeros(size(im_t));

    yind = (y1:y2);
    yind2 = yind - max(y) + round(bottom_y);
    xind = (x1:x2);
    xind2 = xind - round(mean(x)) + round(center_x);
    
    % if the padding exceeds the image boundaries,
    % clip to image boundary
    yind(yind > size(im_s, 1)) = size(im_s, 1);
    yind(yind < 1) = 1;
    xind(xind > size(im_s, 2)) = size(im_s, 2);
    xind(xind < 1) = 1;
   
    yind2(yind2 > size(im_t, 1)) = size(im_t, 1);
    yind2(yind2 < 1) = 1;
    xind2(xind2 > size(im_t, 2)) = size(im_t, 2);
    xind2(xind2 < 1) = 1;

    y = y - max(y) + round(bottom_y);
    x = x - round(mean(x)) + round(center_x);
    ind = y + (x-1)*size(im_t, 1);
    mask2 = false(size(im_t, 1), size(im_t, 2));
    mask2(ind) = true;
    
    im_s2(yind2, xind2, :) = im_s(yind, xind, :);    
end
