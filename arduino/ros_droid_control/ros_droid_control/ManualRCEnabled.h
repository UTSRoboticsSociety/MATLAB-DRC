#ifndef MANUAL_RC_ENABLED
#define MANUAL_RC_ENABLED

#define PPM_DATA_PIN 2
#define PPM_CHANNELS 10
#define MANUAL_RC_ENABLED // Turns on Module

#define MANUAL_RC_STEERING_CH  1
#define MANUAL_RC_THROTTLE_CH 2
#define MANUAL_RC_MODE_AND_E_STOP_KILL_CH 5  

//#define MANUAL_RC_BOOST_SWITCH_CH 8

#define MANUAL_RC_RECEIVER_MAX_THROTTLE_PERIOD 1800
#define MANUAL_RC_RECEIVER_MIN_THROTTLE_PERIOD 1200
#define MANUAL_RC_RECEIVER_MAX_STEERING_PERIOD 2000
#define MANUAL_RC_RECEIVER_MIN_STEERING_PERIOD 1000

#define MANUAL_RC_SWITCH_STATE_UP_LIMIT 1200
#define MANUAL_RC_SWITCH_STATE_DOWN_LIMIT 1750
#include <PinChangeInterrupt.h>

#include <PPMReader.h>
#include "DRCDroid.h"


unsigned long SteeringTimer;
unsigned long ThrottleTimer;
unsigned long ActivateTimer;

unsigned long SteeringPeriod;
unsigned long ThrottlePeriod;
unsigned long ActivatePeriod;

unsigned int PPMPeriods[PPM_CHANNELS + 1];
unsigned int droidState = 0;

struct RCControlModel
{
  unsigned char switch1State;
  unsigned int switch1Period;
  unsigned int steeringPeriod;
  unsigned int throttlePeriod;
  unsigned int panPeriod;
  unsigned int tiltPeriod;
};

RCControlModel RCController1;

PPMReader ppm(PPM_DATA_PIN, PPM_CHANNELS);

DRCDroid matlab_droid(5, 7);  //sevo pin, esc pin

void PPMUpdater()
{
  for (int i = 0; i < PPM_CHANNELS; i++)
  {
    PPMPeriods[i] = ppm.latestValidChannelValue(i,0);
   // dataContainer.PPMChannels[i] = PPMPeriods[i];
  }
  RCController1.steeringPeriod = PPMPeriods[MANUAL_RC_STEERING_CH];
  RCController1.throttlePeriod = PPMPeriods[MANUAL_RC_THROTTLE_CH];
  RCController1.switch1Period = PPMPeriods[MANUAL_RC_MODE_AND_E_STOP_KILL_CH];

  if (RCController1.switch1Period <= MANUAL_RC_SWITCH_STATE_UP_LIMIT)
  {
    droidState = 0;
  }
  else if (RCController1.switch1Period > MANUAL_RC_SWITCH_STATE_UP_LIMIT && RCController1.switch1Period < MANUAL_RC_SWITCH_STATE_DOWN_LIMIT)
  {
    droidState = 1;
  }
  else
  {
    droidState = 2;
  }
}



void ManualControlSetup()
{
  matlab_droid.init();
}

void ManualControlProcessor()
{
  matlab_droid.steerAngle((float)(map(RCController1.steeringPeriod, MANUAL_RC_RECEIVER_MIN_STEERING_PERIOD, MANUAL_RC_RECEIVER_MAX_STEERING_PERIOD, 38, -38)));


  if (RCController1.throttlePeriod > (MANUAL_RC_RECEIVER_MIN_THROTTLE_PERIOD + MANUAL_RC_RECEIVER_MAX_THROTTLE_PERIOD) / 2)
  {
    matlab_droid.setPower(constrain(map(RCController1.throttlePeriod, (MANUAL_RC_RECEIVER_MIN_THROTTLE_PERIOD + MANUAL_RC_RECEIVER_MAX_THROTTLE_PERIOD) / 2, MANUAL_RC_RECEIVER_MAX_THROTTLE_PERIOD, 0, 100), 0, 100));
  }
  else if (RCController1.throttlePeriod < (MANUAL_RC_RECEIVER_MIN_THROTTLE_PERIOD + MANUAL_RC_RECEIVER_MAX_THROTTLE_PERIOD) / 2)
  {
    matlab_droid.setPower(constrain(map(RCController1.throttlePeriod, (MANUAL_RC_RECEIVER_MIN_THROTTLE_PERIOD + MANUAL_RC_RECEIVER_MAX_THROTTLE_PERIOD) / 2, MANUAL_RC_RECEIVER_MIN_THROTTLE_PERIOD, 0, -100), -100, 0));
  }
  else
  {
    matlab_droid.setPower(0);
  }  //edit the few lines pf code to fit the Matlab DROID for DRC
}


#endif // MANUAL_RC_ENABLED
