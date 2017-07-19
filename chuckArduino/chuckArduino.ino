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
void loop() {
    //-4,-1,-193,-4,118,0,0 - output of nunchuk_print();
    if (nunchuk_read()) {
      if (nunchuk_accelX() > VIBRATO_THRESHOLD || nunchuk_accelX() < (VIBRATO_THRESHOLD * -1)) {
        Serial.println(VIBRATO_MID + nunchuk_accelX()); //vibrato will return val between 1500 and 2500
      }
      if (nunchuk_joystickY() > Y_THRESHOLD || nunchuk_joystickY() < (Y_THRESHOLD * -1)) {
        Serial.println(BEND_MID + nunchuk_joystickY()); //bends will return val between 400 and 600
      }
    }
    delay(20); //lower than 20 and chuck has hard time keeping up.
}
