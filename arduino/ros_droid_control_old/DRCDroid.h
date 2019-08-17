#ifndef DRCDROID_H
#define DRCDROID_H

#include <Servo.h>
#include "ESC.h"

#define ESC_MIN 1400
#define ESC_MAX 1600
#define ESC_MID 1500

class DRCDroid {

public:
  DRCDroid(int servo_pin, int esc_pin); //set the pins
  void init();                          //initialise the droid
  void steerAngle(float angle);         //set steering angle (-30 to 30)
  int setPower(float power);           //set motor power (-100 to 100)
  void stop();                          //stop the droid from moving
  
private:
  int servo_pin_, esc_pin_;
  Servo servo;
  ESC esc;
  int esc_value = 1500;
};

#endif
