function error = laneSteerImcrop(filtered_left_img,filtered_right_img, filtered_green_img)
%LANESTEERIMCROP Summary of this function goes here
    %INPUT RESOLUTION HERE
    res_x = 424;            %<<<
    res_y = 240;            %<<<

    %average aoi values
    bot_y = round(res_y / 10 * 6.5, 0);
    top_y = round(res_y / 10 * 5, 0);

    %initial values for out of bounds actions
    left_out = 0;
    right_out = 0;
    
    [left_top_area, left_bot_area, left_right_area, left_stop_area] = getLeftROIs(filtered_left_img, res_x, res_y, top_y, bot_y);
        
    [right_top_area, right_bot_area, right_left_area, right_stop_area] = getRightROIs(filtered_left_img, res_x, res_y, top_y, bot_y);

    final_stop_area = getFinalStopROI(filtered_green_img, res_x, bot_y, res_y);

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
            left_x0 = res_x / 4 * 3;
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
            right_x0 = res_x / 4;
            right_y0 = raw_right_y0;
            right_x1 = rightConverter(right_x0, right_y0, top_y, right_x2, right_y2);
            right_y1 = top_y;
        end

        %this section for left out of lane maneuvers
        if isempty(raw_left_y3) == false
            left_out = 1;
        end

        if isempty(raw_right_x1) == false || isempty(raw_right_x2) == false
            left_out = 0;
        end

        if left_out == 1
            left_x1 = res_x / 4 * 3;
        end

        %this section for right out of lane maneuvers
        if isempty(raw_right_y3) == false
            right_out = 1;
        end

        if isempty(raw_left_x1) == false || isempty(raw_left_x2) == false
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
        error = round(midpoint_average_x - midpoint_absolute_x, 0)*(-1);
    else
        error = 8888;
    end
end

%% isolate the ROIs
function [left_top_area, left_bot_area, left_right_area, left_stop_area] = getLeftROIs(leftImage, res_x, res_y, top_y, bot_y)

    left_top_area = imcrop(leftImage, [1, top_y, res_x - 1, 0]);
    left_bot_area = imcrop(leftImage, [1, bot_y, res_x - 1, 0]);
    left_right_area = imcrop(leftImage, [res_x / 4 * 3, 20, 0, bot_y - 1]);
    left_stop_area = imcrop(leftImage, [res_x / 2, bot_y, 0, res_y - bot_y]);

end

function [right_top_area, right_bot_area, right_left_area, right_stop_area] = getRightROIs(rightImage, res_x, res_y, top_y, bot_y)

    right_top_area = imcrop(rightImage, [1, top_y, res_x - 1, 0]);
    right_bot_area = imcrop(rightImage, [1, bot_y, res_x - 1, 0]);
    right_left_area = imcrop(rightImage, [res_x / 4, 20, 0, bot_y - 1]);
    right_stop_area = imcrop(rightImage, [res_x / 2, bot_y, 0, res_y - bot_y]);

end

function final_stop_area = getFinalStopROI(filteredGreen, res_x, bot_y, res_y)

    final_stop_area = imcrop(filteredGreen, [res_x / 2, res_y - 20, 0, 20]);
    
end

%% find first and last pixels for sides
function [raw_left_x0, raw_left_y0, raw_left_x1, raw_left_y1, raw_left_x2, raw_left_y2, raw_left_x3, raw_left_y3] = getLeftCoords(res_x, bot_y, top_y, left_top_area, left_bot_area, left_right_area, left_stop_area)

     raw_left_x0 = res_x / 4 * 3;
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

    raw_right_x0 = res_x / 4;
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
