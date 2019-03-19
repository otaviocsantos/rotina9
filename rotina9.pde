import java.util.Map;
import processing.sound.*;

Clock clock;
QueryTwitter qt;
QueryBinomio qb;
Speaker speaker;
Reader reader;
SoundTracker soundtrack;
ArrayList<Jam> phrases;
ArrayList<Long> alreadyRead;
void setup()
{
    size(80,60);
    clock = new Clock();
    qt = new QueryTwitter();
    qb = new QueryBinomio();
    speaker = new Speaker();
    reader = new Reader(this, sketchPath()+"/data/poemas/");
    soundtrack = new SoundTracker(this);
    
    phrases = new ArrayList<Jam>();
    alreadyRead = new ArrayList<Long>();
    
    clock.addTrigger(5000, qt);
    clock.addTrigger(1000, qb);
}

void readPhrase(){
  if(phrases.size() > 0){
    Jam phrase = phrases.get(0);
    
    if(phrase.hashtag.equals("twitter"))  
      reader.read(phrase.msg);
    else
      speaker.speak(phrase.msg);
  
    phrases.remove(0);
    if(phrase.id != -1)
      alreadyRead.add(phrase.id);
  }
}

public void addPhrase(String msg, String hashtag, long id){
  //println("--"+msg);
  Jam phrase = new Jam(id,hashtag, msg);
  if(id==-1)
    phrases.add(phrase);
  else if(!containTweet(id))
    phrases.add(phrase);
}

boolean containTweet(long ind){
  for(Long e : alreadyRead){
    if(e == ind){
      return true;
    }
  }
  return false;
}

void draw(){
  clock.tick();
  if(speaker.speaking==false && reader.reading==false){
    readPhrase();
  }
}

class QueryBinomio implements Action{
  
  String path ="http://www.binomio.art.br/parteaparte/frases";
  boolean idle = true;
  void execute(){
    if(idle){
      idle = false;
      String[] page = loadStrings(path); 
      
    
      for(String line : page){
        addPhrase(line,"binomio",-1);
        println(line);
      }
    
      idle = true;
      
    }
  }
}

class Interval{
  private int prev;
  private int interval;
  int getPrev(){ return prev;}
  void reset(){ prev = millis();}
  boolean enabled = true;
  public Interval(){
      prev = millis();
  }
  
  boolean check(){
    if(enabled){
      if(millis() - prev > interval){
        prev = millis();
        return true;
      }
    }
    return false;
  }
}
  
import java.util.Map;

class Clock{

  HashMap<Interval, Action> dic;
  
  public Clock(){
    dic = new HashMap<Interval, Action>();
  }
  
  void addTrigger(int _interval, Action _action){
    Interval lapse = new Interval();
    lapse.interval = _interval;
    dic.put(lapse, _action);
    
  }
  void tick(){
    for (Map.Entry me : dic.entrySet()) {
      //print(me.getKey() + " is ");
      //println(me.getValue());
      Interval i = (Interval) me.getKey(); 
      if(i.check()){
        Action a = (Action) me.getValue();
        a.execute();
      }
    }
  }
}

class Reader{
  boolean reading = false;
  String path = "";
  String[] verses;
  int count = 0;
  PApplet parent;
  
  public Reader(PApplet _parent, String _path){
    parent = _parent;
    path = _path;
    
    File[] files = listFiles(path);
    verses = new String[files.length];
    count = 0;
    String name = "";
    for(File f : files){
      name = f.getName();
      if(name.substring(name.length()-3).equals("wav"))
        verses[count++] = name;
    }
  }
  
  void read(String msg ){
    if(!reading){
      reading = true;
      int rand = (int)random(count);
      String randomVerse = verses[rand];
      
      String readPath = path + randomVerse ;
      
      SoundFile readVerse = new SoundFile(parent, readPath);
      
      readVerse.play();
      delay((int)(readVerse.duration()*1000));
      readEnded();
    }
  }
  
  void readEnded(){
    println("read ended");
    reading = false;
  }
}

import twitter4j.conf.*;
import twitter4j.*;
import twitter4j.auth.*;
import twitter4j.api.*;
import java.util.List;

class QueryTwitter implements Action{
  boolean idle = true;
  Twitter twitter;
  String currentPlace = "casadasrosas";
  String searchFor ="#hildahilst OR #parteaparte OR #antrohh OR #"+currentPlace;
  long maxID = Long.MAX_VALUE;
  int tweestPerPage = 10;

  public QueryTwitter(){
    ConfigurationBuilder cb = new ConfigurationBuilder();
    
    String[] lines = loadStrings("keys.txt");
    
    cb.setOAuthConsumerKey(lines[0]);
    cb.setOAuthConsumerSecret(lines[1]);
    cb.setOAuthAccessToken(lines[2]);
    cb.setOAuthAccessTokenSecret(lines[3]);
  
    TwitterFactory tf = new TwitterFactory(cb.build());
  
    twitter = tf.getInstance();
  }
  
  void execute(){
    
    if(idle){
      idle = false;
      query();
    }
  }
  
  void query(){
    Query query = new Query(searchFor);
    query.setCount(tweestPerPage);
    query.setMaxId(maxID);
    try{
      QueryResult result = twitter.search(query);
      //tweetList = result.getTweets();
      
      for(Status s : result.getTweets()){
        
        String msg = treatText(s);
        long id = s.getId();
        String hashtag = "";
        HashtagEntity[] hashtags = s.getHashtagEntities();
        try{
          hashtag = hashtags[0].getText();
        }catch(Exception e){
          println("Error reading hashtags");
        }
        if(!hashtag.equals(""))
          addPhrase(hashtag, msg, id);
      }
      idle= true;
    }catch(TwitterException te){
      println("Couldn't connect: "+te);
      idle= true;
    }
  }
  
  String treatText(Status s) {
    if (s == null)  return "";
    String fullText = s.getText();
   
    for (final URLEntity ue : s.getURLEntities())
      fullText = fullText.replace(ue.getURL(), "");
      
    //for (final HashtagEntity he : s.getHashtagEntities())
    //  fullText = fullText.replace(he.getText(), "");
    
    fullText = removeUrl(fullText);
    fullText = fullText.replace("<3", "coração");
    fullText = fullText.replace("hj", "hoje");
    fullText = fullText.replace("bj", "beijo");
    fullText = fullText.replace("bjs", "beijos");
    fullText = fullText.replace("abs", "abraço");
    fullText = fullText.replace("cmg", "comigo");
    fullText = fullText.replace("vc", "você");
    fullText = fullText.replace("tmb", "também");
    fullText = fullText.replace("tb", "também");
    fullText = fullText.replace("td", "tudo");
    fullText = fullText.replace("mds", "meu deus");
    return fullText;
  }

  private String removeUrl(String value)
  {
        
        String result = value.replaceAll( "((https?|ftp|gopher|telnet|file|Unsure|http):((//)|(\\\\))+[\\w\\d:#@%/;$()~_?\\+-=\\\\\\.&]*)","").trim();
        
        return result;
  }
}