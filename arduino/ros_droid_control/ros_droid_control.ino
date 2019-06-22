#include "DRCDroid.h"
#include <ros.h>
#include <rosserial_arduino/TurnAngle.h>
#include <rosserial_arduino/Power.h>

DRCDroid matlab_droid(5, 7);  //servo pin, esc pin

ros::NodeHandle nh;
using rosserial_arduino::TurnAngle;
using rosserial_arduino::Power;


void turnAngleCallback(const TurnAngle::Request & req, TurnAngle::Response & res){
  matlab_droid.steerAngle((float)req.angle);
}

void powerCallback(const Power::Request & req, Power::Response & res){
  matlab_droid.setPower(req.power);
}

ros::ServiceServer<TurnAngle::Request, TurnAngle::Response> turn_angle_svc("/droid/steer",&turnAngleCallback);
ros::ServiceServer<Power::Request, Power::Response> power_svc("/droid/power",&powerCallback);

void setup() {
  matlab_droid.init();
  nh.initNode();
  nh.advertiseService(turn_angle_svc);
  nh.advertiseService(power_svc);
}

void loop() {
  nh.spinOnce();
}
