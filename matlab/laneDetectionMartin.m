rosshutdown;
clc; clear;
close all; 
% 424 x 240
% objects = imaqfind;
% delete(objects);

% setenv('ROS_MASTER_URI','http://172.19.119.104:11311')  % set the NUC's IP Address, 11311 is the ROS port
% setenv('ROS_IP','172.19.127.215')   % set the PC's current IP Address
rosinit;

image_sub = rossubscriber('/camera/color/image_raw/');
steer_svc = rossvcclient('/droid/steer');
steer_msg = rosmessage(steer_svc);
power_svc = rossvcclient('/droid/power');
power_msg = rosmessage(power_svc);

power_msg.Power = 35;
error_all = zeros(4000,1);
i = 0;
    
try
    power_svc.call(power_msg, 'Timeout', 10);
end

while true
    i = i + 1;
    
    image = receive(image_sub, 10);
    image = readImage(image);
        
    %filtering the left and right lane
    blue_left = false;
    [filtered_left_img filtered_right_img] = filterLanes(image, blue_left);
    
    combined_img = (filtered_left_img | filtered_right_img);

    error = errorCalLiang(filtered_left_img, filtered_right_img);
    error = error*(-1);
    error_all(i) = error;
    
    steer_msg.Angle = error;
    try
        steer_svc.call(steer_msg, 'Timeout', 10);
        disp(steer_svc.call);
    end
    
    if error > 30 || error < -30
        power_msg.Power = 25;
        try
            power_svc.call(power_msg, 'Timeout', 10);
        end
    else
        power_msg.Power = 32;
        try
            power_svc.call(power_msg, 'Timeout', 10);
        end
    end
    
    imshow(combined_img);
 
end
