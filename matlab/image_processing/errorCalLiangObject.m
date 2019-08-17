function error = errorCalLiangObject(filtered_left_img,filtered_right_img,image, blueHSVImage, yellowHSVImage)
%ERRORCALLIANG Liang's method of error estimation
    %INPUT RESOLUTION HERE
    res_x = 424;            %<<<
    res_y = 240;            %<<<
    
    %ROI values
    bot_y = round(res_y / 10 * 6, 0);
    top_y = round(res_y / 10 * 5, 0);

    object_bot_y = round(res_y / 10 * 6, 0);
    object_top_y = round(res_y / 10 * 5, 0);
    object_ext_y = round(res_y / 10 * 4.5, 0);
    
    %making ROIs for LEFT LANE: top, bot, vert_left, vert_mid, vert_right, and stop
    %crop top area of interest for analysis
    [left_top_sum, left_bot_sum, left_right_sum, left_stop_sum] = LeftSum(res_x, top_y, bot_y, res_y, filtered_left_img);

    %making RIGHT LANE
    %crop top area of interest for analysis
    [right_top_sum, right_bot_sum, right_left_sum, right_stop_sum] = RightSum(res_x, top_y, bot_y, res_y, filtered_right_img);

    %find peaks individually for each side of the screen
    %left side first

    [left_top_peak_matrix, left_bot_peak_matrix, left_right_peak_matrix, left_stop_peak_matrix] = leftPeaks(left_top_sum, left_bot_sum, left_right_sum, left_stop_sum);

    %find peaks for right side now
    [right_top_peak_matrix, right_bot_peak_matrix, right_left_peak_matrix, right_stop_peak_matrix] = rightPeaks(right_top_sum, right_bot_sum, right_left_sum, right_stop_sum);

    %these values tells us how big the matrix is ie. [m, n] etc
    %there should be only 0 or 1 value
    [left_top_matrix, left_bot_matrix, left_right_matrix, left_stop_matrix] = leftMatrixSize(left_top_peak_matrix, left_bot_peak_matrix, left_right_peak_matrix, left_stop_peak_matrix);

    [right_top_matrix, right_bot_matrix, right_left_matrix, right_stop_matrix] = rightMatrixSize(right_top_peak_matrix, right_bot_peak_matrix, right_left_peak_matrix, right_stop_peak_matrix);

    %% logic for different peak conditions

    if left_stop_matrix(1) == 0 && right_stop_matrix(1) == 0

        %left lane logic
        [left_x1, left_y1, left_x2, left_y2] = leftCoords(res_x, top_y, bot_y, left_bot_matrix, left_top_matrix, left_right_matrix, left_bot_peak_matrix, left_top_peak_matrix, left_right_peak_matrix);

        %right lane logic
        [right_x1, right_y1, right_x2, right_y2] = rightCoords(res_x, top_y, bot_y, right_bot_matrix, right_top_matrix, right_left_matrix, right_bot_peak_matrix, right_top_peak_matrix, right_left_peak_matrix);

        %need to make line equation to determine where x value is if
        %verticals are detected
        [left_x1, left_y1] = scaledLeftx(top_y, left_x1, left_x2, left_y1, left_y2);

        [right_x1, right_y1] = scaledRightx(top_y, right_x1, right_x2, right_y1, right_y2);

        %find dynamic ROI for object detection
        %extended area first
        [ROI_ext_left_x, ROI_ext_left_y] = ROIextLeft(object_ext_y, left_x1, left_x2, left_y1, left_y2);

        [ROI_ext_right_x, ROI_ext_right_y] = ROIextRight(object_ext_y, right_x1, right_x2, right_y1, right_y2);

        %top area second
        [ROI_top_left_x, ROI_top_left_y] = ROItopLeft(object_top_y, left_x1, left_x2, left_y1, left_y2);

        [ROI_top_right_x, ROI_top_right_y] = ROItopRight(object_top_y, right_x1, right_x2, right_y1, right_y2);

        %bot area last
        [ROI_bot_left_x, ROI_bot_left_y] = ROIbotLeft(object_bot_y, left_x1, left_x2, left_y1, left_y2);

        [ROI_bot_right_x, ROI_bot_right_y] = ROIbotRight(object_bot_y, right_x1, right_x2, right_y1, right_y2);

        %% apply filters to isolate object

        %edge first
        %trungs edge filter
%             BW = rgb2gray(Image);
%             BWs = edge(BW,'Canny',0.4); 
%             se90 = strel('line',3,90);
%             se0 = strel('line',3,0);
%             BWsdil = imdilate(BWs,[se90 se0]);
%             filteredEdge = imfill(BWsdil,'holes');

        BW = rgb2gray(image);
        imageSobel = edge(BW, 'Sobel', 0.07);
        filteredEdge = bwareaopen(imageSobel, 40);

        %now HSV
        combinedHSV = imadd(blueHSVImage, yellowHSVImage);
        filteredHSV = bwareaopen(combinedHSV, 40);
        se = strel('disk', 2);
        dilatedHSV = imdilate(filteredHSV, se);
        invertedHSV = imcomplement(dilatedHSV);

        %now and the 2 images together
        objectImage = filteredEdge & invertedHSV;
        filteredObjectImage = bwareaopen(objectImage, 40);

        %% pre calculations for object detection ROIs
        %find the midpoint of guidance lane
        central_x1 = findCentralx1(left_x1, right_x1);
        central_x2 = findCentralx2(left_x2, right_x2);
        %find corresponding x-value for extended y-value
        central_ext_x = centralExtLane(object_ext_y, central_x1, central_x2, top_y, bot_y);% this give an m value of undefined

        %this is so gradient is never an undefined value
        if isnan(central_ext_x) == 1

            central_ext_x = central_x1;

        end

        %% get ROIs for object detection

        [object_ext_left_area, object_ext_right_area] = getExtObjectROI(filteredObjectImage, central_ext_x, object_ext_y, ROI_ext_left_x, ROI_ext_right_x);

        [object_top_left_area, object_top_right_area] = getTopObjectROI(filteredObjectImage, central_x1, object_top_y, ROI_top_left_x, ROI_top_right_x);

        [object_bot_left_area, object_bot_right_area] = getBotObjectROI(filteredObjectImage, central_x2, object_bot_y, ROI_bot_left_x, ROI_bot_right_x);

        %% search for pixels from middle of image outwards ie. from left <- middle and from middle -> right

        [object_ext_left_x, object_ext_right_x] = pixelFinderExt(object_ext_left_area, object_ext_right_area, central_ext_x);

        [object_top_left_x, object_top_right_x] = pixelFinderTop(object_top_left_area, object_top_right_area, central_x1);

        [object_bot_left_x, object_bot_right_x] = pixelFinderBot(object_bot_left_area, object_bot_right_area, central_x2);

        %% logic for object detection (extended ROI)

        %if left comes up as positive
        if isempty(object_ext_left_x) == 0 && isempty(object_ext_right_x) == 0

            %check if its under a certain pixel size so that its
            %not one object, use 25 pixels for now
            object_size_ext = central_ext_x - object_ext_left_x + object_ext_right_x;

            if object_size_ext < 20

                %take 80 pixels as the hole the car can fit
                %through
                if object_ext_left_x - ROI_ext_left_x > 50

                    right_x0 = object_ext_left_x + ROI_ext_left;

                    right_x1 = getRightx1(object_ext_y, bot_y, right_x0, right_x2);

                else

                    left_x0 = object_ext_right_x + central_ext_x;

                    left_x1 = getLeftx1(object_ext_y, top_y, bot_y, left_x0, left_x2);

                end

            else

                %this is a hole situation
                left_x0 = object_ext_left_x + ROI_ext_left_x;

                left_x1 = getLeftx1(object_ext_y, top_y, bot_y, left_x0, left_x2);

                right_x0 = object_ext_right_x;

                right_x1 = getRightx1(object_ext_y, top_y, bot_y, right_x0, right_x2);

            end

        end

        %only left object is seen
        if isempty(object_ext_left_x) == 0 && isempty(object_ext_right_x) == 1

            left_x0 = ROI_ext_left_x + object_ext_left_x;

            left_x1 = getLeftx1(object_ext_y, top_y, bot_y, left_x0, left_x2);

        end

        %only right object is seen  
        if isempty(object_ext_right_x) == 0 && isempty(object_ext_left_x) == 1

            right_x0 = object_ext_right_x;

            right_x1 = getRightx1(object_ext_y, top_y, bot_y, right_x0, right_x2);

        end

        %% logic for object detection (top ROI)

        if isempty(object_top_left_x) == 0 && isempty(object_top_right_x) == 0

            %check if its under a certain pixel size so that its
            %not one object, use 25 pixels for now
            object_size_top = central_x1 - object_top_left_x + object_top_right_x;

            if object_size_top < 40

                %take 80 pixels as the hole the car can fit
                %through
                if object_top_left_x - ROI_top_left_x > 100

                    right_x1 = object_top_left_x + ROI_top_left;

                else

                    left_x1 = object_top_right_x + central_x1;

                end

            else

                %this is a hole situation
                left_x1 = object_top_left_x + ROI_top_left_x;

                right_x1 = object_top_right_x;

            end

        end

        %only left object is seen
        if isempty(object_top_left_x) == 0 && isempty(object_top_right_x) == 1

            left_x1 = ROI_top_left_x + object_top_left_x;

        end

        %only right object is seen  
        if isempty(object_top_right_x) == 0 && isempty(object_top_left_x) == 1

            right_x1 = object_top_right_x;

        end

        %% logic for object detection (bot ROI)

        if isempty(object_bot_left_x) == 0 && isempty(object_bot_right_x) == 0

            %check if its under a certain pixel size so that its
            %not one object, use 25 pixels for now
            object_size_bot = central_x2 - object_bot_left_x + object_bot_right_x;

            if object_size_bot < 60

                %take 80 pixels as the hole the car can fit
                %through
                if object_bot_left_x - ROI_bot_left_x > 150

                    right_x2 = object_bot_left_x + ROI_bot_left;

                else

                    left_x2 = object_bot_right_x + central_x1;

                end

            else

                %this is a hole situation
                left_x2 = object_bot_left_x + ROI_bot_left_x;

                right_x2 = object_bot_right_x;

            end

        end

        %only left object is seen
        if isempty(object_bot_left_x) == 0 && isempty(object_bot_right_x) == 1

            left_x2 = ROI_bot_left_x + object_bot_left_x;

        end

        %only right object is seen  
        if isempty(object_bot_right_x) == 0 && isempty(object_bot_left_x) == 1

            right_x2 = object_bot_right_x;

        end

        %% checks if there is still an objected detected by the top area

        %if so, make bot x-values the same as top x-values so that the
        %car can fully clear the object before turning back into the
        %lane

        if isempty(object_bot_left_x) == 0 && left_x2 > left_x1

            left_x1 = left_x2;

        end

        if isempty(object_bot_right_x) == 0 && right_x2 < right_x1

            right_x1 = right_x2;

        end

        %% after going through the object detection, draw both lanes

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

    else

        %this triggers if the lane is seen at the bottom area of the image
        error = 42069;

    end
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

function [left_top_sum, left_bot_sum, left_right_sum, left_stop_sum] = LeftSum(res_x, top_y, bot_y, res_y, leftImage)
        
    left_top_area = imcrop(leftImage, [1, top_y - 5, res_x, 10]);
    %sum up all the white pixels with respect to the x-axis
    left_top_sum = sum(left_top_area, 1);

    left_bot_area = imcrop(leftImage, [1, bot_y - 5, res_x, 10]);
    left_bot_sum = sum(left_bot_area, 1);

    left_right_area = imcrop(leftImage, [res_x / 4 * 3 - 5, 10, 10, bot_y - 5]);
    %sum up all the white pixels with respect to the y-axis
    left_right_sum = sum(left_right_area, 2);

    %this area tells the car to stop and reverse
    left_stop_area = imcrop(leftImage, [res_x / 2 - 5, bot_y - 5, 10, res_y]);
    left_stop_sum = sum(left_stop_area, 2);

end

function [right_top_sum, right_bot_sum, right_left_sum, right_stop_sum] = RightSum(res_x, top_y, bot_y, res_y, rightImage)
        
    right_top_area = imcrop(rightImage, [1, top_y - 5, res_x, 10]);
    %sum up all the white pixels with respect to the x-axis
    right_top_sum = sum(right_top_area, 1);

    right_bot_area = imcrop(rightImage, [1, bot_y - 5, res_x, 10]);
    right_bot_sum = sum(right_bot_area, 1);

    right_left_area = imcrop(rightImage, [res_x / 4 - 5, 10, 10, bot_y - 5]);
    %sum up all the white pixels with respect to the y-axis
    right_left_sum = sum(right_left_area, 2);

    %this area tells the car to stop and reverse
    right_stop_area = imcrop(rightImage, [res_x / 2 - 5, bot_y - 10, 10, res_y]);
    right_stop_sum = sum(right_stop_area, 2);

end

function [left_top_peak_matrix, left_bot_peak_matrix, left_right_peak_matrix, left_stop_peak_matrix] = leftPeaks(left_top_sum, left_bot_sum, left_right_sum, left_stop_sum)
        
    [left_top_peaks, left_top_locs] = findpeaks(left_top_sum,'MinPeakProminence',7,'MinPeakDistance',50);
    left_top_peak_matrix = [left_top_peaks, left_top_locs];

    [left_bot_peaks, left_bot_locs] = findpeaks(left_bot_sum,'MinPeakProminence',7,'MinPeakDistance',50);
    left_bot_peak_matrix = [left_bot_peaks, left_bot_locs];

    [left_right_peaks, left_right_locs] = findpeaks(left_right_sum,'MinPeakProminence',7,'MinPeakDistance',20);
    left_right_peak_matrix = [left_right_peaks, left_right_locs];

    [left_stop_peaks, left_stop_locs] = findpeaks(left_stop_sum,'MinPeakProminence',7,'MinPeakDistance',20);
    left_stop_peak_matrix = [left_stop_peaks, left_stop_locs];

end

function [right_top_peak_matrix, right_bot_peak_matrix, right_left_peak_matrix, right_stop_peak_matrix] = rightPeaks(right_top_sum, right_bot_sum, right_left_sum, right_stop_sum)

    [right_top_peaks, right_top_locs] = findpeaks(right_top_sum,'MinPeakProminence',7,'MinPeakDistance',50);
    right_top_peak_matrix = [right_top_peaks, right_top_locs];

    [right_bot_peaks, right_bot_locs] = findpeaks(right_bot_sum,'MinPeakProminence',7,'MinPeakDistance',50);
    right_bot_peak_matrix = [right_bot_peaks, right_bot_locs];

    [right_left_peaks, right_left_locs] = findpeaks(right_left_sum,'MinPeakProminence',7,'MinPeakDistance',20);
    right_left_peak_matrix = [right_left_peaks, right_left_locs];

    [right_stop_peaks, right_stop_locs] = findpeaks(right_stop_sum,'MinPeakProminence',7,'MinPeakDistance',20);
    right_stop_peak_matrix = [right_stop_peaks, right_stop_locs];

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

 function [left_x1, left_y1, left_x2, left_y2] = leftCoords(res_x, top_y, bot_y, left_bot_matrix, left_top_matrix, left_right_matrix, left_bot_peak_matrix, left_top_peak_matrix, left_right_peak_matrix)
            
    if left_right_matrix(1) == 0

        if left_top_matrix(2) == 0
            left_x1 = 2;
            left_y1 = top_y;
        else
            left_x1 = left_top_peak_matrix(2);
            left_y1 = top_y;
        end
    else
        left_x1 = res_x / 4 * 3;
        % +10 pixels because we start ROI 10 pixels down
        left_y1 = left_right_peak_matrix(2) + 10;   
    end

    if left_bot_matrix(2) == 0
        left_x2 = 1;
        left_y2 = bot_y;
    else
        left_x2 = left_bot_peak_matrix(2);
        left_y2 = bot_y;
    end

end

function [right_x1, right_y1, right_x2, right_y2] = rightCoords(res_x, top_y, bot_y, right_bot_matrix, right_top_matrix, right_left_matrix, right_bot_peak_matrix, right_top_peak_matrix, right_left_peak_matrix)

    if right_left_matrix(1) == 0

        if right_top_matrix(2) == 0
            right_x1 = res_x - 2;
            right_y1 = top_y;
        else
            right_x1 = right_top_peak_matrix(2);
            right_y1 = top_y;
        end
    else
        right_x1 = res_x / 4;
        right_y1 = right_left_peak_matrix(2) + 10;
    end

    if right_bot_matrix(2) == 0
        right_x2 = res_x - 1;
        right_y2 = bot_y;
    else
        right_x2 = right_bot_peak_matrix(2);
        right_y2 = bot_y;
    end

end

function [left_x1, left_y1] = scaledLeftx(top_y, left_x1, left_x2, left_y1, left_y2)
            
    if left_y1 ~= top_y

        m = (left_y2 - left_y1) / (left_x2 - left_x1);

        left_x1 = (top_y - left_y2 + m * left_x2) / m;

        left_y1 = top_y;

    end

end

function [right_x1, right_y1] = scaledRightx(top_y, right_x1, right_x2, right_y1, right_y2)

    if right_y1 ~= top_y

        m = (right_y2 - right_y1) / (right_x2 - right_x1);

        right_x1 = (top_y - right_y2 + m * right_x2) / m;
        
        right_y1 = top_y;
        
    end

end

function central_x1 = findCentralx1(left_x1, right_x1)

    central_x1 = (left_x1 + right_x1) / 2;

end

function central_x2 = findCentralx2(left_x2, right_x2)
            
    central_x2 = (left_x2 + right_x2) / 2;

end

function central_ext_x = centralExtLane(object_ext_y, central_x1, central_x2, top_y, bot_y)
            
    m = (top_y - bot_y) / (central_x1 - central_x2);

    central_ext_x = (object_ext_y - bot_y + m * central_x2) / m;

end

function [ROI_ext_left_x, ROI_ext_left_y] = ROIextLeft(object_ext_y, left_x1, left_x2, left_y1, left_y2)

    m = (left_y2 - left_y1) / (left_x2 - left_x1);

    ROI_ext_left_x = (object_ext_y - left_y2 + m * left_x2) / m;
    
    ROI_ext_left_y = object_ext_y;
    
end
            
function [ROI_ext_right_x, ROI_ext_right_y] = ROIextRight(object_ext_y, right_x1, right_x2, right_y1, right_y2)

    m = (right_y2 - right_y1) / (right_x2 - right_x1);

    ROI_ext_right_x = (object_ext_y - right_y2 + m * right_x2) / m;
    
    ROI_ext_right_y = object_ext_y;
    
end

function [ROI_top_left_x, ROI_top_left_y] = ROItopLeft(object_top_y, left_x1, left_x2, left_y1, left_y2)

    m = (left_y2 - left_y1) / (left_x2 - left_x1);

    ROI_top_left_x = (object_top_y - left_y2 + m * left_x2) / m;
    
    ROI_top_left_y = object_top_y;
    
end
          
function [ROI_top_right_x, ROI_top_right_y] = ROItopRight(object_top_y, right_x1, right_x2, right_y1, right_y2)

    m = (right_y2 - right_y1) / (right_x2 - right_x1);

    ROI_top_right_x = (object_top_y - right_y2 + m * right_x2) / m;
    
    ROI_top_right_y = object_top_y;
    
end

function [ROI_bot_left_x, ROI_bot_left_y] = ROIbotLeft(object_bot_y, left_x1, left_x2, left_y1, left_y2)

    m = (left_y2 - left_y1) / (left_x2 - left_x1);

    ROI_bot_left_x = (object_bot_y - left_y2 + m * left_x2) / m;
    
    ROI_bot_left_y = object_bot_y;
    
end
          
function [ROI_bot_right_x, ROI_bot_right_y] = ROIbotRight(object_bot_y, right_x1, right_x2, right_y1, right_y2)

    m = (right_y2 - right_y1) / (right_x2 - right_x1);

    ROI_bot_right_x = (object_bot_y - right_y2 + m * right_x2) / m;
    
    ROI_bot_right_y = object_bot_y;
    
end

function [object_ext_left_area, object_ext_right_area] = getExtObjectROI(filteredObjectImage, central_ext_x, object_ext_y, ROI_ext_left_x, ROI_ext_right_x)
            
    %crop ext left ROI from object image
    object_ext_left_area = imcrop(filteredObjectImage, [ROI_ext_left_x, object_ext_y, central_ext_x - ROI_ext_left_x, 0]);

    %crop ext right ROI from object image
    object_ext_right_area = imcrop(filteredObjectImage, [central_ext_x, object_ext_y, ROI_ext_right_x - central_ext_x, 0]);

end

function [object_top_left_area, object_top_right_area] = getTopObjectROI(filteredObjectImage, central_x1, object_top_y, ROI_top_left_x, ROI_top_right_x)
            
    %crop top left ROI from object image
    object_top_left_area = imcrop(filteredObjectImage, [ROI_top_left_x, object_top_y, central_x1 - ROI_top_left_x, 0]);

    %crop top right ROI from object image
    object_top_right_area = imcrop(filteredObjectImage, [central_x1, object_top_y, ROI_top_right_x - central_x1, 0]);
            
end

function [object_bot_left_area, object_bot_right_area] = getBotObjectROI(filteredObjectImage, central_x2, object_bot_y, ROI_bot_left_x, ROI_bot_right_x)

    %crop bot left ROI from object image
    object_bot_left_area = imcrop(filteredObjectImage, [ROI_bot_left_x, object_bot_y, central_x2 - ROI_bot_left_x, 0]);

    %crop bot right ROI from object image
    object_bot_right_area = imcrop(filteredObjectImage, [central_x2, object_bot_y, ROI_bot_right_x - central_x2, 0]);
end

function [object_ext_left_x, object_ext_right_x] = pixelFinderExt(object_ext_left_area, object_ext_right_area, central_ext_x)
            
    %find the first and last white pixels in ext ROI
    object_ext_left_x = find(object_ext_left_area, 1, 'last');
    object_ext_right_x = find(object_ext_right_area, 1, 'first') + central_ext_x;

end

function [object_top_left_x, object_top_right_x] = pixelFinderTop(object_top_left_area, object_top_right_area, central_x1)

    %find the first and last white pixels in top ROI
    object_top_left_x = find(object_top_left_area, 1, 'last');
    object_top_right_x = find(object_top_right_area, 1, 'first') + central_x1;

end

function [object_bot_left_x, object_bot_right_x] = pixelFinderBot(object_bot_left_area, object_bot_right_area, central_x2)
            
    %find the first and last white pixels in top ROI
    object_bot_left_x = find(object_bot_left_area, 1, 'last');
    object_bot_right_x = find(object_bot_right_area, 1, 'first') + central_x2;

end

function right_x1 = getRightx1(object_ext_y, top_y, bot_y, right_x0, right_x2)
                        
    m = (object_ext_y - bot_y) / (right_x0 - right_x2);

    right_x1 = (top_y - bot_y + m * right_x2) / m;

end

function left_x1 = getLeftx1(object_ext_y, top_y, bot_y, left_x0, left_x2)

    m = (object_ext_y - bot_y) / (left_x0 - left_x2);

    left_x1 = (top_y - bot_y + m * left_x2) / m;

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