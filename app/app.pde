//
//                         MidiEvo
//
//                      by Chuanqi Sun
//
//
// A midi sequencer inspired by MuLab (by MuTools) and GarageBand. 
// Instead of providing a comprehensive music composition environment
// as MuLab and GarageBand do, MidiEvo adopts a minimalistic design to
// help musician improvise live music with a midi keyboard and a laptop.
//
// MidiEvo loops over a sequence indefinitely as the musician develops
// music on multiple tracks.
//
// Quick Start
// please refer to User_Manual.pdf
//
// You must have a usb mini keyboard to interact with this program
// 
// Windows users may need third party synthesizer to minize latency
// Please refer to: http://haskell.cs.yale.edu/euterpea/midi-on-windows/#latency
//
import themidibus.*;
import javax.sound.midi.*; 
import java.text.SimpleDateFormat;
import java.util.Date;

Model model;
Controller controller;
View view;

void setup() {
  model = new Model(this);
  
  controller = new Controller();
  
  // full screen used for presentation export
  //view = new View(displayWidth, displayHeight); 
  
  // window mode used for debugging in processing
  view = new View(1200, 600);  
}

void draw() {
  view.handleFrame();
  controller.handleFrame();
  model.handleFrame();
}

// global event handlers
void noteOn(Note note) {
  controller.noteOn(note);
}

void noteOff(Note note) {
  controller.noteOff(note);
}

void mouseWheel(MouseEvent event) {
  controller.handleMouseWheel(event);
}

void keyPressed() {
  controller.handleKeyPressed();  
}

void keyReleased() {
  controller.handleKeyReleased();
}

void mousePressed() {
  controller.handleMousePressed();
}

void mouseReleased() {
  controller.handleMouseReleased();
}

