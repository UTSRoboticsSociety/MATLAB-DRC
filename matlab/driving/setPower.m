function setPower(power_svc, power_msg, power)
%DRIVEDROID Setting the droid's power using ros service
    power_msg.Power = power;
    try
        power_svc.call(power_msg, 'Timeout', 10);
    end
end
