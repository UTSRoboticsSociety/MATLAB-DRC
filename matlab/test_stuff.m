%% DEPTH TEST
depth_sub = rossubscriber('/camera/depth/image_rect_raw');

while true
    depth = receive(depth_sub, 10);
    depth_image = readImage(depth);
    depth_image = depth_image*50;
    imshow(depth_image);
end


%% IMAGE TEST
color_sub = rossubscriber('/camera/color/image_raw');
while true
    color = receive(color_sub, 10);
color_image = readImage(color);
imshow(color_image);
end


%% VFH
rosshutdown;
clc; clear;
close all; 

rosinit;

depth_sub = rossubscriber('/camera/depth/image_rect_raw');
steer_svc = rossvcclient('/droid/steer');
steer_msg = rosmessage(steer_svc);

depth_img_width = 424;
depth_img_height = 240;
camera_field_of_view = 1.487021; %radians (~85 deg)

depth_pixel_layers = 20;
depth_pixel_border = 30;
ranges_matrix = zeros(depth_pixel_layers,depth_img_width);
ranges = zeros(1,depth_img_width);

VFH = robotics.VectorFieldHistogram;
VFH.DistanceLimits = [0.6 1.6];
VFH.RobotRadius = 0.23;
VFH.SafetyDistance = 0.07;
VFH.MinTurningRadius = 0.55;
VFH.HistogramThresholds = [0.6 1.6];
VFH.UseLidarScan = true;

while true
    depth = receive(depth_sub, 10);
    depth_image = readImage(depth);
    depth_image(:,1:depth_pixel_border) = 0;
    for i = 1:depth_pixel_layers
        ranges_matrix(i,:) = depth_image(depth_img_height/2 + i - 25,:);
    end
    ranges(1,:) = mean(ranges_matrix,1);
    ranges = flip(ranges);
    ranges = double(ranges)/1000;
    angles = linspace((-camera_field_of_view/2),(camera_field_of_view/2),depth_img_width);
    ranges = ranges./cos(angles);

    scan = lidarScan(ranges,angles);
    plot(scan);

    targetDir = 0;
    steeringDir = VFH(scan,targetDir);
    steeringDir = rad2deg(steeringDir);
    
    steer_msg.Angle = steeringDir;
    
    try
        steer_svc.call(steer_msg, 'Timeout', 10);
    end

end

%%
for i = 1:depth_img_width
    if test_out(i) == 1
        ranges(i) = 0;
    end
end
