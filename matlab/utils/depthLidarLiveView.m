%% VFH
rosshutdown;
clc; clear;
close all; 

rosinit();

depth_sub = rossubscriber('/camera/depth/image_rect_raw');

depth_img_width = 424;
depth_img_height = 240;
camera_field_of_view = 1.487021; %radians (~85 deg)

depth_mid_line = 28;
depth_pixel_border = 50;
ranges = zeros(1,depth_img_width);

VFH = robotics.VectorFieldHistogram;
VFH.DistanceLimits = [0.25 1.3];
VFH.RobotRadius = 0.23;
VFH.SafetyDistance = 0.08;
VFH.MinTurningRadius = 0.65;
VFH.HistogramThresholds = [0.25 1.3];
VFH.UseLidarScan = true;
VFH.TargetDirectionWeight = 5;
VFH.PreviousDirectionWeight = 0.5;
VFH.CurrentDirectionWeight = 0.5;

while true
    depth = receive(depth_sub, 10);
    depth_image = readImage(depth);
    ranges(1,:) = depth_image(depth_img_height/2 - depth_mid_line,:);
    ranges = flip(ranges);
    ranges = double(ranges)/1000;
    angles = linspace((-camera_field_of_view/2),(camera_field_of_view/2),depth_img_width);
    ranges = ranges./cos(angles);

    scan = lidarScan(ranges,angles);
    scan = removeInvalidData(scan,'RangeLimits',[0.25 1.6]);
    plot(scan);

    targetDir = deg2rad(0);
    steeringDir = VFH(scan,deg2rad(targetDir));
    if isnan(steeringDir)
        steeringDir = targetDir
    else
        steeringDir = rad2deg(steeringDir)
    end
end
