rosshutdown;
rosinit;

workingDir = tempname;
mkdir(workingDir)
mkdir(workingDir,'images')

image_sub = rossubscriber('/camera/color/image_raw');

i = 1;

outputVideo = VideoWriter(fullfile(workingDir,'half_run.avi'));
outputVideo.FrameRate = 10;
open(outputVideo)

while true
    i = i + 1;
    image_msg = receive(image_sub, 10);
    image = readImage(image_msg);
    imshow(image);
    writeVideo(outputVideo,image)
end

rosshutdown;