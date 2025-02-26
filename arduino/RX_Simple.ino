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


//Arduino Uno
//SCK   13
//MISO  12
//MOSI  11
//NSS   10
//DIO0  A0
//RST   A1


// #define NSS 10
// #define RST A1
// #define DIO0 A0

#define NSS 5
#define RST 21
#define DIO0 22

int led[] = {32, 33, 25, 26, 27, 17, 13, 4};
byte data = 0;

void setup() {
    Serial.begin(9600);
    for (auto i : led) pinMode(i, OUTPUT);
    LoRa.setPins(NSS, RST, DIO0);
    if (!LoRa.begin(433E6)) {
        while(1);
    }    
    Serial.println("LoRa RX");
}

void loop() {
    int parsePacket = LoRa.parsePacket();
    Serial.println(parsePacket);
    if (parsePacket) {
        Serial.println("data received: ");
        while(LoRa.available()) {
            data = LoRa.read();
        }
        Serial.println(data, BIN);

        for (int i = 7; i >= 0; i--) digitalWrite(led[i], (data & (1 << i)) ? HIGH : LOW);
    }
}
