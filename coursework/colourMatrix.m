function result = colourMatrix(filename)
%%%%%% Specify lab values of colours %%%%%%%%
% Colours chosen based upon the colour of the noisy images %
white = [128,128]; % colour code 1
blue = [145,85]; % colour code 2
yellow = [116,190]; % colour code 3
green = [65,185]; % colour code 4
red = [170,150]; % colour code 5
colours = [white; blue; yellow; green; red];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% Read in images %%%%%%%%%
basicimg = imread('SimulatedImages/org_1.png');
targimg = imread(filename);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%% Image registration %%%%%%%%%
%%% Filter images for image registration
% Average filter, then fill holes to be left with the corner circles, and the grid
% filled in as one big square
h = fspecial('average',3);
filtered_imgp=imfilter(targimg,h,'replicate');filtered_imgb=imfilter(basicimg,h,'replicate');
% filtered_imgp=medfilt1(im2double(projimg));
filtered_imgp=im2bw(filtered_imgp,0.4);filtered_imgb=im2bw(filtered_imgb,0.4);
filledimp = imfill(imcomplement(filtered_imgp),'holes');filledimb = imfill(imcomplement(filtered_imgb),'holes');
% figure(1)
% imshow(filledimp);

%%% Find regions
CC = bwconncomp(filledimp);CCb = bwconncomp(filledimb);
s  = regionprops(filledimp, 'Area','Centroid');sb  = regionprops(filledimb, 'Area','Centroid');

% Filter objects in base image on region prop
% Largest object will be the square grid, others will be the 4 circles
areasb = [sb.Area];
allcentroidsb = [sb.Centroid];allcentroidsb=vec2mat(allcentroidsb,2);
[maxvalb,maxidxb] = max(areasb);
fixedPoints = [];
% filledimb(ismember(labelmatrix(CCb),maxidxb)) = 0;
for p=1:CCb.NumObjects  %loop through each image
     if p ~= maxidxb % then object is one of the circles
         fixedPoints = [fixedPoints; allcentroidsb(p,:)]; %set the fixed points
     end
  
end

% Filter objects in target image on region prop
% Largest object will be the square grid, others will be the 4 circles
areas = [s.Area];
allcentroids = [s.Centroid];allcentroids=vec2mat(allcentroids,2);
[maxval,maxidx] = max(areas);
movingPoints = [];
filledimp(ismember(labelmatrix(CC),maxidx)) = 0;
% figure(5);
% imshow(filledimp);
for p=1:CC.NumObjects  %loop through each image
     if p ~= maxidx && s(p).Area > 10 % then object is one of the circles
         movingPoints = [movingPoints; allcentroids(p,:)]; %set the moving points
     end
  
end

% Transform the target image to the ref image 
mytform = fitgeotrans(movingPoints, fixedPoints, 'projective');
projimg = imwarp(targimg,mytform,'OutputView',imref2d(size(basicimg)));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%% Filter images for square identfication %%%%%%%%%
C = makecform('srgb2lab');
% labimg = applycform(refimg, C);
w=fspecial('log',[3 3],0.5); % log filter for detecting edges
BW=im2bw(basicimg,0.1);BWref=im2bw(projimg,0.1);
filtered_img=imfilter(BW,w,'replicate');filtered_imgref=imfilter(BWref,w,'replicate');
filledim = imcomplement(imdilate(filtered_img,ones(7))); % dilate to fill circles and grid outlines
filledimref = imcomplement(imdilate(filtered_imgref,ones(7)));
h = fspecial('average',3);
filterim = imfilter(projimg,h,'replicate');
filterim=imcomplement(im2bw(filterim,0.4));
% figure(2);
% imshow(filledim);

%%% Median filter rgb channels to aid colour identification
medfilimg = projimg;
medfilimg(:,:,1) = medfilt2(medfilimg(:,:,1), [9 9]);
medfilimg(:,:,2) = medfilt2(medfilimg(:,:,2), [9 9]);
medfilimg(:,:,3) = medfilt2(medfilimg(:,:,3), [9 9]);
labimg = applycform(medfilimg, C); % convert to lab
% filledimref = imdilate(im2bw(medfilimg,0.5),ones(7));
% figure(2);
% imshow(labimg);
L = labimg(:,:,1);
a = labimg(:,:,2);
b = labimg(:,:,3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%% Find centroids of squares of base image %%%%%%%%
s = regionprops(filledim, 'Centroid', 'Extent','Area');
CC = bwconncomp(filledim);

centroids = [];
% BW2=zeros(CC.ImageSize);
for p=1:CC.NumObjects  %loop through each object of base image
    if s(p).Extent < 0.9 || s(p).Area < 10 % squares will have extent ~1
         % regions with small area just noise so ignore
        % filledim(ismember(labelmatrix(CC),p)) = 0; % for display purposes
        continue;
    else
         centroids = [centroids; s(p).Centroid];
    end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% Find the squares, read a and b values into grids %%%%
grida = zeros(4,4);
gridb = zeros(4,4);
gridl = zeros(4,4);
gridcol = zeros(4,4);

% imshowpair(refimg,medfilimg,'montage');
% filledimb(ismember(labelmatrix(CC),maxidxb)) = 0;

for p=1:CC.NumObjects  %loop through objects of original image
    if s(p).Extent < 0.9 || s(p).Area < 10 % squares will have extent ~1
%         filledimref(ismember(labelmatrix(CC),p)) = 0;
        continue;
    else
        temp = abs(s(p).Centroid - centroids); % find matching square in ref image
        tempmin = min(temp);
        [tf,index] = ismember(temp,tempmin, 'rows');
        index = find(index==1); % find index between 1-16 of ref square centroids
        
        Lav = mean(L(ismember(labelmatrix(CC),p)));
        Aav = mean(a(ismember(labelmatrix(CC),p))); % get average a colour of square
        Bav = mean(b(ismember(labelmatrix(CC),p))); % get average b colour of squar
        avs = [Aav, Bav];
        
        [mindist,colcode] = min(sqrt(sum((colours-avs).^2,2))); % find euclidean distance between ref colour and average square colour
        x = ceil(index/4);
        y = index - (x-1)*4; % convert to full row index to grid coords
        grida(y,x) = Aav;
        gridb(y,x) = Bav;
        gridl(y,x) = Lav;
        gridcol(y,x) = colcode;
    end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% Display ref image squares, return final colour grid of results %%%%%
% figure(4);
% imshow(filledim);
result = gridcol;
% avals = grida
% bvals = gridb
end