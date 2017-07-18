#include <Wire.h>
#include "Nunchuk.h"

void setup() {

    Serial.begin(9600);
    Wire.begin();
    nunchuk_init();

}

void loop() {
//-4,-1,-193,-4,118,0,0


    if (nunchuk_read()) {
        if (nunchuk_buttonZ() == 1) {
          Serial.println("z");
        }
        //nunchuk_print();

    }
    delay(500);
}
