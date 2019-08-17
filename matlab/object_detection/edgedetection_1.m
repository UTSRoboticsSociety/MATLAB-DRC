clear all 

% caminf = imaqhwinfo;
% mycam = char(caminf.InstalledAdaptors(end));
% mycaminfo = imaqhwinfo(mycam);
% resolution = char(mycaminfo.DeviceInfo.SupportedFormats(end));
% 
% obj=videoinput('winvideo',1);
% obj.ReturnedColorspace = 'grayscale';
% B=getsnapshot(obj);

% FR = vision.VideoFileReader('LOcombo.avi','ImageColorSpace','intensity','VideoOutputDataType','uint8');
% vid = VideoReader('LOcombo.avi');

% VP = vision.DeployableVideoPlayer;
% 
% framesAcquired = 0;
% 
%  obj=videoinput('winvideo',1);
%  obj.ReturnedColorspace = 'rgb';

vid = imaq.VideoDevice('winvideo', 2, 'YUY2_320x240', 'ReturnedColorSpace', 'rgb');

% while true
%     data = step(FR);
%     level=graythresh(data);
%     bw=im2bw(data,level);
%     bw=bwareaopen(bw, 45);
%     se=strel('disk',0);
%     bw=imclose(bw,se);
%     bw=~bw;
%     imshow(bw);  
% end

% while true
%     data = step(FR);
%     [~,threshold] = edge(data,'sobel');
%     fudgeFactor = 0.5;
%     BWs = edge(data,'sobel',threshold * fudgeFactor);
%     se90 = strel('line',3,90);
%     se0 = strel('line',3,0);
%     BWsdil = imdilate(BWs,[se90 se0]);
%     BWdfill = imfill(BWsdil,'holes');
%     BWnobord = imclearborder(BWdfill,4);
%     seD = strel('diamond',1);
%     BWfinal = imerode(BWnobord,seD);
%     BWfinal = imerode(BWfinal,seD);
% %     BWoutline = bwperim(BWfinal);
% %     Segout = data; 
% %     Segout(BWoutline) = 255; 
%     imshow(BWfinal);
% end  

% while true
%     data = step(FR);
%     [~,threshold] = edge(data,'sobel');
%     fudgeFactor = 4.5;
%     BWs = edge(data,'sobel',threshold * fudgeFactor);
%     se90 = strel('line',3,90);
%     se0 = strel('line',3,0);
%     BWsdil = imdilate(BWs,[se90 se0]);
%     BWdfill = imfill(BWsdil,'holes');
%     BW = ~(BWdfill);
%     imshow(BW); 
% %     BWnobord = imclearborder(BWdfill,4);
% %     seD = strel('diamond',1);
% %     BWfinal = imerode(BWnobord,seD);
% %     BWfinal = imerode(BWfinal,seD);
%   
% %     dim = size(BWdfill);
% %     col = 640;
% %     row = 1000;
% %     boundary = bwtraceboundary(BWdfill,[640, 1000],'n');
% %     plot(boundary(:,2),boundary(:,1),'g','LineWidth',3);
% %     boundaries = bwboundaries(BWdfill);
% %     hold on;
% %     labeledImage = logical(BWdfill); %not needed, image should be already in logical
% %     measurements = regionprops(labeledImage, 'BoundingBox');
% %     for k = 1 : length(measurements)
% %     thisBB = measurements(k).BoundingBox;
% %     rectangle('Position',[thisBB(1),thisBB(2),thisBB(3),thisBB(4)],'EdgeColor','b','LineWidth',1 );
% %     end
% end

while true
    I = step(vid);
    BW = rgb2gray(I);
    [~,threshold] = edge(BW,'canny');
    fudgeFactor = 9;
    BWs = edge(BW,'canny',0.4);
    se90 = strel('line',3,90);
    se0 = strel('line',3,0);
    BWsdil = imdilate(BWs,[se90 se0]);
    BWdfill = imfill(BWsdil,'holes');
%   [B,L,n,A] = bwboundaries(BWdfill,8,'noholes');
    CC = bwconncomp(BWdfill,4);
    S = regionprops(CC,'Centroid');
    info = regionprops(CC,'Boundingbox');
    [labeledImage, numBlobs] = bwlabel(BWdfill);
    props = regionprops(labeledImage, 'BoundingBox');
    imshow(BWdfill);
    hold on
%    for k = 1:length(B)
%    boundary = B{k};
%    plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
%    end
%    hold on

% for k = 1 : length(info)
%      BB = info(k).BoundingBox;
%      rectangle('Position', [BB(1),BB(2),BB(3),BB(4)],'EdgeColor','r','LineWidth',2) ;
% end

for k = 1 : numBlobs
  thisBoundingBox = props(k).BoundingBox
  rectangle('Position', thisBoundingBox, ...
    'EdgeColor', 'r', 'LineWidth', 2);
end

%     imshow(BWdfill);
%     dim = size(BWdfill);
%     col = 640;
%     row = 1000;
%     boundary = bwtraceboundary(BW,[640, 1000],'n');
%     plot(boundary(:,2),boundary(:,1),'g','LineWidth',3);
%     boundaries = bwboundaries(BW);
end

clear all