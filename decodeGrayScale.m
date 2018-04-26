function [ ] = decodeGrayScale( inputImageFileName,bitPlane,decodeFile)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Decode the string hidden in the secret image
% 
% Input : 
% inputImageFileName : secret image which contain the secret message
% bitPlane : Bit plane to hide the string message (1<= bitplane <=8).
% decodeFile : Text file which saved the decode message.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stegoImage = imread(inputImageFileName);
bitToSet = bitPlane;
bitsPerLetter = 8;	% For ASCII, this is 8.
byteToStoreLength = 4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Decode Process

% Decode first 4 letter to get the string length
numPixelsNeededForString = int64(byteToStoreLength) * int64(bitsPerLetter);
retrievedBits = double(bitget(stegoImage(1:numPixelsNeededForString), bitToSet));

% Convert back to decimal to know how many pixels we need to read
% Remember to add the byte that use to store the length
stringLength = bi2de(retrievedBits) + byteToStoreLength;
numPixelsNeededForString = int64(stringLength) * int64(bitsPerLetter);
% Get the number of bit we need
retrievedBits = double(bitget(stegoImage(1:numPixelsNeededForString), bitToSet));
letterCount = 1;
% Skip first 4 letter since that it store the length of string
nextPixel = 4 * bitsPerLetter + 1; 
for k = nextPixel : bitsPerLetter : numPixelsNeededForString
	% Get the binary bits for one character.
	thisString = retrievedBits(k:(k+bitsPerLetter-1));
	% Turn it from a binary string into an ASCII number (integer) 
    % and then convert into a character/letter.
	currentChar = char(bin2dec(num2str(thisString)));
	% Store this letter as we build up the recovered string.
	recoveredString(letterCount) = currentChar;
	letterCount = letterCount + 1;
end

% Save the decrypted message to text file 
fileID = fopen(decodeFile,'wb');
fwrite(fileID,char(recoveredString),'char');
fclose(fileID);

end

