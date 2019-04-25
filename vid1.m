clc; clear;
close all; 
objects = imaqfind
delete(objects)

obj = imaq.VideoDevice('winvideo', 4, 'YUY2_1280x720', ...
                        'ROI', [169 64 824 656], ...
                        'ReturnedColorSpace', 'rgb', ...
                        'HardwareTriggering', 'on');
%src = getselectedsource(vid);

vid.FramesPerTrigger = 1;

vid.FramesPerTrigger = Inf;

vid.ReturnedColorspace = 'rgb';

vid.ROIPosition = [169 64 824 656];

%preview(vid);

%start(vid);
while true
Frame = step(obj);
imshow(Frame);
end


%stop(vid);


%{
vid = videoinput('winvideo'); %select input device
hvpc = vision.VideoPlayer;   %create video player object

src = getselectedsource(vid);
vid.FramesPerTrigger =1;
vid.TriggerRepeat = Inf;
vid.ReturnedColorspace = 'rgb';
src.FrameRate = '30.0000';
start(vid)


runLoop = true;
%start main loop for image acquisition
while runLoop
  imgO=getdata(vid,1,'uint8');    %get image from camera
  hvpc.step(imgO);    %see current image in player
  
  runLoop = isOpen(hvpc);
end
%}