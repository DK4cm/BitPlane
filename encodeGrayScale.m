function [  ] = encodeGrayScale( inputImageFileName,StringFileTohide,bitPlane,outputImageFileName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to encrypt all string in a text file into Grayscale image.
% If the image is not Grayscale, it will convert it to Grayscale first.
% If the string to encrypt is larger than the image can hold, the string
% will be truncate.
%
% Input : 
% inputImageFileName : Cover image used to hide the message
% StringFileTohide : Text file contain message need to encrypt to grayscale
% image
% bitPlane : Bit plane to hide the string message (1<= bitplane <=8). It 
% should not bigger than 4, otherwise it will visually affect the secret image.
% outputImageFileName : Location of secret image to save
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bitsPerLetter = 8;	% For ASCII, this is 8
byteToStoreLength = 4;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read the coverimage and convert to gray level image
[grayCoverImage, storedColorMap] = imread(inputImageFileName);
[rows, columns, numberOfColorChannels] = size(grayCoverImage);
if numberOfColorChannels > 1    % Not gray image
    imwrite(grayCoverImage,strcat('backup-',inputImageFileName));% Backup first
	grayCoverImage = uint8(255 * mat2gray(rgb2gray(grayCoverImage)));
    imwrite(grayCoverImage,inputImageFileName);
elseif ~isempty(storedColorMap)
    imwrite(grayCoverImage,strcat('backup-',inputImageFileName));% Backup first
	% There's a colormap, so it's an indexed image, not a grayscale image.
    % Change it to RGB First
	grayCoverImage = ind2rgb(grayCoverImage, storedColorMap);
	% Now turn it into a gray scale image.
	grayCoverImage = uint8(255 * mat2gray(rgb2gray(grayCoverImage)));
    imwrite(grayCoverImage,inputImageFileName);
end
[rows, columns, numberOfColorChannels] = size(grayCoverImage);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read the message to be encrypted and convert to character array
fileID = fopen(StringFileTohide,'r');
dataRead = fread(fileID);
hiddenMessage = char(dataRead');
fclose(fileID);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set bitPlane make sue it is between 1 and 8
bitToSet = bitPlane; % should be 1-8 (>4 will be easier to observe)
if bitToSet < 1
	bitToSet = 1;
elseif bitToSet > 8
	bitToSet = 8;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use 4 byte to hold the length of the message to hide. Max (2^(4*8))=2^32
% letter
LengthBit = de2bi(length(hiddenMessage),byteToStoreLength * bitsPerLetter);
LengthBit = num2str(LengthBit); % convert bit array to string
LengthBit(isspace(LengthBit)) = '';% Replace all space

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert hidden string to ascill
asciiValues = hiddenMessage - 0;
stringLength = length(asciiValues);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if the image can hold the message,
% if cannot will truncate the message and show message the user
numPixelsInImage = numel(grayCoverImage);
numPixelsNeededForString = stringLength * bitsPerLetter + byteToStoreLength * bitsPerLetter;
if numPixelsNeededForString > numPixelsInImage
	asciiValues = asciiValues(1:floor(numPixelsInImage/bitsPerLetter));	% Truncate if larger than it can hold
	stringLength = length(asciiValues);	
	numPixelsNeededForString = stringLength * bitsPerLetter;
    fprintf('\nSize Can hold in image Plane%d is %d',bitPlane,numPixelsInImage);
    fprintf('\nSize need to Hide Message         %d\n',numPixelsNeededForString);
    disp('Message is too Large and will be truncate');
else
	% do nothing if enough space
    fprintf('\nSize Can hold in image Plane%d  %d',bitPlane,numPixelsInImage);
    fprintf('\nSize need to Hide Message       %d\n',numPixelsNeededForString);
    disp('Message can be hide into this image');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Encoding Process

% Convert from ASCII values in the range 0-255 to binary values of 0 and 1.
% Forced length to bitsPerLetter,otherwise if the length is less than
% bitsPerLetter,0 at left will be ommitted and make decode failed.
binaryAsciiString = dec2bin(asciiValues,bitsPerLetter)';
% Transpose it and string them all together into a row vector.
% This is the string we want to hide.  Each bit will go into one pixel.
binaryAsciiString = binaryAsciiString(:)';
% Add the LengthBit bit string to the front of message pattern
binaryAsciiString = [LengthBit,binaryAsciiString];
% make a copy of coverImage
stegoImage = grayCoverImage;
% set all bits needs to 0 first
stegoImage(1:numPixelsNeededForString) = bitset(stegoImage(1:numPixelsNeededForString), bitToSet, 0);
% find the linear indexes which have a 1 value in binaryAsciiString
oneIndexes = find(binaryAsciiString == '1'); 
% Then set only those indexes to 1 in the specified bit plane.
stegoImage(oneIndexes) = bitset(stegoImage(oneIndexes), bitToSet, 1);
% Write the image to file
imwrite(stegoImage,outputImageFileName);
end

