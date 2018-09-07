basicimg = imread('SimulatedImages/org_1.png');
projimg = imread('SimulatedImages/proj1_2.png');
C = makecform('srgb2lab');
labimg = applycform(projimg, C);
% figure(1);
h = fspecial('average',3);
% figure(1)
% imshow(basicimg);
% imshow(labimg);
L = labimg(:,:,1);
thresh = L>252;
figure(10)
imshow(thresh);
threshdilate = imdilate(thresh, ones(7));
% figure(3)
% imshow(imfill(imcomplement(threshdilate),'holes'));
objects=bwlabel(threshdilate);
% TODO: use regionprops to find circles/projected circles - eccentricity? 
% figure(2)
% imshow(objects,[]);
% colorbar;

w=fspecial('log',[3 3],0.5);
BW=im2bw(projimg,0.1);
filtered_img=imfilter(BW,w,'replicate');
se=strel('square',3);
figure(5);
% imshow(imcomplement(imdilate(filtered_img,ones(7))));
erdilim = imerode(imdilate(filtered_img, ones(3)),se);
filledim = imfill(erdilim,'holes');
imshow(filledim);

% This average filtering works best since more complex filters like log
% can't deal with the high amounts of noise
% Don't seem to need imerode or dilate
BWp=im2bw(projimg,0.1);
h = fspecial('average',3);
filtered_imgp=imfilter(projimg,h,'replicate');
% filtered_imgp=medfilt1(im2double(projimg));
filtered_imgp=im2bw(filtered_imgp,0.4);
% figure(4);
% imshow(imfill(imcomplement(filtered_imgp),'holes'));
% erdilim = imerode(imdilate(filtered_imgp, ones(3)),se);
% filledimp = imfill(erdilim,'holes');
filledimp = imfill(imcomplement(filtered_imgp),'holes');
% imshow(filledimp);

% figure(4);
% imshow(imcomplement(imerode(imdilate(filtered_img, ones(7)),se)));

CC = bwconncomp(filledimp);
s  = regionprops(filledimp, 'Area','Centroid');
BW3=zeros(CC.ImageSize);

% Find objects
% for p=1:CC.NumObjects  %loop through each image
%      BW3(CC.PixelIdxList{p}) = p; %set the image
%      figure(4)
%      imshow(BW3,[0 CC.NumObjects]) %display with fixed intestiy range
%      pause(.5)  %pause for 0.5 seconds
% end

% Filter objects on region prop
% This works in isolating the circles; though may be more robust to discard
% largest object
areas = [s.Area];
allcentroids = [s.Centroid];allcentroids=reshape(allcentroids,[length(allcentroids)/2,2]);
[maxval,maxidx] = max(areas);
centroids = {};
% BW4 = ismember(labelmatrix(CC),maxidx);
filledimp(ismember(labelmatrix(CC),maxidx)) = 0;
for p=1:CC.NumObjects  %loop through each image
     if p ~= maxidx
         centroids = [centroids, allcentroids(p,:)]; %set the image
     end
  
end
% figure(5)
% imshow(BW3,[0 1]) %display with fixed intestiy range
figure(6)
imshow(filledimp,[0 1]) %display with fixed intestiy range
