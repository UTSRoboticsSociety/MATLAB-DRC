clc; clear;
close all; 
% 424 x 240
% objects = imaqfind;
% delete(objects);

setenv('ROS_MASTER_URI','http://172.19.119.104:11311')  % set the NUC's IP Address, 11311 is the ROS port
setenv('ROS_IP','172.19.127.215')   % set the PC's current IP Address
rosinit;

image_sub = rossubscriber('/camera/color/image_raw/compressed');

while true
    
    image = receive(image_sub, 10);
    image = readImage(image);
    imshow(image);
        
%     %filtering the left and right lane
%     blue_left = true;
%     [filtered_left_img filtered_right_img] = filterLanes(image, blue_left);
% 
%     error = errorCalculation(filtered_left_img, filtered_right_img);
%     
%     combined_img = (filtered_left_img & filtered_right_img);
%     
% %     imshow(combined_img);
 
end
