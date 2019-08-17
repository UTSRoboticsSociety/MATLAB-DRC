rosshutdown;
clc; clear;
close all;
pause on

% setenv('ROS_MASTER_URI','http://172.19.119.104:11311')  % set the NUC's IP Address, 11311 is the ROS port
% setenv('ROS_IP','172.19.127.215')   % set the PC's current IP Address
rosinit;

image_sub = rossubscriber('/camera/color/image_raw/');
depth_sub = rossubscriber('/camera/depth/image_rect_raw');
steer_svc = rossvcclient('/droid/steer');
steer_msg = rosmessage(steer_svc);
power_svc = rossvcclient('/droid/power');
power_msg = rosmessage(power_svc);

error_all = zeros(4000,1);
i = 0;

setPower(power_svc, power_msg, 60);

while true
    i = i + 1;
    
    image = receive(image_sub, 10);
    image = readImage(image);
    
  
    %filtering the left and right lane
    blue_left = true;
    [filtered_left_img, filtered_right_img, filtered_green_img] = filterLanes(image, blue_left);

    lane_error = laneSteerPeak(filtered_left_img, filtered_right_img, filtered_green_img);
    if lane_error == 8888    %reached finish line
        steerAngle(steer_svc, steer_msg, 0);
        pause(0.5);
        setPower(power_svc, power_msg, 0);
        return
    end
    
    try
        error = depthSteer(lane_error, depth_sub);
    end
    error_all(i) = error;
    
    if error == 9999    %cannot pass an object       
        steerAngle(steer_svc, steer_msg, lane_error*(-1));
        setPower(power_svc, power_msg, -70);
        pause(0.5);
    else
        steerAngle(steer_svc, steer_msg, error);
        
        if error > 30 || error < -30
            setPower(power_svc, power_msg, 46); %46
        else
            setPower(power_svc, power_msg, 52); %52
        end
    end
    
end
