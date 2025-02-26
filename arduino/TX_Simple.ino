#include <SPI.h>
#include <LoRa.h>
//ESP23 Dev Module
//NSS   5
//MOSI  23
//MISO  19
//SCK   18
//RST   21
//DIO0  22
//LED   2
#define NSS 5
#define RST 21
#define DIO0 22

int btn[] = {32, 33, 25, 26, 27, 14, 13, 4};
byte data = 0;

void setup() {
    for (auto i : btn) pinMode(i, INPUT);
    LoRa.setPins(NSS, RST, DIO0);
    if (!LoRa.begin(433E6)) {
        while(1);
    }
}

void loop() {
    data = 0;
    for(int i = 0; i < 8; i++) {
        data |= (!digitalRead(btn[i]) << i);
    }

    LoRa.beginPacket();
    LoRa.write(data);
    LoRa.endPacket();
    delay(50);
}
