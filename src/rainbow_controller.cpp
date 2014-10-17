// This #include statement was automatically added by the Spark IDE.
#include "lib1.h"

// This #include statement was automatically added by the Spark IDE.
#include "neopixel/neopixel.h"

#include "application.h"
//#include "spark_disable_wlan.h" // For faster local debugging only
#include "neopixel/neopixel.h"

// Set the LED strip pin, pixel count and type
#define PIXEL_PIN D1
#define PIXEL_COUNT 12
#define PIXEL_TYPE WS2812B

Adafruit_NeoPixel strip = Adafruit_NeoPixel(PIXEL_COUNT, PIXEL_PIN, PIXEL_TYPE);

// name the pins
int led1 = D0;
int led2 = D2;
char patternArr[255] = "rainbow";
String pattern(patternArr);

// This routine runs only once upon reset
void setup()
{
   //Register our 4 Spark functions here
   Spark.function("echo", echo);
   Spark.function("ledsOn", ledsOn);
   Spark.function("ledsOff", ledsOff);
   // change the pattern of the LED strip
   Spark.function("changePat", changePat);
   // LIMIT IS 4 functions!!!
   
   // Configure the pins to be outputs
   pinMode(led1, OUTPUT);
   pinMode(led2, OUTPUT);

   // Initialize the LEDs to be off and on
   digitalWrite(led1, LOW);
   digitalWrite(led2, HIGH);
   
   strip.begin();
   rainbow(20);
   strip.show(); // Initialize all pixels to 'off'
}


// This routine loops forever
void loop()
{
if (pattern == "rainbow") {
      rainbow(20);
};
if (pattern == "red") {
  red();
};

if (pattern == "green") {
  green();
};

if (pattern == "blue") {
  blue();
};

if (pattern == "colorwipe") {
  colorWipe(100, 20);
};

if (pattern == "indigo") {
  indigo();
};

if (pattern == "color100") {
  setColor(100);
};

if (pattern == "colorall200") {
  colorAll(100, 20);
};

if (pattern == "random") {
  random();;
};

if (pattern == "candle") {
  candle();;
};

digitalWrite(led1, HIGH);
delay(50);
digitalWrite(led1, LOW);
}

// change the LED strip pattern
int changePat(String newPattern) {
  if (newPattern == "rainbow") {
      pattern = "rainbow";
      return 1;
  };
  if (newPattern == "red") {
      pattern = "red";
      return 2;
  };
  
  if (newPattern == "green") {
      pattern = "green";
      return 3;
  };
  
  if (newPattern == "blue") {
       pattern = "blue";
      return 4;
  };
  
  if (newPattern == "colorwipe") {
       pattern = "colorwipe";
      return 5;
  };
  
  if (newPattern == "indigo") {
      pattern = "indigo";
      return 6;
  };
  
 if (newPattern == "color100") {
      pattern = "color100";
      return 7;
  };
  
  if (newPattern == "colorall200") {
      pattern = "colorall200";
      return 8;
  };
  
  if (newPattern == "random") {
      pattern = "random";
      return 9;
  };
  
  if (newPattern == "candle") {
      pattern = "candle";
      return 9;
  };
  
  // named pattern not found
  return -1;
}

// echo the string length of the incomming parameter
int echo(String parameter) {
  int length = parameter.length();
  return length;
}

// functions with no parameters and no return 1
int ledsOn(String command) {
   digitalWrite(led1, HIGH);
   digitalWrite(led2, HIGH);
    return 1;
}

int ledsOff(String command) {
   digitalWrite(led1, LOW);
   digitalWrite(led2, LOW);
    return 1;
}

// rotate color wheel every wait milli-second
void rainbow(uint8_t wait) {
  uint16_t i, j;
  for(j=0; j<256; j++) {
    for(i=0; i<strip.numPixels(); i++) {
      strip.setPixelColor(i, Wheel((i+j) & 255));
    }
    strip.show();
    delay(wait);
  }
}

void red() {
    int i;
    for(i=0; i<strip.numPixels(); i++) {
      strip.setPixelColor(i, 255, 0, 0);
    }
    strip.show();
}

void green() {
   int i;
    for(i=0; i<strip.numPixels(); i++) {
      strip.setPixelColor(i, 0, 255, 0);
    }
    strip.show();
}

void blue() {
   int i;
    for(i=0; i<strip.numPixels(); i++) {
      strip.setPixelColor(i, 0, 0, 255);
    }
    strip.show();
}

void indigo() {
   int i;
    for(i=0; i<strip.numPixels(); i++) {
      strip.setPixelColor(i, 75, 0, 130);
    }
    strip.show();
}
  
// set a static color
void setColor(int color) {
    for(uint16_t i=0; i<strip.numPixels(); i++) {
      strip.setPixelColor(i, Wheel(color));
    }
    strip.show();
}

// Input a value 0 to 255 to get a color value.
// The colours are a transition r - g - b - back to r.
uint32_t Wheel(byte WheelPos) {
  if(WheelPos < 85) {
   return strip.Color(WheelPos * 3, 255 - WheelPos * 3, 0);
  } else if(WheelPos < 170) {
   WheelPos -= 85;
   return strip.Color(255 - WheelPos * 3, 0, WheelPos * 3);
  } else {
   WheelPos -= 170;
   return strip.Color(0, WheelPos * 3, 255 - WheelPos * 3);
  }
}

// color all pixels with this color and wait
void colorAll(uint32_t c, uint8_t wait) {
  uint16_t i;
  
  for(i=0; i<strip.numPixels(); i++) {
    strip.setPixelColor(i, c);
  }
  strip.show();
  delay(wait);
}

// Fill the dots one after the other with a color, wait (ms) after each one
void colorWipe(uint32_t c, uint8_t wait) {
  for(uint16_t i=0; i<strip.numPixels(); i++) {
    strip.setPixelColor(i, c);
    strip.show();
    delay(wait);
  }
}

void random() {
  for(uint16_t i=0; i<strip.numPixels(); i++) {
     strip.setPixelColor(i, random(255), random(255), random(255));
     strip.show();
     delay(100);
  }
}

void candle() {
   uint16_t yellowBright; // brightness of the yellow
   uint16_t redBright;  // add a bit for red
   for(uint16_t i=0; i<1000; i++) {
     yellowBright = 50 + random(155);
     redBright = yellowBright + random(50);
     strip.setPixelColor(random(12), redBright, yellowBright, 0);
     strip.show();
     delay(10);
  }
}