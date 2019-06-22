clc; clear;
close all; 
objects = imaqfind;
delete(objects);

vid = VideoReader('LOcombo.avi');

while hasFrame(vid) %while the video is running
    
    Image = readFrame(vid);
    %want 10fps, 0.1s * 100 = 10, 10mod10 = 0
    %0.2s *100 = 20, 20mod10 = 0
    currentTime = vid.CurrentTime * 100;    %hack to get frame every 10th frame
    
    if mod(currentTime, 10) == 0
        
        %filtering the left and right lane
        blue_left = true;
        [filtered_left_img filtered_right_img] = filterLanes(Image, blue_left);
        
        error = errorCalculation(filtered_left_img, filtered_right_img)
  
    end
    
    F = getframe(gcf);
end
