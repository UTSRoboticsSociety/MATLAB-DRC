rosshutdown;
rosinit;
image_sub = rossubscriber('/camera/color/image_raw');
depth_sub = rossubscriber('/camera/depth/image_rect_raw');
image_msg = receive(image_sub, 10);
image = readImage(image_msg);

imshow(image);

blue_left = true;
[filtered_left_img, filtered_right_img, filtered_green_img] = filterLanesNew(image, blue_left);

error = laneSteerHough(filtered_left_img, filtered_right_img, filtered_green_img);
error
% try
%     error = depthSteer(error, depth_sub)
% end
rosshutdown;