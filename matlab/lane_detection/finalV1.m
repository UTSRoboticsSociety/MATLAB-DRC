clc; clear;
close all;
objects = imaqfind;
delete(objects)

a = arduino(); %set up arduino for motion control
configurePin(a, 'D11', 'PWM');
s = servo(a,'D9', 'MinPulseDuration', 5e-4, 'MaxPulseDuration', 2.5e-3);
vid = imaq.VideoDevice('winvideo', 2, 'YUY2_320x240', 'ReturnedColorSpace', 'rgb');
%vid.FramesPerTrigger = Inf;
%INPUT RESOLUTION HERE
res_x = 320;            %<<<
res_y = 240;            %<<<
%^^ INPUT RESOLUTION ^^

%average aoi values
vert_x = round(res_x / 2, 0);
top_y = round(res_y / 4, 0);
bot_y = round(top_y * 2, 0);
lastSide = 0;

while true

    Image = step(vid);
    writePWMDutyCycle(a, 'D11', 0.755);
    %want 10fps, 0.1s * 100 = 10, 10mod10 = 0
    %0.2s *100 = 20, 20mod10 = 0


    %convert to binary
    binaryImage = rgb2gray(Image);

    %HSV filtering:
    blueImg = createMaskBlue(Image);
    yellowImg = createMaskYellow(Image);
    sumHSV = imadd(blueImg, yellowImg);
    %binaryHSV = imbinarize(sumHSV);
    HSVImage = bwareaopen(blueImg, 10);
    %HSVImage = bwareafilt(binaryHSV, [10, 5000]);

    %dilatedImage = rangeFilter;

    %edge filtering:
    %imSobel = edge(binaryImage, 0.05);

    %getting rid of pixels smaller than 40 and larger than 5000
    %can use bwareaopen instead
    %rangeSobel = bwareafilt(imSobel, [40, 5000]);
    %filteredEdge = bwareaopen(imSobel, 10);
    %create spherical structuring element of radius 3
    %sElement = strel('sphere', 2);

    %make edge lines thicker
    %edgeImage = imdilate(filteredEdge, sElement); %change back to edgeImage

    %add the 2 filters together to reduce distortions
    %variable names make no sense here i know
    %imabsdiff(too much interference) + imadd(lines not being detected) interchanged
    %totalImage = imadd(HSVImage, edgeImage);
    totalImage = HSVImage;

    %this area detects horizontal lines
    verticalArea = imcrop(totalImage, [vert_x - 5, 10, 10, bot_y - 10]);
    %sum up all the white pixels with respect to the y-axis
    verticalSum = sum(verticalArea, 2);

    %this area tells the car to stop and reverse
    stopArea = imcrop(totalImage, [vert_x - 5, bot_y - 10, 10, bot_y - 10]);
    stopSum = sum(stopArea, 2);

    %crop top area of interest for analysis
    topArea = imcrop(totalImage, [1, top_y - 5, res_x, 10]);
    %sum up all the white pixels with respect to the x-axis
    topSum = sum(topArea, 1);

    botArea = imcrop(totalImage, [1, bot_y - 5, res_x, 10]);
    botSum = sum(botArea, 1);

    %find 2 peaks using findpeaks
    %minpeakprominence is the height or something, using 5px atm, needs readjustment
    %minpeakdistance is how far a peak can be from another, using 20px atm, needs readjustment
    %[pks, locs] gives peak value and location in the x-axis
    [toppks, toplocs] = findpeaks(topSum,'MinPeakProminence',3,'MinPeakDistance',100);

    %do the same for the bottom
    [botpks, botlocs] = findpeaks(botSum,'MinPeakProminence',3,'MinPeakDistance',100);

    %see if mid aoi sees anything
    [midpks, midlocs] = findpeaks(verticalSum,'MinPeakProminence',3,'MinPeakDistance',50);

    %this is the warning threshhold for the vehicle to reverse
    [stoppks, stoplocs] = findpeaks(stopSum,'MinPeakProminence',3,'MinPeakDistance',50);

    %midlocs is how far DOWN the maximum is
    %therefore area of interest + DOWN = y coordinate
    %x coordinate is the midline, in this case 640px

    %drawing a line on the image to represent the roads

    %make if statement here to threshold a side
    %if a side below threshhold, then turn hard right or left

    %if toppks has only one value and if toplocs is greater than half of image, then errorangle = 90 degrees (ie hard right)
    %if toppks has only one value and if toplocs is less than half of image, then error angle = -90 degrees (ie hard left)
    %else follow the following code

    [mt, nt] = size(toplocs);

    [mb, nb] = size(botlocs);

    [mv, nv] = size(midlocs);

    [ms, ns] = size(stoplocs);

    %could probably use case for this bit
    if ms ~= 0

        %sends a special number to arduino to tell the car to
        %reverse
        error = 42069;
        textStr = 'STOP: WRONG WAY';
        AnnotatedImage = insertText(Image, [vert_x - 110 bot_y], textStr, 'FontSize', 24, 'BoxColor', 'r');
        imshow(AnnotatedImage);

    else

        if nb == 0 %if no lanes are seen, then assume lanes are off camera at min and max values for bot area of interest
            botlocs = [1, res_x];
        end

        if nb ~= 2 && nb ~= 0
            if botlocs > res_x / 2 %error may occur here
                botlocs = [1, botlocs(1)];
                %lastSide = 1;
            else
                botlocs = [botlocs(1), res_x];
                %lastSide = 0;
            end
        end

        if nt == 0  %if no lanes are seen, then assume lanes are off camera at min and max values for top area of interest
            toplocs = [1, res_x];
        end

        if nt ~= 2 && nt ~= 0
            %error may occur here
            if toplocs > res_x / 2  %use botlocs so top bit doesnt go over half of the screen, if still not enough, need to analyse a lower area of interest
                toplocs = [1, toplocs(1)]; %make condition if lanes are too close to each other then must be one line
                lastSide = 1;
            else
                toplocs = [toplocs(1), res_x];
                lastSide = 0;
            end
        end

        if mv == 0

            botAv = (botlocs(1) + botlocs(2)) / 2;

            topAv = (toplocs(1) + toplocs(2)) / 2;

            %work out how many pixels off centre the car is
            %cannot use botAv as it is the fulcrum of calculations
            %try midpoint of the vertical line of vehicle (yellow line)
            %average y value would be (425 + 225 / 2) = 325
            %work out midpoint of green line
            midpointX = (botAv + topAv) / 2;

            error = round(midpointX - res_x / 2, 0); %this is passed onto arduino
            writePosition(s, map(error));

            %big negative value means car needs to turn hard left
            %small positive value means car needs to turn slightly right

            %if mid isnt empty
        else

            %define the 2 points, this is the variable point
            %50px top of vertical interest, need to change for different
            %resolutions
            verticalPoint = [res_x / 2, 10 + midlocs(1)];

            %line will be extended by 100% here
            factorDistance = 0.7;

            %left turn since last seen side is on the right
            if lastSide == 1

                %vector from absolute points to the vertical point
                V = verticalPoint - [res_x, bot_y];

                %extend the line
                lineExtension = verticalPoint + V * factorDistance;

                %line equation, xA = xabsolute, xV = xvertical
                xA = res_x;
                yA = bot_y;

                xV = lineExtension(1);
                yV = lineExtension(2);

                m = (yV - yA) / (xV - xA);

                b = yA - m * xA;

                %cropped bot x coordinates
                xBot = (bot_y - b) / m;

                %cropped top x coordinates
                xTop = (top_y - b) / m;

                botlocs(2) = xBot;
                toplocs(2) = xTop;

                %work out top and bot averages
                botAv = (botlocs(1) + xBot) / 2;

                topAv = (toplocs(1) + xTop) / 2;

                %calculate errors
                midpointX = (botAv + topAv) / 2;

                error = round(midpointX - res_x / 2, 0); %this is passed onto arduino
                writePosition(s ,map(error));

            else

                %vector from absolute points to the vertical point
                V = verticalPoint - [1, bot_y];

                %extend the line
                lineExtension = verticalPoint + V * factorDistance;

                %line equation, xA = xabsolute, xV = xvertical
                xA = 1;
                yA = bot_y;

                xV = lineExtension(1);
                yV = lineExtension(2);

                m = (yV - yA) / (xV - xA);

                b = yA - m * xA;

                %cropped bot x coordinates
                xBot = (bot_y - b) / m;

                %cropped top x coordinates
                xTop = (top_y - b) / m;

                botlocs(1) = xBot;
                toplocs(1) = xTop;

                %work out top and bot averages
                botAv = (botlocs(2) + xBot) / 2;

                topAv = (toplocs(2) + xTop) / 2;

                %calculate errors
                midpointX = (botAv + topAv) / 2;

                error = round(midpointX - res_x / 2, 0); %this is passed onto arduino
                writePosition(s ,map(error));

            end

        end

        textStr = ['Deviation: ' num2str(error) ' pixels'];

        AnnotatedImage = insertText(Image, [vert_x - 80 bot_y + 5], textStr, 'FontSize', 16);

        imshow(AnnotatedImage);

        hold on

        %plot([xBot, xTop], [425, 225], 'r'); %slanted lane

        plot([botlocs(1),toplocs(1)],[bot_y, top_y],'LineWidth',2,'Color','r'); %draw left lane

        plot([botlocs(2),toplocs(2)],[bot_y, top_y],'LineWidth',2,'Color','r'); %draw right lane

        plot(midpointX, round((bot_y + top_y) / 2, 0),'bo'); %plot midpoint of guidance lane

        plot(vert_x, round((bot_y + top_y) / 2, 0),'bo'); %plot midpoint of absolute direction of vehicle

        plot([botAv,topAv],[bot_y, top_y],'LineWidth',2,'Color','g'); %draw desired path

        plot([res_x / 2, res_x / 2],[bot_y, top_y],'LineWidth',2,'Color','y'); %absolute position and direction of the car

    end

end

F = getframe(gcf);


clear s a;
%wont work if lane is too wide and comes upon a straight, horizontal line suddenly

function [BW,maskedRGBImage] = createMaskYellow(RGB)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder app. The colorspace and
%  range for each channel of the colorspace were set within the app. The
%  segmentation mask is returned in BW, and a composite of the mask and
%  original RGB images is returned in maskedRGBImage.

% Auto-generated by colorThresholder app on 13-Jun-2019
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2hsv(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.934;
channel1Max = 0.217;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.000;
channel2Max = 1.000;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.678;
channel3Max = 1.000;

% Create mask based on chosen histogram thresholds
sliderBW = ( (I(:,:,1) >= channel1Min) | (I(:,:,1) <= channel1Max) ) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

% Initialize output masked image based on input image.
maskedRGBImage = RGB;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end


%this is for cornerA.avi
function [BW,maskedRGBImage] = createMaskBlue(RGB)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder app. The colorspace and
%  range for each channel of the colorspace were set within the app. The
%  segmentation mask is returned in BW, and a composite of the mask and
%  original RGB images is returned in maskedRGBImage.

% Auto-generated by colorThresholder app on 13-Jun-2019
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2hsv(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.512;
channel1Max = 0.619;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.000;
channel2Max = 0.792;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.617;
channel3Max = 0.946;

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


function servo = map(error)
if error > 53
    error = 53;
elseif error < -53
    error = -53;
end

servo = 1-((0.566*error + 90) / 180);
end