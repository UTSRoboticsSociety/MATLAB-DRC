#ifndef DRCDROID_H
#define DRCDROID_H

#include <Servo.h>
#include "ESC.h"
#include <PID_v1.h>

#define ESC_MIN 1300
#define ESC_MAX 1700
#define ESC_MID 1500

class DRCDroid {

public:
  DRCDroid(int servo_pin, int esc_pin); //set the pins
  void init();                          //initialise the droid
  void steerAngle(float angle);         //set steering angle (-30 to 30)
  int setPower(float power);           //set motor power (-100 to 100)

  void steerPID();
  
  void stop();                          //stop the droid from moving
  
private:
  int servo_pin_, esc_pin_;
  Servo servo;
  PID droid_pid;
//  double Kp = 0.65, Ki = 0, Kd = 0.4;
//  double Kp = 0.65, Ki = 0, Kd = 0.4;
  double Kp = 0.7, Ki = 0, Kd = 0.4;
  double Input, Output, Setpoint = 0;
  ESC esc;
  int esc_value = 1500;
};

#endif
