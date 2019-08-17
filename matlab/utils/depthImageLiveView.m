rosshutdown;
rosinit;
depth_sub = rossubscriber('/camera/depth/image_rect_raw');

while true
    depth = receive(depth_sub, 10);
    depth_image = readImage(depth);
    depth_image = depth_image*50;
    imshow(depth_image);
end