%INPUT RESOLUTION HERE
res_x = 480;            %<<<
res_y = 270;            %<<<
%^^ INPUT RESOLUTION ^^
%270p = 480x270
%480p = 854x480
%720p = 1280x720

while hasFrame(vid)
    
    Image = readFrame(vid);

    %want 10fps, 0.1s * 100 = 10, 10mod10 = 0
    %0.2s *100 = 20, 20mod10 = 0
    currentTime = vid.CurrentTime * 100;
    
    if mod(currentTime, 10) == 0
        
        %sobel filtering
        %BW = rgb2gray(Image);
        %imageSobel = edge(BW, 'Sobel', 0.05);
        %filteredSobel = bwareaopen(imageSobel, 40);
        
        %% create filters
        blueHSVImage = createBlueHSVMask(Image);
        blueLABImage = createBlueLABMask(Image);
        blueImg = (blueHSVImage & blueLABImage);

        yellowHSVImage = createYellowHSVMask(Image);
        yellowLABImage = createYellowLABMask(Image);
        yellowImg = (yellowHSVImage & yellowLABImage);
        
        %filters the images individually
        filteredBlue = bwareaopen(blueImg, 40);
        filteredYellow = bwareaopen(yellowImg, 40);
        
        %now create areas of interest for these 2 filtered images
        %also need to create a switch between left blue and right blue
        
        %% IMPORTANT CHANGE THIS FOR DIFFERENT SIDED LANES
        %this is the switch
        %0 is blue on left, 1 is blue on right
        x = 1;
        [leftImage, rightImage] = colourSwitch(x, filteredBlue, filteredYellow);
        
        %% make regions of interest for lane detection
        
        %making ROIs for LEFT LANE: top, bot, vert_left, vert_mid, vert_right, and stop
        %crop top area of interest for analysis
        [left_top_sum, left_bot_sum, left_right_sum, left_stop_sum] = LeftSum(res_x, top_y, bot_y, res_y, leftImage);

        %making RIGHT LANE
        %crop top area of interest for analysis
        [right_top_sum, right_bot_sum, right_left_sum, right_stop_sum] = RightSum(res_x, top_y, bot_y, res_y, rightImage);

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

            BW = rgb2gray(Image);
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
            
            %overlay everything
            textStr = ['Deviation: ' num2str(error) ' pixels'];

            AnnotatedImage = insertText(Image, [res_x / 2 - 80 bot_y + 10], textStr, 'FontSize', 16);

            imshow(AnnotatedImage);

            hold on

            plot([left_x1, left_x2], [left_y1, left_y2], 'LineWidth', 2, 'Color', 'r'); %draw left lane

            plot([right_x1, right_x2], [right_y1, right_y2], 'LineWidth', 2, 'Color', 'r'); %draw right lane

            plot(midpoint_average_x, midpoint_average_y, 'bo'); %plot midpoint of guidance lane

            plot([absolute_direction_x1, absolute_direction_x2], [top_y, bot_y], 'LineWidth', 2, 'Color', 'y'); %absolute position and direction of the car
            
            plot([ROI_ext_left_x, central_ext_x], [object_ext_y, object_ext_y], 'Color', 'c');
            
            plot([central_ext_x, ROI_ext_right_x], [object_ext_y, object_ext_y], 'Color', 'g');
            
            plot([ROI_top_left_x, central_x1], [object_top_y, object_top_y], 'Color', 'c');
            
            plot([central_x1, ROI_top_right_x], [object_top_y, object_top_y], 'Color', 'g');
            
            plot([ROI_bot_left_x, central_x2], [object_bot_y, object_bot_y], 'Color', 'c');
            
            plot([central_x2, ROI_bot_right_x], [object_bot_y, object_bot_y], 'Color', 'g');
            
        else
            
            %this triggers if the lane is seen at the bottom area of the
            %image
            error = 42069;
            textStr = 'STOP: WRONG WAY';
            AnnotatedImage = insertText(Image, [res_x / 2 - 100 top_y - 50], textStr, 'FontSize', 20, 'BoxColor', 'r');
            imshow(AnnotatedImage);
            
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