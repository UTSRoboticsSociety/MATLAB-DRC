#define AVR_Atmega328P

#include <ros.h>
#include <Servo.h>
#include <PID_v1.h>
#include <rosserial_arduino/custom.h>

#define servoPin 9

ros::NodeHandle  nh;
using rosserial_arduino::custom;

unsigned int currentOrientation;

//Define Variables we'll be connecting to
double Setpoint, Input, Output;
//Specify the links and initial tuning parameters
double Kp=0.4, Ki=0, Kd=0;
PID myPID(&Input, &Output, &Setpoint, Kp, Ki, Kd, DIRECT);

Servo myservo;

void callback(const custom::Request & req, custom::Response & res){
  currentOrientation = req.input;
  Input = currentOrientation;
  myPID.Compute();
  myservo.write(Output+90);
}

ros::ServiceServer<custom::Request, custom::Response> server("steerAndDrive",&callback);

void setup() {
  //Serial.begin(9600);

  Setpoint = 787;

  //turn the PID on
  myPID.SetMode(AUTOMATIC);
  myPID.SetOutputLimits(-30,30);

  myservo.attach(servoPin);

  nh.initNode();
  nh.advertiseService(server);
}

void loop() {
  nh.spinOnce();
  //delay(10);
}
