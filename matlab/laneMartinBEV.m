clc; clear;
close all; 
objects = imaqfind;
delete(objects)

vid = VideoReader('BirdsEye2.avi');

%INPUT RESOLUTION HERE
res_x = 424;            %<<<
res_y = 240;            %<<<
%^^ INPUT RESOLUTION ^^
%270p = 480x270
%480p = 854x480
%720p = 1280x720

%how big the birds eye image becomes
BEV_x = res_x;
BEV_y = res_x;

%work out what you want to work with in the birds eye image
BEV_left = BEV_x / 4;
BEV_right = BEV_x / 4 * 3;

stop_threshhold = BEV_y / 10 * 10;
top_y = BEV_y / 10 * 8;
bot_y = BEV_y / 10 * 9.5;
HROI_length = (BEV_right - BEV_left) / 3 * 2;

focalLength = [299.8130 299.4886];
principalPoint = [217.5308 120.8126];
imageSize = [res_x res_y];

camIntrinsics = cameraIntrinsics(focalLength,principalPoint,imageSize);

height = 0.3;
pitch = 15;

sensor = monoCamera(camIntrinsics,height,'Pitch',pitch);

distAhead = 3;
spaceToOneSide = 1;
bottomOffset = 0.5;

outView = [bottomOffset,distAhead,-spaceToOneSide,spaceToOneSide];

outImageSize = [BEV_x, BEV_y];

birdsEye = birdsEyeView(sensor,outView,outImageSize);

while hasFrame(vid)
    
    Image = readFrame(vid);
    %want 10fps, 0.1s * 100 = 10, 10mod10 = 0
    %0.2s *100 = 20, 20mod10 = 0
    currentTime = vid.CurrentTime * 100;
    
    if mod(currentTime, 10) == 0
        
        %HSV filtering: individually masked
        %make filter for lab to, combine lab and hsv
        BEV = transformImage(birdsEye, Image);
        
        blueHSVImage = createBlueHSVMask(BEV);
        blueLABImage = createBlueLABMask(BEV);
        blueImg = (blueHSVImage | blueLABImage);

        yellowHSVImage = createYellowHSVMask(BEV);
        yellowLABImage = createYellowLABMask(BEV);
        yellowImg = (yellowHSVImage | yellowLABImage);
        
        %filters the images individually
        filteredBlue = bwareaopen(blueImg, 2);
        filteredYellow = bwareaopen(yellowImg, 2);
        
        %now create areas of interest for these 2 filtered images
        %also need to create a switch between left blue and right blue
        
        %this is the switch function
        %0 means blue lane to the left, 1 means blue lane to the right
        x = 0;
        [leftImage, rightImage] = colourSwitch(x, filteredBlue, filteredYellow);
        
        %making left lane ROIs
        [left_sum_1, left_sum_2, left_sum_top] = leftSum(res_y, top_y, BEV_left, HROI_length, leftImage);
        
        %making right lane ROIs
        [right_sum_1, right_sum_2, right_sum_top] = rightSum(res_y, top_y, BEV_right, HROI_length, rightImage);

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
            AnnotatedImage = insertText(BEV, [res_x / 2 - 50 stop_threshhold], textStr, 'FontSize', 24, 'BoxColor', 'r');
            imshow(AnnotatedImage);
 
        else
            
            %left lane logic
            [left_x1, left_y1, left_x2, left_y2] = leftCoords(top_y, bot_y, BEV_left, HROI_length, left_matrix_1, left_matrix_2, left_matrix_top, left_peak_1_matrix, left_peak_2_matrix, left_peak_top_matrix);
            
            %right lane logic
            [right_x1, right_y1, right_x2, right_y2] = rightCoords(top_y, bot_y, BEV_right, HROI_length, right_matrix_1, right_matrix_2, right_matrix_top, right_peak_1_matrix, right_peak_2_matrix, right_peak_top_matrix);

            %need to have both lane line equations as they are different
            %lengths, so we can get an average result
            
            %now get the average to find our midpoints
            [lane_average_x, lane_average_y] = laneAverage(top_y, left_x2, right_x2);

            %get the absolute spot and direction the car is facing
            [absolute_direction_x, absolute_direction_y] = absoluteDirection(BEV_left, BEV_right, bot_y);

            %work out the error margin
            error = round(lane_average_x - absolute_direction_x, 0);

            %draw everything on video
            textStr = ['Deviation: ' num2str(error) ' pixels'];

            AnnotatedImage = insertText(BEV, [BEV_left + 25 bot_y + 5], textStr, 'FontSize', 16);

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

function [left_sum_1, left_sum_2, left_sum_top] = leftSum(res_y, top_y, BEV_left, HROI_length, leftImage)

    left_area_1 = imcrop(leftImage, [BEV_left, top_y + 5, 10, res_y]);
    left_sum_1 = sum(left_area_1, 2);

    left_area_2 = imcrop(leftImage, [BEV_left + HROI_length - 5, top_y + 5, 10, res_y]); %2/3s of the way across the screen
    left_sum_2 = sum(left_area_2, 2);

    %this ROI is nested between the other 2, not overlapping
    left_area_top = imcrop(leftImage, [BEV_left, top_y - 5, BEV_left + HROI_length + 5, 10]);
    left_sum_top = sum(left_area_top, 1);

end

function [right_sum_1, right_sum_2, right_sum_top] = rightSum(res_y, top_y, BEV_right, HROI_length, rightImage)
    right_area_2 = imcrop(rightImage, [BEV_right - HROI_length - 5, top_y + 5, 10, res_y]);
    right_sum_2 = sum(right_area_2, 2);

    right_area_1 = imcrop(rightImage, [BEV_right - 10, top_y + 5, 10, res_y]); %2/3s of the way across the screen
    right_sum_1 = sum(right_area_1, 2);

    %this ROI is nested ON TOP the other 2, not overlapping
    right_area_top = imcrop(rightImage, [BEV_right - HROI_length - 5, top_y - 5, HROI_length + 5, 10]);
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

function [left_x1, left_y1, left_x2, left_y2] = leftCoords(top_y, bot_y, BEV_left, HROI_length, left_matrix_1, left_matrix_2, left_matrix_top, left_peak_1_matrix, left_peak_2_matrix, left_peak_top_matrix)

    if left_matrix_1(1) == 0
        left_x1 = BEV_left + 2;
        left_y1 = bot_y + 5;
    else
        left_x1 = BEV_left + 5;
        left_y1 = left_peak_1_matrix(2) + top_y + 5;
    end

    if left_matrix_2(1) == 0
        if left_matrix_top(2) == 0
            left_x2 = BEV_left + 1;
            left_y2 = top_y;
        else
            left_x2 = BEV_left + left_peak_top_matrix(2);
            left_y2 = top_y;
        end
    else
        left_x2 = BEV_left + HROI_length;
        left_y2 = left_peak_2_matrix(2) + top_y + 5;
    end

end

function [right_x1, right_y1, right_x2, right_y2] = rightCoords(top_y, bot_y, BEV_right, HROI_length, right_matrix_1, right_matrix_2, right_matrix_top, right_peak_1_matrix, right_peak_2_matrix, right_peak_top_matrix)
            
    if right_matrix_1(1) == 0
        right_x1 = BEV_right - 2;
        right_y1 = bot_y + 5;
    else
        right_x1 = BEV_right - 2;
        right_y1 = right_peak_1_matrix(2) + top_y + 5;
    end

    if right_matrix_2(1) == 0
        if right_matrix_top(2) == 0
            right_x2 = BEV_right - 1;
            right_y2 = top_y;
        else
            right_x2 = right_peak_top_matrix(2) + BEV_right - HROI_length - 5;
            right_y2 = top_y;
        end
    else
        right_x2 = BEV_right - HROI_length;
        right_y2 = right_peak_2_matrix(2) + top_y + 5;
    end
end

function [lane_average_x, lane_average_y] = laneAverage(top_y, left_x2, right_x2)
            
    lane_average_x = (left_x2 + right_x2) / 2;
    lane_average_y = top_y;

end

function [absolute_direction_x, absolute_direction_y] = absoluteDirection(BEV_left, BEV_right, bot_y)
            
    absolute_direction_x = (BEV_left + BEV_right) / 2;
    absolute_direction_y = bot_y;

end

function [BW,maskedRGBImage] = createBlueHSVMask(RGB)
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
channel1Min = 0.551;
channel1Max = 0.651;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.142;
channel2Max = 1.000;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.446;
channel3Max = 0.621;

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

% Auto-generated by colorThresholder app on 22-Jun-2019
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2lab(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 7.049;
channel1Max = 94.568;

% Define thresholds for channel 2 based on histogram settings
channel2Min = -10.472;
channel2Max = 1.085;

% Define thresholds for channel 3 based on histogram settings
channel3Min = -33.214;
channel3Max = -19.579;

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
channel1Min = 0.104;
channel1Max = 0.192;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.250;
channel2Max = 1.000;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.694;
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

% Auto-generated by colorThresholder app on 22-Jun-2019
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2lab(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 7.049;
channel1Max = 94.568;

% Define thresholds for channel 2 based on histogram settings
channel2Min = -10.472;
channel2Max = 9.724;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 29.352;
channel3Max = 80.683;

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