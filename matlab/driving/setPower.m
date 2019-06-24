function setPower(power)
%DRIVEDROID Steering using ros service
    power_svc = rossvcclient('/droid/power');
    power_msg = rosmessage(power_svc);
    
    power_msg.Power = power;
    
    try
        power_svc.call(power_msg, 'Timeout', 10);
    end
end

