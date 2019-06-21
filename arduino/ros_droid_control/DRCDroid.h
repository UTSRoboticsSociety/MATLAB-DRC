#ifndef DRCDROID_H
#define DRCDROID_H

#include <Servo.h>
#include "ESC.h"

#define SERVO_PIN 9
#define ESC_PIN 7
#define ESC_MIN 1400
#define ESC_MAX 1600
#define ESC_MID 1500

class DRCDroid {

public:
  DRCDroid();
  void steerAngle(float angle);
  void setVelocity(float velocity);
  
private:
  Servo servo;
  ESC esc;
  int esc_value = 1500;
};

#endif
