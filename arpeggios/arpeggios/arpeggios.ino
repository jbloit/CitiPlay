#include "pitches.h"
  
  
  
int arpeggio1[] = {NOTE_C4, NOTE_E4, NOTE_G4, NOTE_C5};  
int durations1[] = {32,32,32,32};

void setup() {
  // put your setup code here, to run once:
 
}

void loop() {
  // put your main code here, to run repeatedly: 
   playArpeggio();
}

void playArpeggio(){
  for (int thisNote = 0; thisNote < sizeof(arpeggio1)/sizeof(int); thisNote++) {

    // to calculate the note duration, take one second
    // divided by the note type.
    //e.g. quarter note = 1000 / 4, eighth note = 1000/8, etc.
    int noteDuration = 1000/durations1[thisNote];
    tone(8, arpeggio1[thisNote],noteDuration);

    // to distinguish the notes, set a minimum time between them.
    // the note's duration + 30% seems to work well:
    int pauseBetweenNotes = noteDuration * 1.30;
    delay(pauseBetweenNotes);
    // stop the tone playing:
    noTone(8);
  }

}
