#include "DRCDroid.h"

DRCDroid::DRCDroid(int servo_pin, int esc_pin):
  servo_pin_(servo_pin),
  esc_pin_(esc_pin),
  esc(esc_pin_, ESC_MIN, ESC_MAX, ESC_MID),
  droid_pid(&Input, &Output, &Setpoint, Kp, Ki, Kd, DIRECT)
{
  
}

void DRCDroid::init()
{
  servo.attach(servo_pin_);
  esc.arm();
  droid_pid.SetMode(AUTOMATIC);
  droid_pid.SetOutputLimits(-38, 38);
  droid_pid.SetSampleTime(10);
  droid_pid.SetTunings(Kp, Ki, Kd);
  droid_pid.SetControllerDirection(REVERSE);
}

void DRCDroid::steerAngle(float angle)
{
  Input = angle;
}

int DRCDroid::setPower(float power)
{
  if (power > 100) power = 100;
  if (power < -100) power = -100;
  esc_value = map(power, -100, 100, ESC_MIN, ESC_MAX);
  esc.speed(esc_value);
  return esc_value;
}

void DRCDroid::stop()
{
  esc.stop();
}

void DRCDroid::steerPID()
{
  droid_pid.Compute();
  servo.write(Output+90);
}
