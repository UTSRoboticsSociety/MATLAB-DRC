function error = laneSteerHough(filtered_left_img,filtered_right_img, filtered_green_img)
    midlane_k = 0.1;
    angle_k = 0.8;

    % BEV
    filtered_left_img = birdsEyeGenerate(filtered_left_img);
    filtered_right_img = birdsEyeGenerate(filtered_right_img);
    
    filtered_left_img = imcrop(filtered_left_img,[0,100,188,50]);
    filtered_right_img = imcrop(filtered_right_img,[0,100,188,50]);
    
    % Left image hough
    [H_l,T_l,R_l] = hough(filtered_left_img);

    % Identify Peaks in Hough Transform
    hPeaks_l = houghpeaks(H_l,1);

    % Extract lines from hough transform and peaks
    hLines_l = houghlines(filtered_left_img,T_l,R_l,hPeaks_l);
    
    if isempty(hLines_l)
        left_pixel_offset = 94;
        left_angle = 0;
    else
        if hLines_l.point1(2) >= hLines_l.point2(2)
            left_pixel_offset = 94 - hLines_l.point1(1);
        else
            left_pixel_offset = 94 - hLines_l.point2(1);
        end
        
        left_angle = hLines_l.theta;
    end

    % Right image hough
    [H_r,T_r,R_r] = hough(filtered_right_img);

    % Identify Peaks in Hough Transform
    hPeaks_r = houghpeaks(H_r,1);

    % Extract lines from hough transform and peaks
    hLines_r = houghlines(filtered_right_img,T_r,R_r,hPeaks_r);
    
    if isempty(hLines_r)
        right_pixel_offset = 94;
        right_angle = 0;
    else
        if hLines_r.point1(2) >= hLines_r.point2(2)
            right_pixel_offset = hLines_r.point1(1) - 94;
        else
            right_pixel_offset = hLines_r.point2(1) - 94;
        end
        
        right_angle = hLines_r.theta;
    end
    
    midlane_error = (left_pixel_offset - right_pixel_offset)*midlane_k;
    angle_error = (- right_angle - left_angle)*angle_k;
    
    error = midlane_error + angle_error;
end
