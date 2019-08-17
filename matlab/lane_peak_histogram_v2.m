clc; clear;
close all; 
objects = imaqfind;
delete(objects)

vid = VideoReader('outBoundsinBounds.avi');

%INPUT RESOLUTION HERE
res_x = 480;            %<<<
res_y = 270;            %<<<
%^^ INPUT RESOLUTION ^^
%240p = 424x240
%270p = 480x270

%average aoi values
bot_y = round(res_y / 10 * 5, 0);
top_y = round(res_y / 10 * 3, 0);

%adjustable peak settings
pp = 3; %peak prominence, 5 is default
ROI_width = 5; %ROI width, 10 is default
stop_height = 100; %height of the stop ROI from the bottom in pixels

%initial values for out of bounds actions
left_out = 0;
right_out = 0;

while hasFrame(vid)
    
    Image = readFrame(vid);

    %want 10fps, 0.1s * 100 = 10, 10mod10 = 0
    %0.2s *100 = 20, 20mod10 = 0
    currentTime = vid.CurrentTime * 100;
    
    if mod(currentTime, 10) == 0
        
        tic
        
        %for blue lane
        blueHSVImage = createBlueHSVMask(Image);
        blueLABImage = createBlueLABMask(Image);
        blueImg = blueHSVImage | blueLABImage;
        
        %for yellow lane
        yellowHSVImage = createYellowHSVMask(Image);
        yellowLABImage = createYellowLABMask(Image);
        yellowImg = yellowHSVImage | yellowLABImage;
        
        %for green stop line
        greenHSVImage = createGreenHSVMask(Image);
        greenLABImage = createGreenLABMask(Image);
        greenImg = greenHSVImage | greenLABImage;
        
        %filters the images individually
        filteredBlue = bwareaopen(blueImg, 20);
        filteredYellow = bwareaopen(yellowImg, 20);
        filteredGreen = bwareaopen(greenImg, 20);
        
        %now create areas of interest for these 2 filtered images
        %also need to create a switch between left blue and right blue
        
        %this is the switch
        %0 is blue on left, 1 is blue on right
        x = 0;
        [leftImage, rightImage] = colourSwitch(x, filteredBlue, filteredYellow);
        
        %making ROIs for LEFT LANE: top, bot, vert_left, vert_mid, vert_right, and stop
        %crop top area of interest for analysis
        [left_top_sum, left_bot_sum, left_right_sum, left_stop_sum] = LeftSum(res_x, top_y, bot_y, res_y, leftImage, ROI_width);

        %making RIGHT LANE
        %crop top area of interest for analysis
        [right_top_sum, right_bot_sum, right_left_sum, right_stop_sum] = RightSum(res_x, top_y, bot_y, res_y, rightImage, ROI_width);
        
        %making GREEN STOP signal
        final_stop_sum = FinalSum(res_x, res_y, filteredGreen, ROI_width, stop_height);
        
        %find peaks individually for each side of the screen
        %left side first
        
        [left_top_peak_matrix, left_bot_peak_matrix, left_right_peak_matrix, left_stop_peak_matrix] = leftPeaks(left_top_sum, left_bot_sum, left_right_sum, left_stop_sum, pp);
        
        %find peaks for right side now
        [right_top_peak_matrix, right_bot_peak_matrix, right_left_peak_matrix, right_stop_peak_matrix] = rightPeaks(right_top_sum, right_bot_sum, right_left_sum, right_stop_sum, pp);
        
        %find peaks for green stop signal
        final_stop_peak_matrix = finalPeaks(final_stop_sum, pp);
        
        %these values tells us how big the matrix is ie. [m, n] etc
        %there should be only 0 or 1 value
        [left_top_matrix, left_bot_matrix, left_right_matrix, left_stop_matrix] = leftMatrixSize(left_top_peak_matrix, left_bot_peak_matrix, left_right_peak_matrix, left_stop_peak_matrix);
        
        [right_top_matrix, right_bot_matrix, right_left_matrix, right_stop_matrix] = rightMatrixSize(right_top_peak_matrix, right_bot_peak_matrix, right_left_peak_matrix, right_stop_peak_matrix);
        
        final_stop_matrix = stopMatrixSize(final_stop_peak_matrix);

        %% logic for different peak conditions
        if final_stop_matrix(1) == 0
            
            %left side bot first
            if left_bot_matrix(2) == 0
                
                left_x2 = 1;
                left_y2 = bot_y;
                
            else
                
                left_x2 = left_bot_peak_matrix(2);
                left_y2 = bot_y;
                
            end
            
            %then left side top
            if left_right_matrix(1) == 0
                
                if left_top_matrix(2) == 0
                    
                    left_x1 = 2;
                    left_y1 = top_y;
                    
                else
                    
                    left_x1 = left_top_peak_matrix(2);
                    left_y1 = top_y;
                    
                end
                
            else
                
                left_x0 = res_x / 2;
                left_y0 = left_right_peak_matrix(2) + 10;
                left_x1 = leftConverter(left_x0, left_y0, top_y, left_x2, left_y2);
                left_y1 = top_y;
                
            end
            
            %right side bot
            if right_bot_matrix(2) == 0
                
                right_x2 = res_x - 1;
                right_y2 = bot_y;
                
            else
                
                right_x2 = right_bot_peak_matrix(2);
                right_y2 = bot_y;
                
            end
            
            %then right side top
            if right_left_matrix(1) == 0
                
                if right_top_matrix(2) == 0
                    
                    right_x1 = res_x - 2;
                    right_y1 = top_y;
                    
                else
                    
                    right_x1 = right_top_peak_matrix(2);
                    right_y1 = top_y;
                    
                end
                
            else
                
                right_x0 = res_x / 2;
                right_y0 = right_left_peak_matrix(2) + 10;
                right_x1 = rightConverter(right_x0, right_y0, top_y, right_x2, right_y2);
                right_y1 = top_y;
                
            end
            
            %this section for out of lane maneuvers
            if left_stop_matrix(1) ~= 0
                
                left_out = 1;
                
            end
            
            if left_top_matrix(2) ~= 0 && left_bot_matrix(2) ~= 0
                
                left_out = 0;
                
            end
            
            if left_out == 1
                
                left_x1 = res_x / 4 * 3;
                
            end
            
            if right_stop_matrix(1) ~= 0
                
                right_out = 1;
                
            end
            
            if right_top_matrix(2) ~= 0 && right_bot_matrix(2) ~= 0
                
                right_out = 0;
                
            end
            
            if right_out == 1
                
                right_x1 = res_x / 4;
                
            end

            %calculate lane averages
            %top lane averages
            [lane_average_x1, lane_average_y1] = topLaneAverage(left_x1, right_x1, left_y1, right_y1);

            %bot lane averages
            [lane_average_x2, lane_average_y2] = botLaneAverage(left_x2, right_x2, left_y2, right_y2);

            %calculate absolute direction of the car
            %top lane
            [absolute_direction_x1, absolute_direction_y1] = topAbsoluteDirection(res_x, top_y);

            %bot lane
            [absolute_direction_x2, absolute_direction_y2] = botAbsoluteDirection(res_x, bot_y);

            %calculate midpoints of lane_average
            [midpoint_average_x, midpoint_average_y] = laneAverage(lane_average_x1, lane_average_x2, lane_average_y1, lane_average_y2);

            %calculate midpoints of absolute direction
            [midpoint_absolute_x, midpoint_absolute_y] = absoluteAverage(absolute_direction_x1, absolute_direction_x2, absolute_direction_y1, absolute_direction_y2);

            %calulate deviation
            error = round(midpoint_average_x - midpoint_absolute_x, 0);

            %overlay everything
            textStr = ['Deviation: ' num2str(error) ' pixels'];

            AnnotatedImage = insertText(Image, [res_x / 2 - 90 bot_y + 10], textStr, 'FontSize', 16);

            imshow(AnnotatedImage);

            hold on

            plot([left_x1, left_x2],[left_y1, left_y2],'LineWidth',2,'Color','r'); %draw left lane

            plot([right_x1, right_x2],[right_y1, right_y2],'LineWidth',2,'Color','r'); %draw right lane

            plot(midpoint_average_x, midpoint_average_y, 'bo'); %plot midpoint of guidance lane

            plot(midpoint_absolute_x, midpoint_absolute_y, 'bo'); %plot midpoint of absolute direction of vehicle

            plot([absolute_direction_x1, absolute_direction_x2],[top_y, bot_y],'LineWidth',2,'Color','y'); %absolute position and direction of the car
        
        else
            
            error = 42069;
            textStr = 'FINISH!';
            AnnotatedImage = insertText(Image, [res_x / 2 - 50 top_y], textStr, 'FontSize', 20, 'BoxColor', 'g');
            imshow(AnnotatedImage);
        
        end
        
        toc

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

function [left_top_sum, left_bot_sum, left_right_sum, left_stop_sum] = LeftSum(res_x, top_y, bot_y, res_y, leftImage, ROI_width)
        
    left_top_area = imcrop(leftImage, [1, top_y - ROI_width / 2, res_x - 1, 10]);
    %sum up all the white pixels with respect to the x-axis
    left_top_sum = sum(left_top_area, 1);

    left_bot_area = imcrop(leftImage, [1, bot_y - ROI_width / 2, res_x - 1, 10]);
    left_bot_sum = sum(left_bot_area, 1);

    left_right_area = imcrop(leftImage, [res_x / 4 * 3 - ROI_width / 2 - 1, 10, 10, bot_y - ROI_width / 2]);
    %sum up all the white pixels with respect to the y-axis
    left_right_sum = sum(left_right_area, 2);

    %this area tells the car to stop and reverse
    left_stop_area = imcrop(leftImage, [res_x / 2 - ROI_width / 2 - 1, bot_y - ROI_width / 2, 10, res_y - bot_y]);
    left_stop_sum = sum(left_stop_area, 2);

end

function [right_top_sum, right_bot_sum, right_left_sum, right_stop_sum] = RightSum(res_x, top_y, bot_y, res_y, rightImage, ROI_width)
        
    right_top_area = imcrop(rightImage, [1, top_y - ROI_width / 2, res_x - 1, 10]);
    %sum up all the white pixels with respect to the x-axis
    right_top_sum = sum(right_top_area, 1);

    right_bot_area = imcrop(rightImage, [1, bot_y - ROI_width / 2, res_x - 1, 10]);
    right_bot_sum = sum(right_bot_area, 1);

    right_left_area = imcrop(rightImage, [res_x / 4 - ROI_width / 2 - 1, 10, 10, bot_y - ROI_width / 2]);
    %sum up all the white pixels with respect to the y-axis
    right_left_sum = sum(right_left_area, 2);

    %this area tells the car to stop and reverse
    right_stop_area = imcrop(rightImage, [res_x / 2 - ROI_width / 2, bot_y - ROI_width / 2, 10, res_y - bot_y]);
    right_stop_sum = sum(right_stop_area, 2);

end

function final_stop_sum = FinalSum(res_x, res_y, filteredGreen, ROI_width, stop_height)
        
    final_stop_area = imcrop(filteredGreen, [res_x / 2 - ROI_width / 2 - 1, res_y - stop_height, 10, stop_height]);

    final_stop_sum = sum(final_stop_area, 2);

end

function [left_top_peak_matrix, left_bot_peak_matrix, left_right_peak_matrix, left_stop_peak_matrix] = leftPeaks(left_top_sum, left_bot_sum, left_right_sum, left_stop_sum, pp)
        
    [left_top_peaks, left_top_locs] = findpeaks(left_top_sum,'MinPeakProminence',pp,'MinPeakDistance',50);
    left_top_peak_matrix = [left_top_peaks, left_top_locs];

    [left_bot_peaks, left_bot_locs] = findpeaks(left_bot_sum,'MinPeakProminence',pp,'MinPeakDistance',50);
    left_bot_peak_matrix = [left_bot_peaks, left_bot_locs];

    [left_right_peaks, left_right_locs] = findpeaks(left_right_sum,'MinPeakProminence',pp,'MinPeakDistance',20);
    left_right_peak_matrix = [left_right_peaks, left_right_locs];

    [left_stop_peaks, left_stop_locs] = findpeaks(left_stop_sum,'MinPeakProminence',pp,'MinPeakDistance',20);
    left_stop_peak_matrix = [left_stop_peaks, left_stop_locs];

end

function [right_top_peak_matrix, right_bot_peak_matrix, right_left_peak_matrix, right_stop_peak_matrix] = rightPeaks(right_top_sum, right_bot_sum, right_left_sum, right_stop_sum, pp)

    [right_top_peaks, right_top_locs] = findpeaks(right_top_sum,'MinPeakProminence',pp,'MinPeakDistance',50);
    right_top_peak_matrix = [right_top_peaks, right_top_locs];

    [right_bot_peaks, right_bot_locs] = findpeaks(right_bot_sum,'MinPeakProminence',pp,'MinPeakDistance',50);
    right_bot_peak_matrix = [right_bot_peaks, right_bot_locs];

    [right_left_peaks, right_left_locs] = findpeaks(right_left_sum,'MinPeakProminence',pp,'MinPeakDistance',20);
    right_left_peak_matrix = [right_left_peaks, right_left_locs];

    [right_stop_peaks, right_stop_locs] = findpeaks(right_stop_sum,'MinPeakProminence',pp,'MinPeakDistance',20);
    right_stop_peak_matrix = [right_stop_peaks, right_stop_locs];

end

function final_stop_peak_matrix = finalPeaks(final_stop_sum, pp)

    [final_stop_peaks, final_stop_locs] = findpeaks(final_stop_sum,'MinPeakProminence',pp,'MinPeakDistance',10);
    final_stop_peak_matrix = [final_stop_peaks, final_stop_locs];
        
end

function [left_top_matrix, left_bot_matrix, left_right_matrix, left_stop_matrix] = leftMatrixSize(left_top_locs, left_bot_locs, left_right_locs, left_stop_locs)
        
    [m_left_top, n_left_top] = size(left_top_locs);
    left_top_matrix = [m_left_top, n_left_top];

    [m_left_bot, n_left_bot] = size(left_bot_locs);
    left_bot_matrix = [m_left_bot, n_left_bot];

    [m_left_right, n_left_right] = size(left_right_locs);
    left_right_matrix = [m_left_right, n_left_right];

    [m_left_stop, n_left_stop] = size(left_stop_locs);
    left_stop_matrix = [m_left_stop, n_left_stop];

end

function [right_top_matrix, right_bot_matrix, right_left_matrix, right_stop_matrix] = rightMatrixSize(right_top_locs, right_bot_locs, right_left_locs, right_stop_locs)

    [m_right_top, n_right_top] = size(right_top_locs);
    right_top_matrix = [m_right_top, n_right_top];

    [m_right_bot, n_right_bot] = size(right_bot_locs);
    right_bot_matrix = [m_right_bot, n_right_bot];

    [m_right_left, n_right_left] = size(right_left_locs);
    right_left_matrix = [m_right_left, n_right_left];

    [m_right_stop, n_right_stop] = size(right_stop_locs);
    right_stop_matrix = [m_right_stop, n_right_stop];

end

function final_stop_matrix = stopMatrixSize(final_stop_locs)
        
    [m_final_stop, n_final_stop] = size(final_stop_locs);
    final_stop_matrix = [m_final_stop, n_final_stop];

end

function left_x1 = leftConverter(left_x0, left_y0, top_y, left_x2, left_y2)

    m = (left_y2 - left_y0) / (left_x2 - left_x0);
    
    left_x1 = (top_y - left_y2 + m * left_x2) / m;

end

function right_x1 = rightConverter(right_x0, right_y0, top_y, right_x2, right_y2)

    m = (right_y2 - right_y0) / (right_x2 - right_x0);
    
    right_x1 = (top_y - right_y2 + m * right_x2) / m;

end

function [lane_average_x1, lane_average_y1] = topLaneAverage(left_x1, right_x1, left_y1, right_y1)
            
    lane_average_x1 = (left_x1 + right_x1) / 2;
    lane_average_y1 = (left_y1 + right_y1) / 2;

end

function [lane_average_x2, lane_average_y2] = botLaneAverage(left_x2, right_x2, left_y2, right_y2)
            
    lane_average_x2 = (left_x2 + right_x2) / 2;
    lane_average_y2 = (left_y2 + right_y2) / 2;

end

function [absolute_direction_x1, absolute_direction_y1] = topAbsoluteDirection(res_x, top_y)

    absolute_direction_x1 = res_x / 2;
    absolute_direction_y1 = top_y;

end

function [absolute_direction_x2, absolute_direction_y2] = botAbsoluteDirection(res_x, bot_y)
            
    absolute_direction_x2 = res_x / 2;
    absolute_direction_y2 = bot_y; 

end

function [midpoint_average_x, midpoint_average_y] = laneAverage(lane_average_x1, lane_average_x2, lane_average_y1, lane_average_y2)

    midpoint_average_x = (lane_average_x1 + lane_average_x2) / 2;
    midpoint_average_y = (lane_average_y1 + lane_average_y2) / 2;

end

function [midpoint_absolute_x, midpoint_absolute_y] = absoluteAverage(absolute_direction_x1, absolute_direction_x2, absolute_direction_y1, absolute_direction_y2)
            
    midpoint_absolute_x = (absolute_direction_x1 + absolute_direction_x2) / 2;
    midpoint_absolute_y = (absolute_direction_y1 + absolute_direction_y2) / 2;

end

function [BW,maskedRGBImage] = createBlueHSVMask(RGB)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder app. The colorspace and
%  range for each channel of the colorspace were set within the app. The
%  segmentation mask is returned in BW, and a composite of the mask and
%  original RGB images is returned in maskedRGBImage.

% Auto-generated by colorThresholder app on 28-Jun-2019
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2hsv(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.559;
channel1Max = 0.789;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.000;
channel2Max = 1.000;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.533;
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

% Auto-generated by colorThresholder app on 28-Jun-2019
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2lab(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 17.352;
channel1Max = 92.929;

% Define thresholds for channel 2 based on histogram settings
channel2Min = -9.259;
channel2Max = 11.229;

% Define thresholds for channel 3 based on histogram settings
channel3Min = -27.208;
channel3Max = -15.158;

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
channel1Min = 0.101;
channel1Max = 0.182;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.295;
channel2Max = 1.000;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.667;
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

% Auto-generated by colorThresholder app on 29-Jun-2019
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2lab(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.233;
channel1Max = 99.781;

% Define thresholds for channel 2 based on histogram settings
channel2Min = -17.003;
channel2Max = 12.136;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 70.352;
channel3Max = 89.281;

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

function [BW,maskedRGBImage] = createGreenHSVMask(RGB)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder app. The colorspace and
%  range for each channel of the colorspace were set within the app. The
%  segmentation mask is returned in BW, and a composite of the mask and
%  original RGB images is returned in maskedRGBImage.

% Auto-generated by colorThresholder app on 29-Jun-2019
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2hsv(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.224;
channel1Max = 0.294;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.000;
channel2Max = 1.000;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.000;
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

function [BW,maskedRGBImage] = createGreenLABMask(RGB)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder app. The colorspace and
%  range for each channel of the colorspace were set within the app. The
%  segmentation mask is returned in BW, and a composite of the mask and
%  original RGB images is returned in maskedRGBImage.

% Auto-generated by colorThresholder app on 29-Jun-2019
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2lab(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 19.028;
channel1Max = 92.053;

% Define thresholds for channel 2 based on histogram settings
channel2Min = -33.796;
channel2Max = -19.090;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 25.724;
channel3Max = 45.544;

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