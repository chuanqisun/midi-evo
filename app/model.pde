class Model{
  PApplet app;
  int state;
  int inputDevice, outputDevice, deviceCount;
  
  MidiBus myBus;
  MidiDevice synth;
  Sequencer sequencer;
  Transmitter seqTrans;
  Receiver synthRcvr, seqRcvr;
  Sequence seq;
  
  int defaultLoopLength, loopLength, maxLoopLength, minLoopLength, snapToLength, maxBpm, minBpm;
  int removeTolerance, metronomeGap;
  
  ArrayList<MidiEvent> eventsSnapshot; // hold events on a track at a time point
    
  int[] instruments = new int[16];
  int[] defaultInstruments = new int[]{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  int[] volumes = new int[16];
  int[] defaultVolumes = new int[]{100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100};
    
  Model(PApplet app){
    this.app = app;
    state = 0;
  }
  
  void handleFrame() {
    if (state == 0) { //splash
      if (frameCount > frameRate * 3) { // hold splash screen for 3 seconds
        state = 1;
      }
    }
    if (state == 3) { // initializing
      // setup model
      init();
      state = 4; // running
    }
  } 
  
  void init() {    
    myBus = new MidiBus(this.app, inputDevice, outputDevice);
    
    defaultLoopLength = 64;
    loopLength = defaultLoopLength;
    maxLoopLength = 256;
    minLoopLength = 16;
    metronomeGap = 4;
    snapToLength = 4;
    removeTolerance = 4;
    minBpm = 16;
    maxBpm = 320;
    
    eventsSnapshot = new ArrayList<MidiEvent>();
               
    try {
      // open devices    
      synth = getOutputDevice(outputDevice);
      synth.open();
      
      sequencer = MidiSystem.getSequencer(false);
      sequencer.open();
      
      synthRcvr = synth.getReceiver();
      seqRcvr = sequencer.getReceiver();
            
      // sequencer --> synth         
      seqTrans = sequencer.getTransmitter();
      seqTrans.setReceiver(synthRcvr);
  
    } catch (Exception e) {}
    
    initInstruments();
    initVolumes();
    initSequence();
  }
  
  int getInputDeviceCount() {
    ArrayList<String> inputDevices = getInputDevices();
    return inputDevices.size();
  }
  
  int getOutputDeviceCount() {
    ArrayList<String> outputDevices = getOutputDevices();
    return outputDevices.size();
  }
  
  ArrayList<String> getInputDevices() {
    ArrayList<String> results = new ArrayList<String>();
    MidiDevice.Info[] infos = MidiSystem.getMidiDeviceInfo();
    int outputCount = 0;
    for (int i = 0; i < infos.length; i++) {
      try {
        MidiDevice d = MidiSystem.getMidiDevice(infos[i]);
        d.getTransmitter();
        results.add(infos[i].toString() + " (" + infos[i].getDescription() + ")");
        outputCount++;
      } catch (Exception e) {}
    }
    return results;
  }

  ArrayList<String> getOutputDevices() {
    ArrayList<String> results = new ArrayList<String>();
    MidiDevice.Info[] infos = MidiSystem.getMidiDeviceInfo();
    int outputCount = 0;
    for (int i = 0; i < infos.length; i++) {
      try {
        MidiDevice d = MidiSystem.getMidiDevice(infos[i]);
        d.getReceiver();
        results.add(infos[i].toString() + " (" + infos[i].getDescription() + ")");
        outputCount++;
      } catch (Exception e) {}
    }
    return results;
  }
        
  MidiDevice getOutputDevice(int id) {
    MidiDevice.Info[] infos = MidiSystem.getMidiDeviceInfo();
    int currentId = 0;
    for (int i = 0; i < infos.length; i++) {
      try {
        MidiDevice d = MidiSystem.getMidiDevice(infos[i]);
        d.getReceiver();
        if (currentId++ == id) {
          return d;
        }
      } catch (Exception e) {}
    }
    return null;
  }
  
  void reset() {
    sequencer.stop(); 
    rewind(0);
    initInstruments();
    initVolumes();
    sequencer.setTempoFactor(0.4);
    cleanAllTracks();
    setupTracks();
  }
  
  void cleanAllTracks() {
    Track[] tracks = seq.getTracks();
    for (Track t : tracks) {
      while (t.size() > 0) {
        t.remove(t.get(0));
      }
    }
  }
    
  void setupTracks() {
    loopLength = defaultLoopLength;
    
    Track[] tracks = seq.getTracks();
    for(int i = 0; i < tracks.length; i++) {
      Track t = tracks[i];    
      ShortMessage myMsg = new ShortMessage(); 
      try{ 
        myMsg.setMessage(ShortMessage.NOTE_OFF, i, 0, 0); // need a dummy note to stretch the length of the tracks
      } catch (Exception e) {}
      MidiEvent dummyEvent = new MidiEvent(myMsg, maxLoopLength + 240); 
      t.add(dummyEvent);     
    }
   
    setUpMetronomoe();
    setUpSequencer();  
            
    for(int i = 0; i < tracks.length; i++) {
      sequencer.recordEnable(tracks[i], i);        
    }   
  }
    
  void initSequence() {
    try{
      seq = new Sequence(Sequence.PPQ, 10);      
      
      for(int i = 0; i < instruments.length; i++) {
        Track t = seq.createTrack();    
        ShortMessage myMsg = new ShortMessage();  
        myMsg.setMessage(ShortMessage.NOTE_OFF, i, 0, 0);
        MidiEvent dummyEvent = new MidiEvent(myMsg, maxLoopLength + 240); // extra buffer for the last note to sound 
        t.add(dummyEvent);          
      }
      
      setUpMetronomoe();
      setUpSequencer();
      
      Track[] tracks = seq.getTracks();      
      for(int i = 0; i < tracks.length; i++) {
        sequencer.recordEnable(tracks[i], i);        
      }             
    } catch (Exception e) {}
  }
  
  void setUpMetronomoe() {
    // track 16 as Metronome 
    Track[] tracks = seq.getTracks(); 
    for (int tick = 0; tick <= maxLoopLength; tick += metronomeGap) {
      ShortMessage myMsg = new ShortMessage();  
      try{
        myMsg.setMessage(ShortMessage.NOTE_ON, 15, 125, 127);
      } catch (Exception e) {}
      MidiEvent dummyEvent = new MidiEvent(myMsg, tick); 
      tracks[15].add(dummyEvent); 
    }  
  }
  
  void setUpSequencer() {
    try{
      sequencer.setSequence(seq);
    } catch (Exception e){}
    sequencer.setLoopCount(sequencer.LOOP_CONTINUOUSLY);
    sequencer.setLoopStartPoint(0);
    sequencer.setLoopEndPoint(defaultLoopLength);
    sequencer.setTempoFactor(0.4); 
  }

  void initInstruments() {
    for(int i = 0; i < instruments.length; i++) {
      setInstrument(i, defaultInstruments[i]);
    }
  }
  
  void initVolumes() {
    for(int i = 0; i < volumes.length; i++) {
      setVolume(i, defaultVolumes[i]);
    }
  }

  int getInstrument(int channel) {
    return instruments[channel];
  }
  
  int getVolume(int channel) {
    return volumes[channel];
  }
  
  void setVolume(int channel, int volume) {
    int status_byte = 0xC0; // change volume
    int channel_byte = channel;
    int first_byte = volume; //0-127
    int second_byte = 0;
      
    try{
      ShortMessage msg = new ShortMessage(ShortMessage.CONTROL_CHANGE, channel, 7, volume);
      synthRcvr.send(msg, -1); 
      volumes[channel] = volume; 
    } catch (Exception e) {}
    
  }

  void useNextInstrument(int channel) {
     setInstrument(channel, (getInstrument(channel) + 1 + 128) % 128);
  }
  
  void usePreviousInstrument(int channel) {
    setInstrument(channel, (getInstrument(channel) - 1 + 128) % 128);
  }

  void setInstrument(int channel, int instrument) {    
    int status_byte = 0xC0; // change program
    int channel_byte = channel;
    int first_byte, second_byte;
    if (channel == 9) {
      first_byte = 0;
      second_byte = 128;
    } else {
      instruments[channel] = instrument; 
      first_byte = instrument; //0-127
      second_byte = 0;
    }
    
    myBus.sendMessage(status_byte, channel_byte, first_byte, second_byte);
  }
  
  boolean isTickInBetween(long tick, long preTick, long postTick) {
    if (preTick <= postTick) {
      return (tick > preTick && tick <= postTick);
    } else {
      return (tick > preTick || tick <= postTick);
    }    
  }

  void removeNote(int channel, long currentTickPosition, long previousTickPosition) {
    // find all the events
    Track[] tracks = seq.getTracks(); 
        
    for (MidiEvent event : eventsSnapshot) {
      if (isTickInBetween(event.getTick(), previousTickPosition, currentTickPosition)) {
        println("[model] event removed at " + event.getTick());
        tracks[channel].remove(event);
      }
    }
    
    eventsSnapshot.clear(); 
    for (int i = 0; i < tracks[channel].size(); i++ ) {
      eventsSnapshot.add(tracks[channel].get(i));
    }
  }
  
  void togglePlay() {
    if (!sequencer.isRunning()) {
      sequencer.start();
      println("[model] playback started at " + sequencer.getTickPosition());
    } else {
      sequencer.stop();
      println("[model] playback paused at " + sequencer.getTickPosition());      
    }
  }
    
  void rewind(long position) {
    sequencer.setTickPosition(position);
    println("[model] sequence rewind to " + sequencer.getTickPosition());
  }
  
  void startRecording() {
    if (!sequencer.isRecording()) {
      sequencer.startRecording();
      println("[model] recording started at " + sequencer.getTickPosition());
    }
  }
  
  void stopRecording() {
    if (sequencer.isRecording()) {
      println("[model] recording stopped at " + sequencer.getTickPosition());
      sequencer.stopRecording();
    }
  }
  
  void setLoopLength(long tickLength) {
     if (sequencer.getTickPosition() > tickLength) {
       rewind(0);
     } 
     loopLength = int(tickLength);
     sequencer.setLoopEndPoint(tickLength);
  }
  
  void expandTrack() {
   if (loopLength * 2 <= maxLoopLength) {
     loopLength *= 2;
     setLoopLength(loopLength);
   }
  }
  
  void shrinkTrack() {
   if (loopLength / 2 >= minLoopLength) {
     loopLength /= 2;
     setLoopLength(loopLength);
   }
  }
  
  void speedUp() {
    float newFactor = constrain(getMmBpm() + 1.1, minBpm, maxBpm) * metronomeGap / seq.getResolution() / sequencer.getTempoInBPM();
    sequencer.setTempoFactor(newFactor);
  }
  
  void slowDown() {
    float newFactor = constrain(getMmBpm() - 0.9, minBpm, maxBpm) * metronomeGap / seq.getResolution() / sequencer.getTempoInBPM();
    sequencer.setTempoFactor(newFactor);
  }
  
  int getMmBpm() {
    return int(sequencer.getTempoInBPM() * sequencer.getTempoFactor() * seq.getResolution() / metronomeGap);
  }
  
  long removeTickPosition() {
    return (sequencer.getTickPosition() + removeTolerance) % loopLength; 
  }
  
  long snapToRemoveTickPosition() {
    return (getSnapToTickPositionFloor() + removeTolerance) % loopLength;
  }
  
  long getSnapToTickPositionFloor() {
    return int(floor(1.0 * sequencer.getTickPosition() / snapToLength) * snapToLength) % loopLength;
  }
  
  long getSnapToTickPositionRound() {
    return int(round(1.0 * sequencer.getTickPosition() / snapToLength) * snapToLength) % loopLength;
  }
  
  
  long getSnapToMicrosecondPosition() {
    long timestamp = sequencer.getMicrosecondPosition();
    
    long snapToTicksPosition = getSnapToTickPositionRound();
    long snapToTimestamp = (60000000 / model.seq.getResolution()) * snapToTicksPosition / int(model.sequencer.getTempoInBPM());
  
    return snapToTimestamp;     
  }
  
  boolean isMetronomeOn() {
    return !sequencer.getTrackMute(15);
  }
  
  void exportToFile() {
    String fileName = "equence_" + new SimpleDateFormat("yyyyMMddhhmmss'.mid'").format(new Date());
    String folderPath = sketchPath("") + "export\\";
    File outputFolder = new File(folderPath);
    if (!outputFolder.exists()) {
      if (outputFolder.mkdir()) {
        System.out.println("Directory is created!");
      } else {
        System.out.println("Failed to create directory!");
      }
    }
    
    File outputFile = new File(folderPath + fileName);
    
    try {
      int[] types = MidiSystem.getMidiFileTypes(seq);
      MidiSystem.write(seq, types[0], outputFile);
      println("[model] exported to " + folderPath + fileName);
    } catch (IOException e) {}
  }
}

