Image = image;

%INPUT RESOLUTION HERE
res_x = 424;            %<<<
res_y = 240;            %<<<
%^^ INPUT RESOLUTION ^^
%270p = 480x270
%480p = 854x480
%720p = 1280x720

focalLength = [299.8130 299.4886];
principalPoint = [217.5308 120.8126];
imageSize = [res_x res_y];

camIntrinsics = cameraIntrinsics(focalLength,principalPoint,imageSize);

height = 0.3;
pitch = 15;

sensor = monoCamera(camIntrinsics,height,'Pitch',pitch);

distAhead = 2;
spaceToOneSide = 1;
bottomOffset = 0.5;

outView = [bottomOffset,distAhead,-spaceToOneSide,spaceToOneSide];

outImageSize = [NaN,250];

birdsEye = birdsEyeView(sensor,outView,outImageSize);

BEV = transformImage(birdsEye, Image);

imshow(BEV);