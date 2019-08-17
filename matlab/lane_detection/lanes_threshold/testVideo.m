testVid = VideoReader('lane3.avi');
% testVid.CurrentTime = 5.5;
% vidFrame = readFrame(testVid);

while hasFrame(testVid)
    currentFrame = readFrame(testVid);
    
    blueHSVImage = createBlueHSVMask(currentFrame);
    blueLABImage = createBlueLABMask(currentFrame);
%     blueRGBImage = createBlueRGBMask(currentFrame);
    blueImage = (blueHSVImage & blueLABImage);% | (blueLABImage & blueRGBImage);
    
    yellowHSVImage = createYellowHSVMask(currentFrame);
    yellowLABImage = createYellowLABMask(currentFrame);
%     yellowRGBImage = createYellowRGBMask(currentFrame);
    yellowImage = (yellowHSVImage & yellowLABImage);% | (yellowLABImage & yellowRGBImage);
    
    Image = imadd(blueImage, yellowImage);
    imshow(Image);
end
% imshow(vidFrame);