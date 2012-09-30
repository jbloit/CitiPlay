#include "pitches.h"

//int chord[4] = {NOTE_C4, NOTE_E4, NOTE_G4, NOTE_C5};
//
//int sounds[3][4];
//

//sounds[0] = {{NOTE_C4, NOTE_E4, NOTE_G4, NOTE_C5}};



int chords [3] [4] = {
  {NOTE_C4, NOTE_E4, NOTE_G4, NOTE_C5},
  {NOTE_D4, NOTE_FS4, NOTE_A4, NOTE_D5},
  {NOTE_E4, NOTE_GS4, NOTE_B4, NOTE_E5}
};



//
//struct arpeggio {
//  int pitch[4]; 
//};
//
//// the oscillators (8 of them)
//struct arpeggio sounds[3];
//sounds[0].pitch = {{NOTE_C4}, {NOTE_E4}, {NOTE_G4}, {NOTE_C5}};
//sounds[0].duration = {32,32,32,32};
//
//sounds[1].pitch = {NOTE_D4, NOTE_FS4, NOTE_A4, NOTE_D5};
//sounds[1].duration = {32,32,32,32};
//
//sounds[2].pitch = {NOTE_E4, NOTE_GS4, NOTE_B4, NOTE_E5};
//sounds[2].duration = {32,32,32,32};
 
//int arpeggio1[] = {NOTE_C4, NOTE_E4, NOTE_G4, NOTE_C5};  
//int durations1[] = {32,32,32,32};

int stepPeriod = 1000;

long dt = 0;
long lastTime = 0;
long accumDt = 0;

int currentChord = 0;

void setup() {
  Serial.begin(9600);
  // put your setup code here, to run once:
  Serial.println("setting up");
}

void loop() {
  
  long curTime = millis();
  dt = curTime - lastTime;
  lastTime = curTime;
  accumDt += dt;
  
  if (accumDt > stepPeriod){
      currentChord = random(0, 3);
      Serial.println(currentChord);
      accumDt = 0;
  }
  
  
  
  // put your main code here, to run repeatedly: 
   play(currentChord, 500);
}

void play(int chordIndex, int maxDuration){

  for (int thisNote = 0; thisNote < 4; thisNote++) {
    
    // to calculate the note duration, take one second
    // divided by the note type.
    //e.g. quarter note = 1000 / 4, eighth note = 1000/8, etc.
    int noteDuration = 1000/32;
    tone(8, chords[chordIndex][thisNote] , noteDuration);

    // to distinguish the notes, set a minimum time between them.
    // the note's duration + 30% seems to work well:
    int pauseBetweenNotes = noteDuration * 1.30;
    delay(pauseBetweenNotes);
    // stop the tone playing:
    noTone(8);
  }

}
