basicimg = imread('SimulatedImages/org_1.png');
projimg = imread('SimulatedImages/proj1_2.png');
C = makecform('srgb2lab');
labimg = applycform(basicimg, C);

% This average filtering works best since more complex filters like log
% can't deal with the high amounts of noise
% Don't seem to need imerode or dilate
h = fspecial('average',3);
filtered_imgp=imfilter(projimg,h,'replicate');filtered_imgb=imfilter(basicimg,h,'replicate');
filtered_imgp=medfilt1(im2double(projimg));
figure(10)
imshow(filtered_imgp)
filtered_imgp=im2bw(filtered_imgp,0.4);filtered_imgb=im2bw(filtered_imgb,0.4);
filledimp = imfill(imcomplement(filtered_imgp),'holes');filledimb = imfill(imcomplement(filtered_imgb),'holes');
% imshowpair(filtered_imgb,filledimb,'montage');
% imshowpair(projimg,filledimp,'montage');



% figure(4);
% imshow(imcomplement(imerode(imdilate(filtered_img, ones(7)),se)));

CC = bwconncomp(filledimp);CCb = bwconncomp(filledimb);
s  = regionprops(filledimp, 'Area','Centroid');sb  = regionprops(filledimb, 'Area','Centroid');
BW3=zeros(CC.ImageSize);

% Filter objects on region prop
% This works in isolating the circles; though may be more robust to discard
% largest object
areasb = [sb.Area];
allcentroidsb = [sb.Centroid];allcentroidsb=vec2mat(allcentroidsb,2);
[maxvalb,maxidxb] = max(areasb);
fixedPoints = [];
% BW4 = ismember(labelmatrix(CC),maxidx);
filledimb(ismember(labelmatrix(CCb),maxidxb)) = 0;
for p=1:CCb.NumObjects  %loop through each image
     if p ~= maxidxb
         fixedPoints = [fixedPoints; allcentroidsb(p,:)]; %set the image
     end
  
end

% Filter objects on region prop
% This works in isolating the circles; though may be more robust to discard
% largest object
areas = [s.Area];
allcentroids = [s.Centroid];allcentroids=vec2mat(allcentroids,2);
[maxval,maxidx] = max(areas);
movingPoints = [];
% BW4 = ismember(labelmatrix(CC),maxidx);
filledimp(ismember(labelmatrix(CC),maxidx)) = 0;
for p=1:CC.NumObjects  %loop through each image
     if p ~= maxidx
         movingPoints = [movingPoints; allcentroids(p,:)]; %set the image
     end
  
end
% figure(5)
% imshow(BW3,[0 1]) %display with fixed intestiy range
% figure(6)
% imshow(filledimp,[0 1]) %display with fixed intestiy range

mytform = fitgeotrans(movingPoints, fixedPoints, 'projective');
mytform.T
projphoto = imwarp(projimg,mytform,'OutputView',imref2d(size(basicimg)));
figure(1)
labim2 = applycform(imsharpen(projphoto),C);
imshowpair(basicimg,projphoto,'montage');

% TODO: detect squares except max sized square (this is the whole grid),
% then order into grid co-ords based on their x and y co-ords (min x, y is
% 1,1 in grid, max x, y is 4,4). Then, take an average value over colour in
% square, find distance to r,g,b,y, colour is min distance.