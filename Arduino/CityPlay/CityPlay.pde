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

// GAME VARS

typedef enum GameMode {
  GameModeNone = 0,
  GameModeTouchReact,
  GameModeWhacamole,
  GameModeCycleColors,
  GameModeSkipScotch
} GameMode;

GameMode currGameMode = GameModeWhacamole;


// LIGHT VARS

#define NUM_LIGHTS 18

int dataPin  = 2;    // Yellow wire on Adafruit Pixels
int clockPin = 3;    // Green wire on Adafruit Pixels
boolean lights[NUM_LIGHTS]; 

int sensorLightIndex[NUM_LIGHTS];

// Set the first variable to the NUMBER of pixels. 25 = 25 pixels in a row
Adafruit_WS2801 strip = Adafruit_WS2801(NUM_LIGHTS, dataPin, clockPin);



// SENSOR VARS

#define SENSOR_EVENT_THRESHOLD 4

#define NUM_DDR_PINS 8

int ddrSensorValues[NUM_DDR_PINS];
int numConsecutiveSensorEvents[NUM_DDR_PINS];


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

  
  // Read ddr Sensor values
  
  Serial.print("Sensors Values:  ");
  
  for (int i = 0; i < NUM_DDR_PINS; i++) {
    ddrSensorValues[i] = analogRead(i);
    
    Serial.print(i);
    Serial.print(", ");
    Serial.print(ddrSensorValues[i]);
    Serial.print("  __  ");
    
  }
  Serial.println();
  
  switch(currGameMode) {
     case GameModeTouchReact:
     playGameModeTouchReact();
     break;
     case GameModeWhacamole:
     playGameModeWhacamole();
     break;
     case GameModeCycleColors:
     playGameModeCycleColors();
     default:
     break;
  }
}

// ***********************************************************
// GAMEPLAY FUNCTIONS
// ***********************************************************

int currMoleIndex = 0;

void playGameModeWhacamole() {
    
    if (didSensorEventOccur(currMoleIndex)) {
        int currentChord = random(0, 13);  
        play(currentChord, 500);
        currMoleIndex = generateNextMoleIndex(currMoleIndex);
    } else {
        uint32_t sensorColor = defaultColorForSensorIndex(currMoleIndex);
        int lightIndex = lightIndexForSensorIndex(currMoleIndex);
        setColorOnlyForLightsAtSensorIndex(lightIndex, sensorColor);
        strip.show();
    }
}

int generateNextMoleIndex(int lastIndex) {
    int nextIndex = 0;
    int incrementAmount = random(1, 4);
    
    int polarityValue = random(1,100);
    if (polarityValue > 50) {
        incrementAmount *= -1;
    }
    
    nextIndex = lastIndex + incrementAmount;
    
    // make sure we are not out of bounds
    if (nextIndex < 0 || nextIndex > NUM_DDR_PINS) {
        nextIndex = lastIndex - incrementAmount;
    } 
    
    return nextIndex;
}


void playGameModeTouchReact() {
  
  for (int i = 0; i < NUM_DDR_PINS; i++) {
    
    
    if (didSensorEventOccur(i)) {
      numConsecutiveSensorEvents[i]++;
    } else {
      numConsecutiveSensorEvents[i] = 0;
    }
    
    int lightIndex = lightIndexForSensorIndex(i);
    
    if (numConsecutiveSensorEvents[i] >= SENSOR_EVENT_THRESHOLD) {
      
      int rand = random(0, 5);
      
      uint32_t color;
      
      switch (rand) {
        case 0:
        color = Color(255, 0, 0);
        break;
        case 1:
        color = Color(0, 255, 0);
        break;
        case 2:
        color = Color(0, 0, 255);
        break;
        case 3:
        color = Color(255, 255, 0);
        break;
        case 4:
        color = Color(0, 255, 255);
        break;
        case 5:
        color = Color(255, 0, 255);
        break;
      }
      setColorForLightsAtSensorIndex(lightIndex, color);
      strip.show();
      
      int currentChord = random(0, 13);  
      play(currentChord, 500);
      
    } else {
      setColorForLightsAtSensorIndex(lightIndex, Color(0, 0, 0));
      strip.show();
    }
  }
}

void playGameModeCycleColors() {
    for (int i = 0; i < NUM_DDR_PINS; i++) {
         setColorForLightsAtSensorIndex(i, defaultColorForSensorIndex(i));
         uint32_t noColor = Color(0,0,0);
         
         for (int j = 0; j < NUM_DDR_PINS; j++) {
             if (i != j) {
                 setColorForLightsAtSensorIndex(j, noColor);
             }
         }         
         strip.show();
         delay(100);
    }
    //defaultColorForSensorIndex
}


// ***********************************************************
// SENSOR FUNCTIONS
// ***********************************************************

int lightIndexForSensorIndex(int sensorIndex) {
  int lightIndex;
  switch (sensorIndex) {
    case 0:
    case 1:
    case 2:
    case 3:
    case 7:
    case 8:
      lightIndex = sensorIndex;
      break;
    case 4:
      lightIndex = 6;
      break;
    case 5:
      lightIndex = 4;
      break;
    case 6:
      lightIndex = 5;
      break;
    default:
      lightIndex = sensorIndex;
      break;
  }
  return lightIndex;
}

boolean didSensorEventOccur(int sensorIndex) {
  boolean sensorEvent = false;
  if (sensorIndex == 8) {
    sensorEvent = ddrSensorValues[sensorIndex] < 100;
  } else {
    sensorEvent = ddrSensorValues[sensorIndex] < 500;
  }
  return sensorEvent;
}


// ***********************************************************
// COLOR FUNCTIONS
// ***********************************************************

void setColorForLightsAtSensorIndex(int sensorIndex, uint32_t color) {
  strip.setPixelColor(sensorIndex * 2, color);
  strip.setPixelColor(sensorIndex * 2 + 1, color);
}

void setColorOnlyForLightsAtSensorIndex(int sensorIndex, uint32_t color) {
    uint32_t noColor = Color(0,0,0);
    for (int i = 0; i < NUM_DDR_PINS; i++) {
        if (i == sensorIndex) {
            setColorForLightsAtSensorIndex(i, color);
        } else {
            setColorForLightsAtSensorIndex(i, noColor);
        }
    }
    strip.show();
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

uint32_t defaultColorForSensorIndex(int sensorIndex) {
    uint32_t color;
    switch(sensorIndex) {
        case 0:
        color = Color(255, 0, 0);
        break;
        case 1:
        color = Color(0, 255, 0);
        break;
        case 2:
        color = Color(0, 0, 255);
        break;
        case 3:
        color = Color(255, 255, 0);
        break;
        case 4:
        color = Color(0, 255, 255);
        break;
        case 5:
        color = Color(255, 0, 255);
        break;
        case 6:
        color = Color(51,255,204);
        break;
        case 7:
        color = Color(51,255,102);
        break;
        case 8:
        color = Color(204,255,51);
        break;        
    }
    return color;
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