#include "ManualRCEnabled.h"
#include <ros.h>
#include <rosserial_arduino/TurnAngle.h>
#include <rosserial_arduino/Power.h>

//DRCDroid matlab_droid(5, 7);  //servo pin, esc pin

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
  ManualControlSetup();
  nh.initNode();
  nh.advertiseService(turn_angle_svc);
  nh.advertiseService(power_svc);
  nh.spinOnce();
}

void loop() {
  PPMUpdater();

  if(droidState == 0) //kill mode: completely stop droid
  {
    matlab_droid.setPower(0);
    matlab_droid.steerAngle(0);
    matlab_droid.stop();
  }
  else if(droidState == 1) //manual rc control mode
  {
    ManualControlProcessor();
  }
  else if(droidState == 2) //autonomous mode
  {
    nh.spinOnce();
  }
  matlab_droid.steerPID();
}
