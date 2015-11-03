class View {
  // device option screen
  float deviceOptionHeight;
  float deviceOptionTopMargin;
  
  // main screen
  float topPanelHeight, cellHeight, topMargin;
  // control panel
  float speedButtonWidth, bpmDisplayWidth, stateButtonWidth, exportButtonWidth, resetButtonWidth, exitButtonWidth, lengthDisplayWidth, lengthDisplayUnitWidth, lengthDisplayStart;
  
  // left panel
  float trackNumWidth, programScrollWidth, programDisplayWidth, muteWidth, soloWidth, volumeSideWidth, volumeDisplayWidth;
  float programSetWidth, volumeSetWidth;
  float leftPanelWidth;
  
  float trackNumCenter, programScrollLeftCenter, programDisplayCenter, programScrollRightCenter, muteCenter, soloCenter, volumeDisplayCenter;
  float trackNumStart, programScrollLeftStart, programDisplayStart, programScrollRightStart, muteStart, soloStart, volumeSetStart, volumeDisplayStart;
  
  int buttonStrokeWeight, topPannelStrokeWeight;
  float playBarWidth;
  float noteWidth;
  float volumeBarWidth;
  
  color deviceOptionNormal = color(200);
  color deviceOptionHover = color(255, 0, 0);

  color topPanelBackground = color(10);
  
  color darkGrid = color(30);
  color metronomeGrid = color(50, 0, 0, 100);
  
  color normalButton = color(0);
  color selectedButton = color(50);
  color normalText = color(200);
  color selectedText = color(255, 0, 0);
  color cellStroke = color(0);
  
  color normalPlaybar = color(200);
  color recordPlaybar = color(255, 0, 0);
  color removePlaybar = color(255, 0, 0);
  
  color normalNote = color(200);
  color selectedNote = color(255, 0, 0);
  color muteNote = color(100);
  
  color volume = color(200);
  color volumeBackground = color(50);
  
  color controlButtonNormalText = color(200);
  color controlButtonDownText = color(255, 0, 0);
  color controlButtonDownBackground = color(50); 
    
  View(int w, int h) {
    size(w, h);
    smooth();
    
    deviceOptionHeight = 30;
    deviceOptionTopMargin = 40;
       
    topPanelHeight = 30;
    cellHeight = (height - topPanelHeight) / 16.0 ;
    topMargin = cellHeight / 2.0;

    // basic elements
    trackNumWidth = 30;
    programScrollWidth = 18;
    programDisplayWidth = 40;
    muteWidth = 25;
    soloWidth = 25;
    volumeDisplayWidth = 60;
    volumeSideWidth = 10;
    programSetWidth = programDisplayWidth + 2 * programScrollWidth;
    volumeSetWidth = volumeDisplayWidth + 2 * volumeSideWidth;
       
    // calculating coordinates
    trackNumStart = 0;
    programScrollLeftStart = trackNumWidth;
    programDisplayStart = programScrollLeftStart + programScrollWidth;
    programScrollRightStart = programDisplayStart + programDisplayWidth;
    muteStart = programScrollRightStart + programScrollWidth;
    soloStart = muteStart + muteWidth;
    volumeSetStart = soloStart + soloWidth;
    volumeDisplayStart = volumeSetStart + volumeSideWidth;
        
    trackNumCenter = trackNumStart + trackNumWidth / 2;
    programScrollLeftCenter = programScrollLeftStart + programScrollWidth / 2;
    programDisplayCenter = programDisplayStart + programDisplayWidth / 2;
    programScrollRightCenter = programScrollRightStart + programScrollWidth / 2;
    muteCenter = muteStart + muteWidth / 2;
    soloCenter = soloStart + soloWidth / 2;
    volumeDisplayCenter = volumeDisplayStart + volumeDisplayWidth / 2;
    
    leftPanelWidth = soloStart + soloWidth + volumeSetWidth + 10;
    
    // control pannel
    speedButtonWidth = 20;
    bpmDisplayWidth = 40;
    stateButtonWidth = 60;
    exportButtonWidth = 85;
    resetButtonWidth = 85;
    exitButtonWidth = 65;
    lengthDisplayUnitWidth = 60;
    
    // other elements
    buttonStrokeWeight = 3;
    noteWidth = constrain(width / 100, 1, 10);
    playBarWidth = noteWidth;
    volumeBarWidth = 2;
    topPannelStrokeWeight = 3;
    
    PFont font;
    font = loadFont("OCRAExtended-20.vlw");
    textFont(font, 20);
  }

  int getOptionFromY(float y) {
    if (y - deviceOptionTopMargin < 0) {
      return -1;
    }
    return int((y - deviceOptionTopMargin) / deviceOptionHeight);
  }

  int getRowFromY(float y) {
    if (y < topPanelHeight) {
      return -1;
    }
    return int((y - topPanelHeight)  / cellHeight);
  }
  
  int getColFromX(float x) { 
    if (0 < x && x < trackNumWidth) {
      return 0; // track num
    } 

    if (programScrollLeftStart < x && x < programScrollLeftStart + programScrollWidth) {
      return 1; // scroll left
    }
    
    if (programScrollRightStart < x && x < programScrollRightStart + programScrollWidth) {
      return 2; // scroll right   
    }
    
    if (muteStart < x && x < muteStart + muteWidth) {
      return 3; // mute
    }
    
    if (soloStart < x && x < soloStart + soloWidth) {
      return 4; // solo
    }
    
    if (volumeSetStart < x && x < volumeSetStart + volumeSetWidth) {
      return 5; // volume
    }
    
    return -1;
  }
  
  int getControlButton(float x) {
    if (x > 0 && x < speedButtonWidth) {
      return 0; // '-'
    } else if (x > speedButtonWidth + bpmDisplayWidth && x < speedButtonWidth * 2 + bpmDisplayWidth) {
      return 1; // '+'
    } else if (x > speedButtonWidth * 2 + bpmDisplayWidth && x < speedButtonWidth * 2 + bpmDisplayWidth + stateButtonWidth) {
      return 2; // SNAP
    } else if (x > speedButtonWidth * 2 + bpmDisplayWidth + stateButtonWidth && x < speedButtonWidth * 2 + bpmDisplayWidth + stateButtonWidth * 2) {
      return 3; // PLAY
    }else if (x > width - exportButtonWidth - exitButtonWidth - resetButtonWidth && x < width - exitButtonWidth - resetButtonWidth) {
      return 4; // EXPORT
    } else if (x > width - exitButtonWidth - resetButtonWidth && x < width - exitButtonWidth) {
      return 5; // RESET
    } else if (x > width - exitButtonWidth && x < width) {
      return 6; // EXIT
    } else if (x > lengthDisplayStart && x < lengthDisplayStart + lengthDisplayWidth) {
      return 10 + floor((x - lengthDisplayStart) / lengthDisplayUnitWidth); // Loop Length Select    
    }else {
      return -1; // nothing
    }
  }
  
  boolean isInScore(float x, float y) {
    return (y > topPanelHeight && x > leftPanelWidth);
  }
  
  float getPercentInBar(float x) {
    float raw = (x - volumeDisplayStart) / volumeDisplayWidth;
    return constrain(raw, 0, 1); // make sure it's between 0 and 1
  }
  
  String getAlphaNumFromNum(int num) {
    String id = String.valueOf(num);
    if (num > 9) {
      id = Character.toString ((char)(num + 87)); // 10->a, 11->b ...
    }
    
    return id;
  }
 
  void handleFrame() {
    if (model.state == 0) { // splash
      drawSplash();  
    }
    if (model.state == 1) { // need input device id
      drawInputSelect();
    } else if (model.state == 2) { // need output device id
      drawOutputSelect();
    } else if (model.state == 4) { // running, note state 2 is handled in model
      background(0);
      drawGrid();
      drawMetronome();
      displayTrackStatus();
      drawTickPosition();
      drawNotes();     
      drawTopPanel();
      drawBPM();
      drawSnapTo();
      drawPlayState();
      drawRecordState();
      drawDeleteState();
      drawLengthDisplay();
      drawExport();
      drawReset();
      drawExit();
    }
  }
  
  void drawSplash() {
    background(0);
    textAlign(CENTER, CENTER);
    PFont font;
    font = loadFont("OCRAExtended-31.vlw");
    textFont(font, 31);
    text("MidiEvo", width / 2 , height / 2);
    font = loadFont("OCRAExtended-20.vlw");
    textFont(font, 20);
  }
    
  void drawInputSelect() {
    background(0);
    
    ArrayList<String> inputDevices = model.getInputDevices();
    textAlign(LEFT, CENTER);
    fill(deviceOptionNormal);
    text("Select Input Device ", 0 , 15);
    for (int i = 0; i < inputDevices.size(); i++) {
      if (getOptionFromY(mouseY) == i) {
        fill(deviceOptionHover);
      } else {
        fill(deviceOptionNormal);
      }
      text("[" + getAlphaNumFromNum(i) + "] " + inputDevices.get(i), 0 , (i + 0.5) * deviceOptionHeight + deviceOptionTopMargin);
    } 
  }
  
  void drawOutputSelect() {
    background(0);
    fill(deviceOptionNormal);
    
    ArrayList<String> outputDevices = model.getOutputDevices();
    textAlign(LEFT, CENTER);
    fill(deviceOptionNormal);
    text("Select Synthesizer ", 0 , 15);
    for (int i = 0; i < outputDevices.size(); i++) {
      if (getOptionFromY(mouseY) == i) {
        fill(deviceOptionHover);
      } else {
        fill(deviceOptionNormal);
      }
      text("[" + getAlphaNumFromNum(i) + "] " + outputDevices.get(i), 0 , (i + 0.5) * deviceOptionHeight + deviceOptionTopMargin);
    }
  }
  
  void drawTopPanel() {
    rectMode(CORNER);
    fill(topPanelBackground);
    stroke(topPanelBackground);
    strokeWeight(topPannelStrokeWeight);
    rect(0, 0, width, topPanelHeight);
  }
  
  void drawBPM() {    
    textAlign(CENTER, CENTER);
    rectMode(CENTER);
    stroke(cellStroke);
    strokeWeight(buttonStrokeWeight);
    fill(controlButtonNormalText);
    
    int mmBpm = model.getMmBpm();
    String bpmText = Integer.toString(mmBpm);
    while (bpmText.length() < 3) {
      bpmText = "0" + bpmText;
    }
    
    if (getRowFromY(mouseY) == -1 && getControlButton(mouseX) == 0) {
      fill(controlButtonDownText);  // hover or down
    } else {
      fill(controlButtonNormalText); // normal
    }
        
    if (controller.slowingDown) {
      fill(controlButtonDownBackground);
      rect(speedButtonWidth / 2, topPanelHeight / 2, speedButtonWidth, topPanelHeight);
      fill(controlButtonDownText);
    }
        
    text("-", speedButtonWidth / 2, topPanelHeight / 2);
    
    fill(controlButtonNormalText);
    text(bpmText, speedButtonWidth + bpmDisplayWidth / 2, topPanelHeight / 2);
    
    if (getRowFromY(mouseY) == -1 && getControlButton(mouseX) == 1) {
      fill(controlButtonDownText);  // hover or down
    } else {
      fill(controlButtonNormalText); // normal
    }
    
    if (controller.speedingUp) {
      fill(controlButtonDownBackground);
      rect(speedButtonWidth * 1.5 + bpmDisplayWidth, topPanelHeight / 2, speedButtonWidth, topPanelHeight);
      fill(controlButtonDownText);
    }

    text("+", speedButtonWidth * 1.5 + bpmDisplayWidth, topPanelHeight / 2);
  }
  
  void drawSnapTo() {
    textAlign(CENTER, CENTER);
    rectMode(CENTER);
    stroke(cellStroke);
    strokeWeight(buttonStrokeWeight);

    if (getRowFromY(mouseY) == -1 && getControlButton(mouseX) == 2) {
      fill(controlButtonDownText);  // hover or down
    } else {
      fill(controlButtonNormalText); // normal
    }

    if (controller.snappingTo) {
      fill(controlButtonDownBackground);
      rect(speedButtonWidth * 2 + bpmDisplayWidth + stateButtonWidth / 2, topPanelHeight / 2, stateButtonWidth, topPanelHeight);
      fill(controlButtonDownText);
    }
    text("SNAP", speedButtonWidth * 2 + bpmDisplayWidth + stateButtonWidth / 2, topPanelHeight / 2);
  }
  
  void drawPlayState() {
    textAlign(CENTER, CENTER);
    rectMode(CENTER);
    stroke(cellStroke);
    strokeWeight(buttonStrokeWeight);
    
    if (getRowFromY(mouseY) == -1 && getControlButton(mouseX) == 3) {
      fill(controlButtonDownText);  // hover or down
    } else {
      fill(controlButtonNormalText); // normal
    }
    
    if (model.sequencer.isRunning()) {
      fill(controlButtonDownBackground);
      rect(speedButtonWidth * 2 + bpmDisplayWidth + stateButtonWidth * 1.5, topPanelHeight / 2, stateButtonWidth, topPanelHeight);
      fill(controlButtonDownText);
    }
    
    text("PLAY", speedButtonWidth * 2 + bpmDisplayWidth + stateButtonWidth * 1.5, topPanelHeight / 2);
  }
  
  void drawRecordState() {
    textAlign(CENTER, CENTER);
    rectMode(CENTER);
    stroke(cellStroke);
    strokeWeight(buttonStrokeWeight);
    fill(controlButtonNormalText);
    if (model.sequencer.isRecording()) {
      fill(controlButtonDownBackground);
      rect(speedButtonWidth * 2 + bpmDisplayWidth + stateButtonWidth * 2.5, topPanelHeight / 2, stateButtonWidth, topPanelHeight);
      fill(controlButtonDownText);
    }
    text("REC", speedButtonWidth * 2 + bpmDisplayWidth + stateButtonWidth * 2.5, topPanelHeight / 2);
  }
  
  void drawDeleteState() {
    textAlign(CENTER, CENTER);
    rectMode(CENTER);
    stroke(cellStroke);
    strokeWeight(buttonStrokeWeight);
    fill(controlButtonNormalText);
    if (controller.removing) {
      fill(controlButtonDownBackground);
      rect(speedButtonWidth * 2 + bpmDisplayWidth + stateButtonWidth * 3.5, topPanelHeight / 2, stateButtonWidth, topPanelHeight);
      fill(controlButtonDownText);
    }
    text("DEL", speedButtonWidth * 2 + bpmDisplayWidth + stateButtonWidth * 3.5, topPanelHeight / 2);
  }
  
  void drawLengthDisplay() {
    ArrayList<Integer> loopLengths = new ArrayList<Integer>();  
    for (int l = model.minLoopLength; l <= model.maxLoopLength; l *= 2) {
      loopLengths.add(int(l / model.metronomeGap));
    }
    
    lengthDisplayWidth = lengthDisplayUnitWidth * loopLengths.size();
    lengthDisplayStart = width / 2 - lengthDisplayWidth / 2;
    
    textAlign(CENTER, CENTER);
    rectMode(CENTER);
    noStroke();
    strokeWeight(buttonStrokeWeight);
    
    for (int i = 0; i < loopLengths.size(); i++) {
      
      if (model.loopLength / model.metronomeGap == loopLengths.get(i)) {
        fill(controlButtonDownBackground);
        rect(lengthDisplayStart + lengthDisplayUnitWidth * (i + 0.5), topPanelHeight / 2, lengthDisplayUnitWidth, topPanelHeight * 0.8);
        fill(controlButtonDownText);
        text(loopLengths.get(i), lengthDisplayStart + lengthDisplayUnitWidth * (i + 0.5), topPanelHeight / 2);
      } else {
        noFill();
        rect(lengthDisplayStart + lengthDisplayUnitWidth * (i + 0.5), topPanelHeight / 2, lengthDisplayUnitWidth, topPanelHeight * 0.8);
        
        if (getRowFromY(mouseY) == -1 && getControlButton(mouseX) == 10 + i) {
          fill(controlButtonDownText);  // hover or down
        } else {
          fill(controlButtonNormalText); // normal
        }
           
        text(loopLengths.get(i), lengthDisplayStart + lengthDisplayUnitWidth * (i + 0.5), topPanelHeight / 2);
      }
    }
  }
  
  void drawExport() {
    textAlign(CENTER, CENTER);
    rectMode(CENTER);
    stroke(cellStroke);
    strokeWeight(buttonStrokeWeight);  
    
    if (getRowFromY(mouseY) == -1 && getControlButton(mouseX) == 4) {
      fill(controlButtonDownText);  // hover or down
    } else {
      fill(controlButtonNormalText); // normal
    }
    
    if (controller.exporting) {
      fill(controlButtonDownBackground);
      rect(width - exportButtonWidth / 2 - exitButtonWidth - resetButtonWidth, topPanelHeight / 2, exportButtonWidth, topPanelHeight);
      fill(controlButtonDownText);
    }

    text("EXPORT", width - exportButtonWidth / 2 - exitButtonWidth - resetButtonWidth, topPanelHeight / 2);
  }
  
  void drawReset() {
    textAlign(CENTER, CENTER);
    rectMode(CENTER);
    stroke(cellStroke);
    strokeWeight(buttonStrokeWeight);  
    
    if (getRowFromY(mouseY) == -1 && getControlButton(mouseX) == 5) {
      fill(controlButtonDownText);  // hover or down
    } else {
      fill(controlButtonNormalText); // normal
    }
            
    if (controller.resetting) {
      fill(controlButtonDownBackground);
      rect(width - resetButtonWidth / 2 - exitButtonWidth, topPanelHeight / 2, resetButtonWidth, topPanelHeight);
      fill(controlButtonDownText);
    }

    text("RESET", width - resetButtonWidth / 2 - exitButtonWidth, topPanelHeight / 2);   
  }
  
  void drawExit() {
    textAlign(CENTER, CENTER);
    rectMode(CENTER);
    stroke(cellStroke);
    strokeWeight(buttonStrokeWeight);  

    if (controller.exiting) {
      fill(controlButtonDownBackground);
      rect(width - exitButtonWidth / 2, topPanelHeight / 2, exitButtonWidth, topPanelHeight);
      fill(controlButtonDownText);
    }
    
    if (getRowFromY(mouseY) == -1 && getControlButton(mouseX) == 6) {
      fill(controlButtonDownText);  // hover or down
    } else {
      fill(controlButtonNormalText); // normal
    }
    
    text("EXIT", width - exitButtonWidth / 2, topPanelHeight / 2); 
  }
  
  void drawGrid() {
    int gridNum = int(model.loopLength / model.metronomeGap);
    rectMode(CORNER);
    fill(darkGrid);
    noStroke();
    Track[] tracks = model.seq.getTracks();
    for (int i = 0; i < gridNum; i+=2) {

      float x = map(i, 0, gridNum, leftPanelWidth, width);
      rect(x, topPanelHeight, (width - leftPanelWidth) / gridNum, height - topPanelHeight);
    }
  }
  
  void drawMetronome() {
    rectMode(CORNER);
    fill(metronomeGrid);
    int gridNum = int(model.loopLength / model.metronomeGap);
    if (model.isMetronomeOn()) {
      int currentBand = int(map(model.sequencer.getTickPosition(), 0, model.loopLength, 0, gridNum));
      if (currentBand % 2 == 1) {
        for (int i = 0; i < gridNum; i+=2) {
          float x = map(i, 0, gridNum, leftPanelWidth, width);
          rect(x, topPanelHeight, (width - leftPanelWidth) / gridNum, height - topPanelHeight);
        }
      }
    }  
  }
  
  void displayTrackStatus() {
    Track[] tracks = model.seq.getTracks();
          
    for (int i = 0; i < tracks.length; i++) {
      textAlign(CENTER, CENTER);
      rectMode(CENTER);
      stroke(cellStroke);
      strokeWeight(buttonStrokeWeight);
      
      drawTrackNumber(i);
      drawInstrumentSet(i);
      drawMute(i);
      drawSolo(i);
      drawVolume(i);
    }
  }
  
  void drawTrackNumber(int track) {
    String trackNum = "" + (track + 1);
    if (trackNum.length() < 2) {
      trackNum = "0" + trackNum;
    }
    if (controller.selectedChannel == track) {
      fill(selectedButton);
      rect(trackNumCenter, topPanelHeight + cellHeight * track + topMargin, trackNumWidth, cellHeight);
      fill(selectedText);
      text(trackNum, trackNumCenter, topPanelHeight + cellHeight * track + topMargin);
    } else {
      if (getRowFromY(mouseY) == track && getColFromX(mouseX) == 0) {
        fill(selectedText);  // hover or down
      } else {
        fill(normalText); // normal
      }
      text(trackNum, trackNumCenter, topPanelHeight + cellHeight * track + topMargin);
    }
  }
  
  void drawInstrumentSet(int track) {
    String instrumentNum = "" + model.getInstrument(track);
    while (instrumentNum.length() < 3) {
       instrumentNum = "0" + instrumentNum;
    }
    if (getRowFromY(mouseY) == track && getColFromX(mouseX) == 1) {
      fill(selectedText);  // hover or down
    } else {
      fill(normalText); // normal
    }
    
    if (controller.leftScrolling && controller.scrollingTrackNum == track) {
      fill(controlButtonDownBackground);
      rect(programScrollLeftCenter, topPanelHeight + cellHeight * track + topMargin, programScrollWidth, cellHeight);
      fill(selectedText);
    }
    text("<", programScrollLeftCenter, topPanelHeight + cellHeight * track + topMargin);
    fill(normalText);
    text(instrumentNum, programDisplayCenter, topPanelHeight + cellHeight * track + topMargin);
    
    if (getRowFromY(mouseY) == track && getColFromX(mouseX) == 2) {
      fill(selectedText);  // hover or down
    } else {
      fill(normalText); // normal
    }
    
    if (controller.rightScrolling && controller.scrollingTrackNum == track) {
      fill(controlButtonDownBackground);
      rect(programScrollRightCenter, topPanelHeight + cellHeight * track + topMargin, programScrollWidth, cellHeight);
      fill(selectedText);
    }
    text(">", programScrollRightCenter, topPanelHeight + cellHeight * track + topMargin);
  }
  
  void drawMute(int track) {
    if (model.sequencer.getTrackMute(track)) {
      fill(selectedButton);
      rect(muteCenter, topPanelHeight + cellHeight * track + topMargin, muteWidth, cellHeight);
      fill(selectedText);
      text("M", muteCenter + 2, topPanelHeight + cellHeight * track + topMargin);
    } else {        
      if (getRowFromY(mouseY) == track && getColFromX(mouseX) == 3) {
        fill(selectedText);  // hover or down
      } else {
        fill(normalText); // normal
      }
      text("M", muteCenter + 2, topPanelHeight + cellHeight * track + topMargin);        
    }
  }

  void drawSolo(int track) {
    if (model.sequencer.getTrackSolo(track)) {
      fill(selectedButton);
      rect(soloCenter, topPanelHeight + cellHeight * track + topMargin, soloWidth, cellHeight);
      
      fill(selectedText); 
      text("S", soloCenter, topPanelHeight + cellHeight * track + topMargin);  
    } else {
       if (getRowFromY(mouseY) == track && getColFromX(mouseX) == 4) {
        fill(selectedText);  // hover or down
      } else {
        fill(normalText); // normal
      }
      text("S", soloCenter, topPanelHeight + cellHeight * track + topMargin);   
    }
  }
  
  void drawVolume(int track) {
    int level = model.getVolume(track); 
    fill(volume);
    for(int j = 0; j < 10; j+=1) {
      strokeWeight(volumeBarWidth);
      int volX = 0;
      while (volX < volumeDisplayWidth) {
        if(volX < volumeDisplayWidth * level / 127) {
          if (getRowFromY(mouseY) == track && getColFromX(mouseX) == 5 || controller.scrollingVolumeDelayCounter > 0 && controller.selectedChannel == track) {
            stroke(selectedText);  // hover or down
          } else {
            stroke(volume); // normal
          }
        } else {
          stroke(volumeBackground);
        }
       
        line(volumeDisplayStart + volX, topPanelHeight + cellHeight * track + cellHeight / 3.2, volumeDisplayStart + volX, topPanelHeight + cellHeight * (track + 1) - cellHeight / 3.2);
        volX += 4;          
      }
    }
  }

  
  void drawTickPosition() {
    long totalTickLength = model.loopLength;
    long currentTickPosition;
    if (controller.snappingTo) {
      currentTickPosition = model.getSnapToTickPositionFloor();
    } else {
      currentTickPosition = model.sequencer.getTickPosition();
    }
    float x = map(currentTickPosition, 0, totalTickLength, leftPanelWidth, width);
    
    
    stroke(normalPlaybar);
    if (model.sequencer.isRecording()) {
      stroke(recordPlaybar);
    }
    strokeWeight(playBarWidth);
    line(x, topPanelHeight, x, height);
    
    if (controller.removing) {
      long removeTickPosition;
      if (controller.snappingTo) {
        removeTickPosition = model.snapToRemoveTickPosition();
      } else {
        removeTickPosition = model.removeTickPosition();
      }
      stroke(removePlaybar);
       x = map(removeTickPosition, 0, totalTickLength, leftPanelWidth, width);
       line(x, topPanelHeight, x, height);
    }
  }
  
  void drawNotes() {
    rectMode(CENTER);
    noStroke();
    
    long totalTickLength = model.loopLength;
    Track[] tracks = model.seq.getTracks();
    for (int i = 0; i < tracks.length; i++) {
      fill(normalNote);
      if (model.sequencer.getTrackMute(i) && !model.sequencer.getTrackSolo(i)) {
        fill(muteNote); 
      } else if (controller.selectedChannel == i) {
        fill(selectedNote);  
      }
      
      int length = tracks[i].size();
      for (int j = 0; j < length; j++) {
        MidiEvent event = tracks[i].get(j);
        MidiMessage msg = event.getMessage();
        int status = msg.getStatus();
        if (status >= ShortMessage.NOTE_ON && status < ShortMessage.NOTE_ON + 16) {
          long eventTickPosition = event.getTick();
          byte[] data = msg.getMessage();
          int velocity = data[2];
          int pitch = data[1];
          float noteHeight = map(velocity, 0, 127, 0, cellHeight * 0.9);
          float x = map(eventTickPosition, 0, totalTickLength, leftPanelWidth, width);
          float y = topPanelHeight + cellHeight * i + topMargin;
          rect(x, y, noteWidth, noteHeight);
        }
      }
    }    
  }
}
