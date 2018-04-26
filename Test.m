messageFile = 'EncodeMessage.txt';
decodedFile = 'DecodeMessage.txt';
coverImage = 'lena_g.bmp';
secretImage = 'stego.bmp';
bitPlane = 1;
% Encode
encodeGrayScale(coverImage,messageFile,bitPlane,secretImage)
% Decode
decodeGrayScale(secretImage,bitPlane,decodedFile)
coverImage_read = imread(coverImage);
secretImage_read =imread(secretImage);
% MSE
meanSquareError = immse(coverImage_read, secretImage_read);
fprintf('\nThe mean-squared error is %0.4f', meanSquareError);
% PSN
peaksnr = psnr(secretImage_read,coverImage_read);
fprintf('\nThe peak signal-to-noise ratio  is %0.4f\n', peaksnr);
%%%%%% histogram %%%%%

figure(1);
[y1,x1] = imhist(coverImage_read);
plot(x1,y1);
hold on;
[y2,x2] = imhist(secretImage_read);
plot(x2,y2);
legend('original','stego-image');

