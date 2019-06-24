function steerAngle(steer_angle)
%DRIVEDROID Steering using ros service
    steer_svc = rossvcclient('/droid/steer');
    steer_msg = rosmessage(steer_svc);
    
    steer_msg.Angle = steer_angle;
    try
        steer_svc.call(steer_msg, 'Timeout', 10);
    end
end

