//#include "DRCDroid.h"
//#include <ros.h>
//#include <rosserial_arduino/TurnAngle.h>
//
//DRCDroid matlab_droid;
//
//ros::NodeHandle nh;
//using rosserial_arduino::TurnAngle;
//
//void turnAngleCallback(const TurnAngle::Request & req, TurnAngle::Response & res){
//  matlab_droid.steerAngle(req.angle);
//}
//
//ros::ServiceServer<TurnAngle::Request, TurnAngle::Response> turn_angle_svc("steerAndDrive",&turnAngleCallback);
//
//void setup() {
//  nh.initNode();
//  nh.advertiseService(turn_angle_svc);
//}
//
//void loop() {
//  nh.spinOnce();
//}

#include "DRCDroid.h"

DRCDroid matlab_droid(7, 9);  //servo pin, esc_pin
float motor_power = 0;
int esc_value = 1500;

void setup() {
  matlab_droid.init();
  Serial.begin(9600);
}

void loop() {
  if(Serial.available() > 0)
  {
    motor_power = Serial.parseFloat();
    while(Serial.available())
    {
      Serial.read();
    }
    Serial.println(motor_power);
    esc_value = matlab_droid.setPower(motor_power);
    Serial.println(esc_value);
  }
}
