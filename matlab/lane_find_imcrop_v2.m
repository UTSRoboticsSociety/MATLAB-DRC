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

stop_height = 20; %how tall the final stop area is from the bottom of the image

%average aoi values
bot_y = round(res_y / 10 * 5, 0);
top_y = round(res_y / 10 * 3, 0);

%initial values for out of bounds actions
left_out = 0;
right_out = 0;
    
        Image = readFrame(vid);       
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
        [left_top_area, left_bot_area, left_right_area, left_stop_area] = getLeftROIs(leftImage, res_x, res_y, top_y, bot_y);
        
        [right_top_area, right_bot_area, right_left_area, right_stop_area] = getRightROIs(rightImage, res_x, res_y, top_y, bot_y);
        
        final_stop_area = getFinalStopROI(filteredGreen, res_x, res_y, stop_height);
        
        %get raw xy values from ROIs, can have empty sets
        [raw_left_x0, raw_left_y0, raw_left_x1, raw_left_y1, raw_left_x2, raw_left_y2, raw_left_x3, raw_left_y3] = getLeftCoords(res_x, bot_y, top_y, left_top_area, left_bot_area, left_right_area, left_stop_area);
        
        [raw_right_x0, raw_right_y0, raw_right_x1, raw_right_y1, raw_right_x2, raw_right_y2, raw_right_x3, raw_right_y3] = getRightCoords(res_x, bot_y, top_y, right_top_area, right_bot_area, right_left_area, right_stop_area);
        
        [raw_final_x3, raw_final_y3] = getFinalStopCoords(res_x, final_stop_area);
        
        %% logic for lanes
        %check to see if green line is there
        if isempty(raw_final_y3) == true
            
            %LEFT SIDE
            %check to see if left_bot area is clear
            if isempty(raw_left_x2) == true

                left_x2 = 1;
                left_y2 = bot_y;

            else

                left_x2 = raw_left_x2;
                left_y2 = bot_y;

            end

            %check to see if left_right area is clear
            if isempty(raw_left_y0) == true

                %check to see if left_top is clear
                if isempty(raw_left_x1) == true

                    left_x1 = 2;
                    left_y1 = top_y;

                else

                    left_x1 = raw_left_x1;
                    left_y1 = top_y;

                end

            else

                left_x0 = res_x / 2;
                left_y0 = raw_left_y0;
                left_x1 = leftConverter(left_x0, left_y0, top_y, left_x2, left_y2);
                left_y1 = top_y;

            end

            %RIGHT SIDE
            %check to see if right_bot area is clear
            if isempty(raw_right_x2) == true

                right_x2 = res_x - 1;
                right_y2 = bot_y;

            else

                right_x2 = raw_right_x2;
                right_y2 = bot_y;

            end
            
            %check to see if right_left area is clear
            if isempty(raw_right_y0) == true

                %check to see if right_top is clear
                if isempty(raw_right_x1) == true

                    right_x1 = res_x - 2;
                    right_y1 = top_y;

                else

                    right_x1 = raw_right_x1;
                    right_y1 = top_y;

                end

            else

                right_x0 = res_x / 2;
                right_y0 = raw_right_y0;
                right_x1 = rightConverter(right_x0, right_y0, top_y, right_x2, right_y2);
                right_y1 = top_y;

            end
            
            %this section for left out of lane maneuvers
            if isempty(raw_left_y3) == false
                
                left_out = 1;
                
            end
            
            if isempty(raw_left_x1) == false && isempty(raw_left_x2) == false
                
                left_out = 0;
                
            end
            
            if left_out == 1
                
                left_x1 = res_x / 4 * 3;
                
            end
            
            %this section for right out of lane maneuvers
            if isempty(raw_right_y3) == false
                
                right_out = 1;
                
            end
            
            if isempty(raw_right_x1) == false && isempty(raw_right_x2) == false
                
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

        %stop the car, race finish
        else

            error = 42069;
            textStr = 'FINISH!';
            AnnotatedImage = insertText(Image, [res_x / 2 - 50 top_y], textStr, 'FontSize', 20, 'BoxColor', 'g');
            imshow(AnnotatedImage);

        end
function [leftImage, rightImage] = colourSwitch(x, filteredBlue, filteredYellow)
        
    if x == 0
        leftImage = filteredBlue;
        rightImage = filteredYellow;
    else
        leftImage = filteredYellow;
        rightImage = filteredBlue;
    end

end

%% isolate the ROIs
function [left_top_area, left_bot_area, left_right_area, left_stop_area] = getLeftROIs(leftImage, res_x, res_y, top_y, bot_y)

    left_top_area = imcrop(leftImage, [1, top_y, res_x - 1, 0]);
    left_bot_area = imcrop(leftImage, [1, bot_y, res_x - 1, 0]);
    left_right_area = imcrop(leftImage, [res_x / 2, 10, 0, bot_y - 1]);
    left_stop_area = imcrop(leftImage, [res_x / 2, bot_y, 0, res_y - bot_y]);

end

function [right_top_area, right_bot_area, right_left_area, right_stop_area] = getRightROIs(rightImage, res_x, res_y, top_y, bot_y)

    right_top_area = imcrop(rightImage, [1, top_y, res_x - 1, 0]);
    right_bot_area = imcrop(rightImage, [1, bot_y, res_x - 1, 0]);
    right_left_area = imcrop(rightImage, [res_x / 2, 10, 0, bot_y - 1]);
    right_stop_area = imcrop(rightImage, [res_x / 2, bot_y, 0, res_y - bot_y]);

end

function final_stop_area = getFinalStopROI(filteredGreen, res_x, res_y, stop_height)

    final_stop_area = imcrop(filteredGreen, [res_x / 2, res_y - stop_height, 0, stop_height]);
    
end

%% find first and last pixels for sides
function [raw_left_x0, raw_left_y0, raw_left_x1, raw_left_y1, raw_left_x2, raw_left_y2, raw_left_x3, raw_left_y3] = getLeftCoords(res_x, bot_y, top_y, left_top_area, left_bot_area, left_right_area, left_stop_area)

     raw_left_x0 = res_x / 2;
     left_first_y0 = find(left_right_area, 1, 'first');
     left_last_y0 = find(left_right_area, 1, 'last');
     raw_left_y0 = (left_first_y0 + left_last_y0) / 2;

    left_first_x1 = find(left_top_area, 1, 'first');
    left_last_x1 = find(left_top_area, 1, 'last');
    raw_left_x1 = (left_first_x1 + left_last_x1) / 2;
    raw_left_y1 = top_y;

    left_first_x2 = find(left_bot_area, 1, 'first');
    left_last_x2 = find(left_bot_area, 1, 'last');
    raw_left_x2 = (left_first_x2 + left_last_x2) / 2;
    raw_left_y2 = bot_y;
    
    raw_left_x3 = res_x / 2;
    left_first_y3 = find(left_stop_area, 1, 'first');
    left_last_y3 = find(left_stop_area, 1, 'last');
    raw_left_y3 = (left_first_y3 + left_last_y3) / 2;

end

function [raw_right_x0, raw_right_y0, raw_right_x1, raw_right_y1, raw_right_x2, raw_right_y2, raw_right_x3, raw_right_y3] = getRightCoords(res_x, bot_y, top_y, right_top_area, right_bot_area, right_right_area, right_stop_area)

    raw_right_x0 = res_x / 2;
    right_first_y0 = find(right_right_area, 1, 'first');
    right_last_y0 = find(right_right_area, 1, 'last');
    raw_right_y0 = (right_first_y0 + right_last_y0) / 2;

    right_first_x1 = find(right_top_area, 1, 'first');
    right_last_x1 = find(right_top_area, 1, 'last');
    raw_right_x1 = (right_first_x1 + right_last_x1) / 2;
    raw_right_y1 = top_y;

    right_first_x2 = find(right_bot_area, 1, 'first');
    right_last_x2 = find(right_bot_area, 1, 'last');
    raw_right_x2 = (right_first_x2 + right_last_x2) / 2;
    raw_right_y2 = bot_y;
    
    raw_right_x3 = res_x / 2;
    right_first_y3 = find(right_stop_area, 1, 'first');
    right_last_y3 = find(right_stop_area, 1, 'last');
    raw_right_y3 = (right_first_y3 + right_last_y3) / 2;

end

function [raw_final_x3, raw_final_y3] = getFinalStopCoords(res_x, final_stop_area)

    raw_final_x3 = res_x / 2;
    final_first_y3 = find(final_stop_area, 1, 'first');
    final_last_y3 = find(final_stop_area, 1, 'last');
    raw_final_y3 = (final_first_y3 + final_last_y3) / 2;
    
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

% Auto-generated by colorThresholder app on 23-Jun-2019
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2hsv(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.544;
channel1Max = 0.638;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.286;
channel2Max = 1.000;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.394;
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

% Auto-generated by colorThresholder app on 23-Jun-2019
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2lab(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 24.945;
channel1Max = 100.000;

% Define thresholds for channel 2 based on histogram settings
channel2Min = -11.685;
channel2Max = 48.972;

% Define thresholds for channel 3 based on histogram settings
channel3Min = -38.605;
channel3Max = -14.064;

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