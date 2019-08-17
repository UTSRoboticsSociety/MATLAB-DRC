rosshutdown;
rosinit;
% image_sub = rossubscriber('/camera/color/image_raw');
image_sub = rossubscriber('/device_0/sensor_1/Color_0/image/data');

while true
    image_msg = receive(image_sub, 10);
    image = readImage(image_msg);

    blue_left = true;
    [filtered_left_img, filtered_right_img, filtered_green_img] = filterLanes(image, blue_left);

    combined_img = (filtered_left_img | filtered_right_img);
    imshow(combined_img);
end

rosshutdown;