function birdsEye = BEVFilter(image, res_x, res_y)
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
end