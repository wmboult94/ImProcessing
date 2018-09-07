img=imread('mms.jpg');
imdoub=im2double(img);
% imfilt = medfilt1(imdoub);
h = fspecial('average',3);
% imfilter(imdoub,h,'replicate');
imnoisy = imnoise(imdoub,'gaussian');
imfilt = imfilter(imnoisy,h,'replicate');
% imshow(imnoisy);
% imfilt2 = medfilt1(imnoisy);
% imshow(imfilt2);
imshowpair(imnoisy, imfilt, 'montage')