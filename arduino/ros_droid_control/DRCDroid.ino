#include "DRCDroid.h"

DRCDroid::DRCDroid():
  esc(ESC_PIN, ESC_MIN, ESC_MAX, ESC_MID)
{
  servo.attach(SERVO_PIN);
  esc.arm();
  delay(4000);
}

void DRCDroid::steerAngle(float angle)
{
  if (angle < -30 ) angle = -30;
  if (angle > 30) angle = 30;
  servo.write(angle+90);
}

void DRCDroid::setVelocity(float velocity)
{
  esc_value = map(velocity, -100, 100, ESC_MIN, ESC_MAX);
}
