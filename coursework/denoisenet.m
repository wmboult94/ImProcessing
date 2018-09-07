basicimg = imread('SimulatedImages/org_1.png');
refimg = imread('SimulatedImages/noise_2.png');

noisyR = refimg(:,:,1);
noisyG = refimg(:,:,2);
noisyB = refimg(:,:,3);

net = denoisingNetwork('dncnn');

denoisedR = denoiseImage(noisyR,net);
denoisedG = denoiseImage(noisyG,net);
denoisedB = denoiseImage(noisyB,net);

denoisedRGB = cat(3,denoisedR,denoisedG,denoisedB);
imshow(denoisedRGB)
title('Denoised Image')
