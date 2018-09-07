% final = colourMatrix('SimulatedImages/noise_3.png')

liveimg = imread('LiveImage2/IMG_4758.jpg');
refimg = imread('LiveImage2/IMG_4757.jpg');
% I2= imbothat(liveimg, strel('disk', 85));
% I2 = im2bw(liveimg,0.4);
img = rgb2gray(liveimg);

Hadj = HistNorm(refimg,liveimg);
image(Hadj);
figure, imshow(Hadj)

% background = imopen(liveimg,strel('disk',45));
% imgl = img - background
% figure,imshow(imgl)
% figure, imshow(imerode(im2bw(imadjust(imgl),0.05),ones(5)))
% k = 5;
% sigma1 =  0.1;
% sigma2 = sigma1*k;
% 
% hsize = [3,3];
% 
% h1 = fspecial('gaussian', hsize, sigma1);
% h2 = fspecial('gaussian', hsize, sigma2);
% 
% gauss1 = imfilter(img,h1,'replicate');
% gauss2 = imfilter(img,h2,'replicate');
% 
% dogImg = gauss2 - gauss1;
% 
% % figure, imshow(gauss1)
% 
% w=fspecial('log',[3 3],0.15);
% filtered_img=imfilter(img,w,'replicate');
% % figure, imshow(filtered_img)
% 
%BW = edge(img,'sobel');
% figure, imshow(BW);
%figure, imshow(imfill(imdilate(BW,ones(17)),'holes'))
% figure, imshow(imdilate(BW,ones(3)))

% dinfo = dir('SimulatedImages/*.png');
% c = containers.Map
% % grids = zeros(4,4,length(dinfo));
% for K = 1 : length(dinfo)
%     filename = strcat('SimulatedImages/',dinfo(K).name);
%     final = colourMatrix(filename);
%     c(dinfo(K).name) = final;
% %     grids(:,:,K) = final;
%     dinfo(K).name
%     c(dinfo(K).name)
% end

