class Speaker{
  boolean speaking = false;
  
  public Speaker(){
    launch("/Applications/Utilities/Terminal.app");  
  }
  
void speak(String msg ){
  if(!speaking){
    speaking = true;
    delay(300);
    
    if(random(1)>0.838){
      String[] params = {"say", "-v","Felipe", msg };
      exec(params);
    }else{
      String[] params = {"say", msg };
      exec(params);
    }
    
    delay(msg.length() * 150);
    speakEnded();
  }
}

void speakEnded(){
  speaking = false;
}
}