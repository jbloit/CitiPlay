#include "SPI.h"
#include "Adafruit_WS2801.h"
#include "pitches.h"

/*****************************************************************************
Example sketch for driving Adafruit WS2801 pixels!


  Designed specifically to work with the Adafruit RGB Pixels!
  12mm Bullet shape ----> https://www.adafruit.com/products/322
  12mm Flat shape   ----> https://www.adafruit.com/products/738
  36mm Square shape ----> https://www.adafruit.com/products/683

  These pixels use SPI to transmit the color data, and have built in
  high speed PWM drivers for 24 bit color per pixel
  2 pins are required to interface

  Adafruit invests time and resources providing this open source code, 
  please support Adafruit and open-source hardware by purchasing 
  products from Adafruit!

  Written by Limor Fried/Ladyada for Adafruit Industries.  
  BSD license, all text above must be included in any redistribution

*****************************************************************************/
// Optional: leave off pin numbers to use hardware SPI
// (pinout is then specific to each board and can't be changed)
//Adafruit_WS2801 strip = Adafruit_WS2801(25);

// For 36mm LED pixels: these pixels internally represent color in a
// different format.  Either of the above constructors can accept an
// optional extra parameter: WS2801_RGB is 'conventional' RGB order
// WS2801_GRB is the GRB order required by the 36mm pixels.  Other
// than this parameter, your code does not need to do anything different;
// the library will handle the format change.  Examples:
//Adafruit_WS2801 strip = Adafruit_WS2801(25, dataPin, clockPin, WS2801_GRB);
//Adafruit_WS2801 strip = Adafruit_WS2801(25, WS2801_GRB);



// LIGHT VARS

#define NUM_LIGHTS 18

int dataPin  = 2;    // Yellow wire on Adafruit Pixels
int clockPin = 3;    // Green wire on Adafruit Pixels
boolean lights[NUM_LIGHTS]; 

int sensorLightIndex[NUM_LIGHTS];

// Set the first variable to the NUMBER of pixels. 25 = 25 pixels in a row
Adafruit_WS2801 strip = Adafruit_WS2801(NUM_LIGHTS, dataPin, clockPin);





// SENSOR VARS

#define NUM_DDR_PINS 8

int ddrSensorValues[NUM_DDR_PINS];


// ARPEGIO VARS

int stepPeriod = 1000;

long dt = 0;
long lastTime = 0;
long accumDt = 0;
int currentChord = 0;
int speakerPin = 8;


int chords [13] [4] = {
  {NOTE_B1, NOTE_C2, NOTE_CS2, NOTE_D2},
  {NOTE_C4, NOTE_E4, NOTE_G4, NOTE_C5},
  {NOTE_CS4, NOTE_F4, NOTE_GS4, NOTE_CS5},
  {NOTE_D4, NOTE_FS4, NOTE_A4, NOTE_D5},
  {NOTE_DS4, NOTE_F4, NOTE_DS4, NOTE_DS5},
  {NOTE_E4, NOTE_GS4, NOTE_B4, NOTE_E5},
  {NOTE_F4, NOTE_A4, NOTE_C4, NOTE_F5},
  {NOTE_FS4, NOTE_AS4, NOTE_CS4, NOTE_FS5},
  {NOTE_G4, NOTE_B4, NOTE_D4, NOTE_G5},
  {NOTE_GS4, NOTE_C4, NOTE_DS4, NOTE_GS5},
  {NOTE_A4, NOTE_CS4, NOTE_E4, NOTE_A5},
  {NOTE_AS4, NOTE_D4, NOTE_F4, NOTE_AS5},
  {NOTE_B4, NOTE_DS4, NOTE_FS4, NOTE_B5}
};


void setup() {
    
  Serial.begin(9600);
  strip.begin();

  // Update LED contents, to start they are all 'off'
  strip.show();
  
  lights[0] = true;
  
  
  // setup sensorLightIndex
  
  int count = 0; 
  for (int i = 0; i < NUM_LIGHTS; i++) {
    //sensorLightIndex[i] = i
  }
}


void loop() {
  // Some example procedures showing how to display to the pixels
  
  //colorWipe(Color(255, 0, 0), 50);
  //colorWipe(Color(0, 255, 0), 50);
  //colorWipe(Color(0, 0, 255), 50);
  //rainbow(20);
  //rainbowCycle(20);
  
  // Read ddr Sensor values
  
  //Serial.print("Sensor Values:  ");
  
  for (int i = 0; i < NUM_DDR_PINS; i++) {
    ddrSensorValues[i] = analogRead(i);
    
    //Serial.print(i);
    //Serial.print(", ");
    //Serial.print(ddrSensorValues[i]);
    //Serial.print("  __  ");
    
  }
  //Serial.println();
  
  for (int i = 0; i < NUM_DDR_PINS; i++) {
    
    if (ddrSensorValues[i] < 500) {
      setColorForLightsAtSensorIndex(i, Color(0, 255,0));
      strip.show();
      
      int currentChord = random(0, 13);  
      play(currentChord, 500);
      
    } else {
      setColorForLightsAtSensorIndex(i, Color(0, 0, 0));
      strip.show();
    }
      
  }
  
  // still need to actually show the lights
  
  //setColorForLightsAtSensorIndex
  
  
  
  /*
  for (int i = 0; i < NUM_LIGHTS; i++) {
    
    strip.setPixelColor(i, Color(0,255,0));
    strip.show();
 
  }

  delay(1000);
  for (int i = 0; i < NUM_LIGHTS; i++) {
    strip.setPixelColor(i, Color(255,0,0));
    strip.show();
   
  }
  delay(1000);
  */
/*
  if (sensorValue < 500) {
    lights[0] = true; 
  }
  else {
    lights[0] = false;
  }
  
  if (lights[0]) {
    strip.setPixelColor(0, Color(0,255,0));
    strip.setPixelColor(1, Color(0,255,0));
     strip.show();
     
    // play sound
    
     int currentChord = random(-1, 13);  
     play(currentChord, 500);
     
  } else {
    
    // turn the note off...
    play(-1, 5);
     strip.setPixelColor(0, Color(0,0,0));
     strip.setPixelColor(1, Color(0,0,0));
      strip.show();
  }
  */
 
  
}


void setColorForLightsAtSensorIndex(int sensorIndex, uint32_t color) {
  strip.setPixelColor(sensorIndex * 2, color);
  strip.setPixelColor(sensorIndex * 2 + 1, color);
}

/* Helper functions */

// Create a 24 bit color value from R,G,B
uint32_t Color(byte r, byte g, byte b)
{
  uint32_t c;
  c = r;
  c <<= 8;
  c |= g;
  c <<= 8;
  c |= b;
  return c;
}


// ***********************************************************
// ARPEGIO FUNCTIONS
// ***********************************************************


void play(int chordIndex, int maxDuration){

  if(chordIndex < 0){
    noTone(speakerPin);
  } else{
    for (int thisNote = 0; thisNote < 4; thisNote++) {
      
      // to calculate the note duration, take one second
      // divided by the note type.
      //e.g. quarter note = 1000 / 4, eighth note = 1000/8, etc.
      int noteDuration = 1000/32;
      tone(speakerPin, chords[chordIndex][thisNote] , noteDuration);
  
      // to distinguish the notes, set a minimum time between them.
      // the note's duration + 30% seems to work well:
      int pauseBetweenNotes = noteDuration * 1.30;
      delay(pauseBetweenNotes);
      // stop the tone playing:
      noTone(speakerPin);
    }
  }
}