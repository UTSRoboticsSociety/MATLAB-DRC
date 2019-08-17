clc; clear;
close all; 
objects = imaqfind
delete(objects)

vid = VideoReader('LaneSample0.avi');
video = VideoWriter('laneSeg.avi', 'Uncompressed AVI');
video.FrameRate = 6;
open(video)
while hasFrame(vid)
    Frame = readFrame(vid);
    yellowImg = createMaskYellow(Frame);
    blueImg = createMaskBlue(Frame);
    imshow(imadd(yellowImg, blueImg));
    F = getframe(gcf);
    writeVideo(video, F);
    %writeVideo(writerObj, Frame);
end


close(video)
%{
writerObj = VideoWriter('LaneSample.avi');
writerObj.FrameRate = 6;
open(writerObj);
close(writerObj);
%}

function [BW,maskedRGBImage] = createMaskYellow(RGB)
I = rgb2hsv(RGB);
channel1Min = 0.095;
channel1Max = 0.217;
channel2Min = 0.574;
channel2Max = 1.000;
channel3Min = 0.343;
channel3Max = 1.000;
sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;
maskedRGBImage = RGB;
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;
end

function [BW,maskedRGBImage] = createMaskBlue(RGB)
I = rgb2hsv(RGB);

channel1Min = 0.558;
channel1Max = 0.710;
channel2Min = 0.202;
channel2Max = 1.000;

channel3Min = 0.328;
channel3Max = 0.708;

sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

maskedRGBImage = RGB;
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end

