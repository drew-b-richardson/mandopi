#include <Wire.h>
#include "Nunchuk.h"

void setup() {

    Serial.begin(9600);
    Wire.begin();
    nunchuk_init();

}
int BEND_MID = 500;
int Y_THRESHOLD = 5;
int VIBRATO_MID = 2000;
int VIBRATO_THRESHOLD = 100;
bool isSending = false;
bool zIsTriggered = false;
void loop() {
  //-4,-1,-193,-4,118,0,0 - output of nunchuk_print();
  if (nunchuk_read()) {

    //turn on/off send via z-button
    // if (nunchuk_buttonZ() == 1 && !zIsTriggered) {
    //   zIsTriggered = true;
    // }
    // if (nunchuk_buttonZ() == 0 && zIsTriggered) {
    //   zIsTriggered = false;
    //   if (isSending) {
    //     isSending = false;
    //   }
    //   else{
    //     isSending = true;
    //   }
    // }
    //
    //if set to send, send steady stream of data
    //if (isSending) {
    if (nunchuk_buttonZ() == 1) {
      if (nunchuk_accelX() > VIBRATO_THRESHOLD || nunchuk_accelX() < (VIBRATO_THRESHOLD * -1)) {
        Serial.println(VIBRATO_MID + nunchuk_accelX()); //vibrato will return val between 1500 and 2500
      }
      if (nunchuk_joystickY() > Y_THRESHOLD || nunchuk_joystickY() < (Y_THRESHOLD * -1)) {
        Serial.println(BEND_MID + nunchuk_joystickY()); //bends will return val between 400 and 600
      }
    }
  }
  delay(20); //lower than 20 and chuck has hard time keeping up.
}
