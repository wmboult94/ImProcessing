orthphoto = imread('westconcordorthophoto.png');
normphoto = imread('westconcordaerial.png');
% figure(1);
% imshow(orthphoto);
% figure(2);
% imshow(normphoto);
% cpselect(normphoto,orthphoto);
mytform = fitgeotrans(movingPoints, fixedPoints, 'projective');
mytform.T
projphoto = imwarp(normphoto,mytform);
figure(1)
imshow(projphoto);
figure(2)
imshow(orthphoto);