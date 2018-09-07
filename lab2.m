image = imread('mms.jpg');
C = makecform('srgb2lab');
img = applycform(image,C);
% imshow(img);
doubleimg = lab2double(img);
L = doubleimg(:,:,1);
a = doubleimg(:,:,2);
b = doubleimg(:,:,3);
% imshow(b);
% LabHistPlot(a,b);
bmin = 59;
bmax = 73;
amin = 48;
amax = 67;
in = inpolygon(a, b, [amin,amax], [bmin,bmax]);
newimgd = imdilate(in, ones(7));
newimge = imerode(newimgd, ones(7));
% figure(3)
% imshow(in)
figure(1)
imshow(newimgd)
figure(2)
imshow(newimge)
% imshow(L);
% imshow(a, [-128,128]);
% imshow(b, [-128, 128]);
% colorbar;
% imshow(newimg);
% colorbar;