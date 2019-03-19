import processing.sound.*;

class SoundTracker{
  PApplet parent;
  SoundFile soundFile;
  String soundPath;
  SoundFile soundtrack;
  String soundtrackPath = "0_FULL_BG.wav";
  
  public SoundTracker(PApplet _parent){
    parent = _parent;
    soundtrack = new SoundFile(parent, soundtrackPath);
    soundtrack.loop();
  } 
}