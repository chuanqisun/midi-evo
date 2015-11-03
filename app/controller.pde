class Controller{
  long previousRemoveTickPosition;
  int selectedChannel;
  // controller states
  boolean removing;
  boolean snappingTo;
  boolean leftPressed, rightPressed;
  boolean speedingUp, slowingDown; // tempo change
  boolean exporting, resetting, exiting;
  boolean leftScrolling, rightScrolling; // scroll to previous or next instrument
  int longPressCounter; // has value 0 when left mouse button is long pressed
  int longPressThreshold = int(frameRate);
  int scrollingTrackNum; // which track is volume adjustment applying to
  int scrollingVolumeDelayThreshold = int(frameRate/2); // 0.5 second 
  int scrollingVolumeDelayCounter; // has value 0 when continous scroll starts
  int keyboardVolumeStepSize = 3;
  
  Controller(){
    init();
  }
  
  void init() {
    selectedChannel = 0; // default first channel
    removing = false;
    snappingTo = false;
    leftPressed = false;
    rightPressed = false;
    speedingUp = false;
    slowingDown = false;
    exporting = false;
    resetting = false;
    exiting = false;
    leftScrolling = false;
    rightScrolling = false;
    longPressCounter = longPressThreshold; // 1 second
    scrollingVolumeDelayCounter = 0;
    previousRemoveTickPosition = -1;
  }
  
  int getNumFromAlphaNum(char alphaNum) {
    if (key >= '0' && key <= '9') {
      return Character.getNumericValue(key);
    } else if (key >= 'a' && key <= 'z') {
      return key - 87; // a->10, b->11 ...
    } else {
      return -1;
    }
  }
  
  void handleKeyPressed() {
    if (key == ESC) {
      safeExit();
    }
    
    if (model.state == 1) { // selecting device
      int deviceCount = model.getInputDeviceCount();
      model.inputDevice = getNumFromAlphaNum(key);
      
      if (model.inputDevice < deviceCount && model.inputDevice >= 0) {
        model.state = 2; 
      }      
      return;
    }
    
    if (model.state == 2) { // selecting device
      int deviceCount = model.getOutputDeviceCount();
      model.outputDevice = getNumFromAlphaNum(key);
      
      if (model.outputDevice < deviceCount && model.outputDevice >= 0) {
        model.state = 3; 
      }      
      return;
    }
    
    if (model.state == 3) {
      return; // model will handle this state
    }
    
    // state == 4
    if (key >= '1' && key <= '9') {
      selectChannel(Character.getNumericValue(key) - 1);
    }
        
    if (key == '0') {
      selectChannel(9);
    }
    
    if (key == 'M') {
      model.sequencer.setTrackMute(15, !model.sequencer.getTrackMute(15));
    }
    
    if (key == 'm') {
      model.sequencer.setTrackMute(selectedChannel, !model.sequencer.getTrackMute(selectedChannel));
    }
    
    if (key == 's') {
      model.sequencer.setTrackSolo(selectedChannel, !model.sequencer.getTrackSolo(selectedChannel));
    }
    
    if (key == 'S') {
      toggleSnapTo();
    }
    
    if (key == 'R') {
      model.reset(); 
      reset();
      resetting = true;
    }
    
    if (key == 'E') {
      if(!exporting) {
        model.exportToFile();
        exporting = true;
      }
    }
        
    if (keyCode == 155) { // INSERT
      model.startRecording();
    }
    
    if (keyCode == UP) {
      selectedChannel = (selectedChannel -1 + 16) % 16;
    }
    
    if (keyCode == DOWN) {
      selectedChannel = (selectedChannel + 1) % 16;
    }
    
    if (keyCode == LEFT) {
      model.usePreviousInstrument(selectedChannel);
      leftScrolling = true;
      scrollingTrackNum = selectedChannel;
    }
    
    if (keyCode == RIGHT) {
      model.useNextInstrument(selectedChannel);
      rightScrolling = true;
      scrollingTrackNum = selectedChannel;
    }  
    
    if (key == '=') {
      model.speedUp(); 
      speedingUp = true;
    }
    
    if (key == '-') {
      model.slowDown();
      slowingDown = true;
    }
    
    if (key == '>') {
      model.expandTrack();
    }
    
    if (key == '<') {
      model.shrinkTrack();
    }
    
    if (key == ',') {
      int newVolume = constrain(model.getVolume(selectedChannel) - keyboardVolumeStepSize, 0, 127);
      scrollingVolumeDelayCounter = scrollingVolumeDelayThreshold;
      model.setVolume(selectedChannel, newVolume);
    }
    
    if (key == '.') {
      int newVolume = constrain(model.getVolume(selectedChannel) + keyboardVolumeStepSize, 0, 127);
      scrollingVolumeDelayCounter = scrollingVolumeDelayThreshold;
      model.setVolume(selectedChannel, newVolume);
    }
    
    if (key == ENTER) {
      model.togglePlay(); 
    }
    
    if (key == BACKSPACE) {
      model.rewind(0); 
    }
    
    if (key == DELETE) {
      removeNote();
    }
    
    if (key  == ' ') { 
      model.startRecording();
      removeNote();
    }
  }
  
  void handleKeyReleased() {
    if (model.state < 4)
      return;
      
    if (keyCode == 155) { // INSERT
      model.stopRecording();
    }  
    
    if (key == DELETE) {
      stopRemoveNote();
    }
    
    if (keyCode == LEFT) {
      leftScrolling = false;
    }
  
    if (keyCode == RIGHT) {
      rightScrolling = false;
    }
    
    if (key == 'E') {
      exporting = false;
    }
      
    if (key == 'R') {
      resetting = false;
    }
    
    if (key  == ' ') { 
      model.stopRecording();
      stopRemoveNote();
    }  
    
    if (key == '=') { 
      speedingUp = false;
    }
    
    if (key == '-') {
      slowingDown = false;
    }  
  }
  
  void handleMouseWheel(MouseEvent event) {
    int step = int(event.getCount());
    int newVolume = constrain(model.getVolume(selectedChannel) - step, 0, 127);
    scrollingVolumeDelayCounter = scrollingVolumeDelayThreshold;
    model.setVolume(selectedChannel, newVolume);
  }
  
  void handleMousePressed() {
    if (model.state == 1 && mouseButton == LEFT) {
        int option = view.getOptionFromY(mouseY); 
        if (option >= 0 && option < model.getInputDeviceCount()) {
          model.inputDevice = option;
          model.state = 2;
        }
    } else if (model.state == 2 && mouseButton == LEFT) {
        int option = view.getOptionFromY(mouseY); 
        if (option >= 0 && option < model.getOutputDeviceCount()) {
          model.outputDevice = option;
          model.state = 3;
        }
    } else if (model.state == 4) {
      if (mouseButton == LEFT) {
        leftPressed = true;
        mouseClick(mouseX, mouseY);
      }
      
      if (mouseButton == RIGHT) {
        rightPressed = true;
      }   
    }
  }
  
  void handleMouseReleased() {
    if (model.state < 4)
      return;
      
    if (mouseButton == LEFT) {
      model.stopRecording();
      leftPressed = false;
      speedingUp = false;
      slowingDown = false;
      exporting = false; 
      resetting = false;
      leftScrolling = false;
      rightScrolling = false;
      longPressCounter = longPressThreshold;
    }
    
    if (mouseButton == RIGHT) {
      stopRemoveNote();
      rightPressed = false;
    }  
  }
  
  void selectChannel(int channel) {
    selectedChannel = channel;
    println("[controller] channel " + channel + " selected");
  }
  
  void toggleSnapTo() {
    snappingTo = !snappingTo;
  }
    
  void noteOn(Note note) {
    ShortMessage myMsg = new ShortMessage();
    try{
      myMsg.setMessage(ShortMessage.NOTE_ON, selectedChannel, note.pitch(), note.velocity());
    } catch (Exception e){}
    
    long timestamp = model.sequencer.getMicrosecondPosition();
    if (snappingTo) {      
      timestamp = model.getSnapToMicrosecondPosition();
    }
    
    model.seqRcvr.send(myMsg, timestamp);
    if (!model.sequencer.getTrackMute(selectedChannel)) {
      model.synthRcvr.send(myMsg, timestamp);
    }
  }
  
  void noteOff(Note note) {
    ShortMessage myMsg = new ShortMessage();
    try{
      myMsg.setMessage(ShortMessage.NOTE_OFF, selectedChannel, note.pitch(), note.velocity());
    } catch (Exception e){}
    
    long timestamp = model.sequencer.getMicrosecondPosition();
    if (snappingTo) {      
      timestamp = model.getSnapToMicrosecondPosition();
    }
    
    model.seqRcvr.send(myMsg, timestamp);
    model.synthRcvr.send(myMsg, timestamp);
  }
  
  void removeNote() {
    removing = true; 
    long currentTickPosition;
    if (snappingTo) {
      currentTickPosition = model.getSnapToTickPositionRound();
    } else {
      currentTickPosition = model.sequencer.getTickPosition();
    }
    
    if(previousRemoveTickPosition < 0) {
      previousRemoveTickPosition = currentTickPosition;
      model.removeNote(selectedChannel, (currentTickPosition + model.removeTolerance) % model.loopLength, currentTickPosition);
      previousRemoveTickPosition = currentTickPosition;
    } else {
      model.removeNote(selectedChannel, (currentTickPosition + model.removeTolerance) % model.loopLength, previousRemoveTickPosition);
      previousRemoveTickPosition = currentTickPosition;
    }
  }
  
  void stopRemoveNote() {
    removing = false;
    previousRemoveTickPosition = -1; 
  }
  
  void handleFrame() {
    if (model.state < 4)
      return;
      
    if (leftPressed) {
      if (view.isInScore(mouseX, mouseY)) {
        model.startRecording();
      }
      handleDrag(mouseX, mouseY);
    } 
   
    if (rightPressed) {
      if (view.isInScore(mouseX, mouseY)) {
        removeNote();
      }
    }
    
    if (scrollingVolumeDelayCounter > 0) {
      scrollingVolumeDelayCounter--;
    }
  }
  
  void mouseClick(float x, float y) {
    int col = view.getColFromX(x);
    int row = view.getRowFromY(y);
    
    if (row < 0) { // control buttons
      int control = view.getControlButton(x);
      if (control == 2) { // SNAP
        toggleSnapTo();
      } else if (control == 3) { // PLAY
        model.togglePlay();
      } else if (control == 4) { // EXPORT
        exporting = true; 
        model.exportToFile();
      } else if (control == 5) { // RESET
        model.reset();
        reset();
        resetting = true;
      } else if (control == 6) { // EXIT
        exiting = true;
        safeExit();
      } else if (control >= 10) { // loop lengths
        
        ArrayList<Integer> loopLengths = new ArrayList<Integer>();  
        for (int l = model.minLoopLength; l <= model.maxLoopLength; l *= 2) {
          loopLengths.add(int(l / model.metronomeGap));
        } 
        model.setLoopLength(loopLengths.get(control - 10) * model.metronomeGap);
      }
    } else {
      if (col == 0) { // select track
        selectedChannel = row;
      }  
      
      if (col == 3) { // mute
        model.sequencer.setTrackMute(row, !model.sequencer.getTrackMute(row));
      }
      
      if (col == 4) { // solo
        model.sequencer.setTrackSolo(row, !model.sequencer.getTrackSolo(row));
      }
    }
  }
  
  void handleDrag(float x, float y) {
    if (longPressCounter > 0) {
      longPressCounter--;
    }
    
    int col = view.getColFromX(x);
    int row = view.getRowFromY(y);
    
    if (row < 0) { // global controls
      int control = view.getControlButton(x);
      if (control == 0) { // tempo change
        if (!slowingDown || longPressCounter == 0) {
          slowingDown = true;
          model.slowDown();
        }
      } else if (control == 1) {
        if (!speedingUp || longPressCounter == 0) {
          speedingUp = true;
          model.speedUp();
        }
      }        
    } else { // track controls
      if (col == 1) { // previous instrument
        if (!leftScrolling || longPressCounter == 0) {
          leftScrolling = true;
          scrollingTrackNum = row;
          model.usePreviousInstrument(row);
        }
      } else if (col == 2) { // next instrument
        if (!rightScrolling || longPressCounter == 0) {
          rightScrolling = true;
          scrollingTrackNum = row;
          model.useNextInstrument(row);
        }        
      }else if (col == 5) { // volume
        float percent = view.getPercentInBar(x);
        int vol = round(map(percent, 0, 1, 0 ,127));
        model.setVolume(row, vol);
      }
    }
  }
  
  void reset() {
    init();
     
    // unmute and unsolo all channels
    for (int i = 0; i < 16; i++) {
      model.sequencer.setTrackMute(i, false);  
      model.sequencer.setTrackSolo(i, false);  
    }    
  }
  
  void safeExit() {
    if (model.state == 4) {
      model.reset();
      reset();
    }
    exit();
  }
}
