clc; clear;
close all; 
objects = imaqfind;
delete(objects)

vid = VideoReader('LOcombo.avi');

%INPUT RESOLUTION HERE
res_x = 480;            %<<<
res_y = 270;            %<<<
%^^ INPUT RESOLUTION ^^
%270p = 480x270
%480p = 854x480
%720p = 1280x720

%how far down the screen can a lane appear before stopping the car
stop_threshhold = res_y / 10 * 8;
top_y = res_y / 10 * 2;
bot_y = res_y / 10 * 4;
HROI_length = res_x / 3 * 2; %right now its 2/3 of the screen resolution

while hasFrame(vid)
    
    Image = readFrame(vid);
    %want 10fps, 0.1s * 100 = 10, 10mod10 = 0
    %0.2s *100 = 20, 20mod10 = 0
    currentTime = vid.CurrentTime * 100;
    
    if mod(currentTime, 10) == 0
        
        %HSV filtering: individually masked
        %make filter for lab to, combine lab and hsv
        
        blueHSVImage = createBlueHSVMask(Image);
        blueLABImage = createBlueLABMask(Image);
        blueImg = (blueHSVImage & blueLABImage);

        yellowHSVImage = createYellowHSVMask(Image);
        yellowLABImage = createYellowLABMask(Image);
        yellowImg = (yellowHSVImage & yellowLABImage);
        
        %filters the images individually
        filteredBlue = bwareaopen(blueImg, 50);
        filteredYellow = bwareaopen(yellowImg, 50);
        
        %now create areas of interest for these 2 filtered images
        %also need to create a switch between left blue and right blue
        
        %this is the switch function
        %0 means blue lane to the left, 1 means blue lane to the right
        x = 1;
        [leftImage, rightImage] = colourSwitch(x, filteredBlue, filteredYellow);
        
        %making left lane ROIs
        [left_sum_1, left_sum_2, left_sum_top] = leftSum(res_y, top_y, HROI_length, leftImage);
        
        %making right lane ROIs
        [right_sum_1, right_sum_2, right_sum_top] = rightSum(res_x, res_y, top_y, HROI_length, rightImage);

        %find peaks individually for each side of the screen
        %left side first
        [left_peak_1_matrix, left_peak_2_matrix, left_peak_top_matrix] = leftPeaks(left_sum_1, left_sum_2, left_sum_top);
        
        %find peaks for right side now
        [right_peak_1_matrix, right_peak_2_matrix, right_peak_top_matrix] = rightPeaks(right_sum_1, right_sum_2, right_sum_top);
        
        %these values tells us how big the matrix is ie. [m, n] etc
        %there should be only 0 or 1 value
        %left side first
        [left_matrix_1, left_matrix_2, left_matrix_top] = LeftMatrixSizes(left_peak_1_matrix, left_peak_2_matrix, left_peak_top_matrix);
        
        %right side now
        [right_matrix_1, right_matrix_2, right_matrix_top] = RightMatrixSizes(right_peak_1_matrix, right_peak_2_matrix, right_peak_top_matrix);
        
        %logic for different peak conditions
        %stop threshhold logic

        if left_matrix_2(1) ~= 0 && left_peak_2_matrix(2) > stop_threshhold || right_matrix_2(1) ~= 0 && right_peak_2_matrix(2) > stop_threshhold
            
            %stop signal
            error = 42069;
            textStr = 'STOP: WRONG WAY';
            AnnotatedImage = insertText(Image, [res_x / 2 - 50 stop_threshhold], textStr, 'FontSize', 24, 'BoxColor', 'r');
            imshow(AnnotatedImage);
 
        else
            
            %left lane logic
            [left_x1, left_y1, left_x2, left_y2] = leftCoords(top_y, bot_y, HROI_length, left_matrix_1, left_matrix_2, left_matrix_top, left_peak_1_matrix, left_peak_2_matrix, left_peak_top_matrix);
            
            %right lane logic
            [right_x1, right_y1, right_x2, right_y2] = rightCoords(res_x, top_y, bot_y, HROI_length, right_matrix_1, right_matrix_2, right_matrix_top, right_peak_1_matrix, right_peak_2_matrix, right_peak_top_matrix);

            %need to have both lane line equations as they are different
            %lengths, so we can get an average result
            
            %now get the average to find our midpoints
            [lane_average_x, lane_average_y] = laneAverage(top_y, left_x2, right_x2);

            %get the absolute spot and direction the car is facing
            [absolute_direction_x, absolute_direction_y] = absoluteDirection(res_x, res_y);

            %work out the error margin
            error = round(lane_average_x - absolute_direction_x, 0);

            %draw everything on video
            textStr = ['Deviation: ' num2str(error) ' pixels'];

            AnnotatedImage = insertText(Image, [bot_y absolute_direction_y + 5], textStr, 'FontSize', 16);

            imshow(AnnotatedImage);

            hold on

            plot([left_x1, left_x2],[left_y1, left_y2],'LineWidth',2,'Color','r'); %draw left lane

            plot([right_x1, right_x2],[right_y1, right_y2],'LineWidth',2,'Color','r'); %draw right lane

            plot(lane_average_x, top_y, 'bo'); %plot guidance circle

            plot(absolute_direction_x, top_y, 'bo'); %plot absolute direction of vehicle

            plot([absolute_direction_x, absolute_direction_x],[top_y, bot_y],'LineWidth',2,'Color','y'); %absolute position and direction of the car
        
        end
  
    end
    
    F = getframe(gcf);
end
    
video = VideoWriter('rightCorner.avi', 'Uncompressed AVI');
video.FrameRate = 10;
open(video)
writeVideo(video, F)
close(video)
%wont work if lane is too wide and comes upon a straight, horizontal line suddenly

function [leftImage, rightImage] = colourSwitch(x, filteredBlue, filteredYellow)

    if x == 0
        leftImage = filteredBlue;
        rightImage = filteredYellow;
    else
        leftImage = filteredYellow;
        rightImage = filteredBlue;
    end

end

function [left_sum_1, left_sum_2, left_sum_top] = leftSum(res_y, top_y, HROI_length, leftImage)

    left_area_1 = imcrop(leftImage, [1, top_y + 5, 10, res_y]);
    left_sum_1 = sum(left_area_1, 2);

    left_area_2 = imcrop(leftImage, [HROI_length - 5, top_y + 5, 10, res_y]); %2/3s of the way across the screen
    left_sum_2 = sum(left_area_2, 2);
    %this ROI needs to be optimized
    %by default, will make this 1/3 of the height of image
    %this ROI is nested between the other 2, not overlapping
    left_area_top = imcrop(leftImage, [1, top_y - 5, HROI_length + 5, 10]);
    left_sum_top = sum(left_area_top, 1);

end

function [right_sum_1, right_sum_2, right_sum_top] = rightSum(res_x, res_y, top_y, HROI_length, rightImage)
    right_area_2 = imcrop(rightImage, [res_x - HROI_length - 5, top_y + 5, 10, res_y]);
    right_sum_2 = sum(right_area_2, 2);

    right_area_1 = imcrop(rightImage, [res_x - 10, top_y + 5, 10, res_y]); %2/3s of the way across the screen
    right_sum_1 = sum(right_area_1, 2);

    %this ROI is nested ON TOP the other 2, not overlapping
    right_area_top = imcrop(rightImage, [res_x - HROI_length - 5, top_y - 5, HROI_length + 5, 10]);
    right_sum_top = sum(right_area_top, 1);

end

function [left_peak_1_matrix, left_peak_2_matrix, left_peak_top_matrix] = leftPeaks(left_sum_1, left_sum_2, left_sum_top)

    [left_peaks_1, left_locs_1] = findpeaks(left_sum_1,'MinPeakProminence',5,'MinPeakDistance',50);
    left_peak_1_matrix = [left_peaks_1, left_locs_1];
    
    [left_peaks_2, left_locs_2] = findpeaks(left_sum_2,'MinPeakProminence',5,'MinPeakDistance',50);
    left_peak_2_matrix = [left_peaks_2, left_locs_2];
    
    [left_peaks_top, left_locs_top] = findpeaks(left_sum_top,'MinPeakProminence',5,'MinPeakDistance',100);
    left_peak_top_matrix = [left_peaks_top, left_locs_top];
    
end

function [right_peak_1_matrix, right_peak_2_matrix, right_peak_top_matrix] = rightPeaks(right_sum_1, right_sum_2, right_sum_top)
        
    [right_peaks_1, right_locs_1] = findpeaks(right_sum_1,'MinPeakProminence',5,'MinPeakDistance',50);
    right_peak_1_matrix = [right_peaks_1, right_locs_1];

    [right_peaks_2, right_locs_2] = findpeaks(right_sum_2,'MinPeakProminence',5,'MinPeakDistance',50);
    right_peak_2_matrix = [right_peaks_2, right_locs_2];

    [right_peaks_top, right_locs_top] = findpeaks(right_sum_top,'MinPeakProminence',5,'MinPeakDistance',100);
    right_peak_top_matrix = [right_peaks_top, right_locs_top];

end

function [left_matrix_1, left_matrix_2, left_matrix_top] = LeftMatrixSizes(left_locs_1, left_locs_2, left_locs_top)
        
    [m_left_1, n_left_1] = size(left_locs_1);
    left_matrix_1 = [m_left_1, n_left_1];

    [m_left_2, n_left_2] = size(left_locs_2);
    left_matrix_2 = [m_left_2, n_left_2];

    [m_left_top, n_left_top] = size(left_locs_top);
    left_matrix_top = [m_left_top, n_left_top];

end

function [right_matrix_1, right_matrix_2, right_matrix_top] = RightMatrixSizes(right_locs_1, right_locs_2, right_locs_top)

    [m_right_1, n_right_1] = size(right_locs_1);
    right_matrix_1 = [m_right_1, n_right_1];
    
    [m_right_2, n_right_2] = size(right_locs_2);
    right_matrix_2 = [m_right_2, n_right_2];
    
    [m_right_top, n_right_top] = size(right_locs_top);
    right_matrix_top = [m_right_top, n_right_top];
    
end

function [left_x1, left_y1, left_x2, left_y2] = leftCoords(top_y, bot_y, HROI_length, left_matrix_1, left_matrix_2, left_matrix_top, left_peak_1_matrix, left_peak_2_matrix, left_peak_top_matrix)

    if left_matrix_1(1) == 0
        left_x1 = 2;
        left_y1 = bot_y + 5;
    else
        left_x1 = 5;
        left_y1 = left_peak_1_matrix(2) + top_y + 5;
    end

    if left_matrix_2(1) == 0
        if left_matrix_top(2) == 0
            left_x2 = 1;
            left_y2 = top_y;
        else
            left_x2 = left_peak_top_matrix(2);
            left_y2 = top_y;
        end
    else
        left_x2 = HROI_length;
        left_y2 = left_peak_2_matrix(2) + top_y + 5;
    end

end

function [right_x1, right_y1, right_x2, right_y2] = rightCoords(res_x, top_y, bot_y, HROI_length, right_matrix_1, right_matrix_2, right_matrix_top, right_peak_1_matrix, right_peak_2_matrix, right_peak_top_matrix)
            
    if right_matrix_1(1) == 0
        right_x1 = res_x - 2;
        right_y1 = bot_y + 5;
    else
        right_x1 = res_x - 2;
        right_y1 = right_peak_1_matrix(2) + top_y + 5;
    end

    if right_matrix_2(1) == 0
        if right_matrix_top(2) == 0
            right_x2 = res_x - 1;
            right_y2 = top_y;
        else
            right_x2 = right_peak_top_matrix(2) + res_x - HROI_length + 5;
            right_y2 = top_y;
        end
    else
        right_x2 = res_x - HROI_length;
        right_y2 = right_peak_2_matrix(2) + top_y + 5;
    end
end

function [lane_average_x, lane_average_y] = laneAverage(top_y, left_x2, right_x2)
            
    lane_average_x = (left_x2 + right_x2) / 2;
    lane_average_y = top_y;

end

function [absolute_direction_x, absolute_direction_y] = absoluteDirection(res_x, bot_y)
            
    absolute_direction_x = res_x / 2;
    absolute_direction_y = bot_y;

end

function [BW,maskedRGBImage] = createBlueHSVMask(RGB)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder app. The colorspace and
%  range for each channel of the colorspace were set within the app. The
%  segmentation mask is returned in BW, and a composite of the mask and
%  original RGB images is returned in maskedRGBImage.

% Auto-generated by colorThresholder app on 18-Jun-2019
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2hsv(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.528;
channel1Max = 0.798;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.000;
channel2Max = 1.000;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.223;
channel3Max = 1.000;

% Create mask based on chosen histogram thresholds
sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

% Initialize output masked image based on input image.
maskedRGBImage = RGB;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end

function [BW,maskedRGBImage] = createBlueLABMask(RGB)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder app. The colorspace and
%  range for each channel of the colorspace were set within the app. The
%  segmentation mask is returned in BW, and a composite of the mask and
%  original RGB images is returned in maskedRGBImage.

% Auto-generated by colorThresholder app on 21-Jun-2019
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2lab(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 16.161;
channel1Max = 90.968;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 3.403;
channel2Max = 16.124;

% Define thresholds for channel 3 based on histogram settings
channel3Min = -38.105;
channel3Max = 0.483;

% Create mask based on chosen histogram thresholds
sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

% Initialize output masked image based on input image.
maskedRGBImage = RGB;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end
        
function [BW,maskedRGBImage] = createYellowHSVMask(RGB)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder app. The colorspace and
%  range for each channel of the colorspace were set within the app. The
%  segmentation mask is returned in BW, and a composite of the mask and
%  original RGB images is returned in maskedRGBImage.

% Auto-generated by colorThresholder app on 22-Jun-2019
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2hsv(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.147;
channel1Max = 0.201;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.000;
channel2Max = 1.000;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.675;
channel3Max = 1.000;

% Create mask based on chosen histogram thresholds
sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

% Initialize output masked image based on input image.
maskedRGBImage = RGB;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end

function [BW,maskedRGBImage] = createYellowLABMask(RGB)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder app. The colorspace and
%  range for each channel of the colorspace were set within the app. The
%  segmentation mask is returned in BW, and a composite of the mask and
%  original RGB images is returned in maskedRGBImage.

% Auto-generated by colorThresholder app on 21-Jun-2019
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2lab(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 16.161;
channel1Max = 90.968;

% Define thresholds for channel 2 based on histogram settings
channel2Min = -18.172;
channel2Max = 16.124;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 37.580;
channel3Max = 76.853;

% Create mask based on chosen histogram thresholds
sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

% Initialize output masked image based on input image.
maskedRGBImage = RGB;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end