#include "DRCDroid.h"

DRCDroid::DRCDroid(int servo_pin, int esc_pin):
  servo_pin_(servo_pin),
  esc_pin_(esc_pin),
  esc(esc_pin_, ESC_MIN, ESC_MAX, ESC_MID)
{
  
}

void DRCDroid::init()
{
  servo.attach(servo_pin_);
  esc.arm();
}

void DRCDroid::steerAngle(float angle)
{
  if (angle < -30 ) angle = -30;
  if (angle > 30) angle = 30;
  servo.write(angle+90);
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
