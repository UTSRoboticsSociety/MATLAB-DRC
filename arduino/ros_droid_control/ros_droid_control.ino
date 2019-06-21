#include "DRCDroid.h"
#include <ros.h>
#include <rosserial_arduino/TurnAngle.h>

DRCDroid matlab_droid;

ros::NodeHandle nh;
using rosserial_arduino::TurnAngle;

void turnAngleCallback(const TurnAngle::Request & req, TurnAngle::Response & res){
  matlab_droid.steerAngle(req.angle);
}

ros::ServiceServer<TurnAngle::Request, TurnAngle::Response> turn_angle_svc("steerAndDrive",&turnAngleCallback);

void setup() {
  nh.initNode();
  nh.advertiseService(turn_angle_svc);
}

void loop() {
  nh.spinOnce();
}
