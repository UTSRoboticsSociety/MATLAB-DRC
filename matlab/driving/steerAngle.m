function steerAngle(steer_svc, steer_msg, angle)
%DRIVEDROID Steering using ros service
    steer_msg.Angle = angle;
    try
        steer_svc.call(steer_msg, 'Timeout', 10);
    end
end