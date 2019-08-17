rosshutdown;
rosinit;
image_sub = rossubscriber('/camera/color/image_raw');

while true
    image_msg = receive(image_sub, 10);
    image = readImage(image_msg);

    blue_left = true;
    [filtered_left_img, filtered_right_img, filtered_green_img] = filterLanesNew(image, blue_left);
    
    filtered_left_img = birdsEyeGenerate(filtered_left_img);
    image = birdsEyeGenerate(image);
    
    filtered_left_img = imcrop(filtered_left_img,[0,100,188,100]);
    %% Detect Lines
    % Perform Hough Transform
    [H,T,R] = hough(filtered_left_img);

    % Identify Peaks in Hough Transform
    hPeaks = houghpeaks(H,5,'NhoodSize',[15 15]);

    % Extract lines from hough transform and peaks
    hLines = houghlines(filtered_left_img,T,R,hPeaks,...
        'FillGap',25,'MinLength',25);
    
    
    %% View results
    % Overlay lines
    [linePos,markerPos] = getVizPosArray(hLines);

    if(~isempty(hLines))
        lineFrame = insertShape(image,'Line',linePos,...
            'Color','blue','LineWidth',5);
        outFrame = insertObjectAnnotation(lineFrame,...
            'circle',markerPos,'','Color','yellow','LineWidth',5);
    else
        outFrame = image;
    end
    imshow(outFrame);
end

rosshutdown;