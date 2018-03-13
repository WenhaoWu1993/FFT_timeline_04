import ddf.minim.*;
import ddf.minim.analysis.*;
//import ddf.minim.effects.*;
//import ddf.minim.signals.*;
//import ddf.minim.spi.*;
//import ddf.minim.ugens.*;

import peasy.*;

PeasyCam cam;

float forwardDistance;
float[] rawSpectrum = new float[8];

float speed = 0.1, progression = 0.5;

ArrayList<WaveTimeline> timelines = new ArrayList<WaveTimeline>();

Minim minim;
AudioPlayer audio;
FFT fft;

float scale = 2;

void setup() {
  size(800, 600, P3D);
  cam = new PeasyCam(this, 500);
  
  for(int i = 0; i < 8; i++) {
    timelines.add(new WaveTimeline(i));
  }
  
  minim = new Minim(this);
  audio = minim.loadFile("radio_activity.mp3");
  fft = new FFT(audio.bufferSize(), audio.sampleRate());
  fft.logAverages(150, 1);
  
  audio.loop();
  
  colorMode(HSB, 100);
  noFill();
  pixelDensity(2);
}

void draw() {
  background(0);
  
  //for(int i = 0; i < 8; i++) {
  //  rawSpectrum[i] = random(-30, 30);
  //}
  
  lights();
    
  fft.forward(audio.mix);
  
  if(forwardDistance < 1) {
    for(int i = 0; i < 8; i++) {
      WaveTimeline wt = timelines.get(i);
      wt.goForward();
      wt.display();
    }
    forwardDistance += speed;
  }
  else {
    for(int i = 0; i < 8; i++) {
      WaveTimeline wt = timelines.get(i);
      wt.update();
      wt.display();
    }
    forwardDistance = 0.0;
  }
  
  //println(frameRate);
  
  //drawAxis();
}

void drawAxis() {
  //axis
  colorMode(RGB);
  stroke(255, 0, 0);
  line(0, 0, 0, 100, 0, 0);
  
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 100, 0);
  
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 100);
}
  

class WaveTimeline {
  int index;
  float[] trace = new float[0];
  
  float xBase;
  PVector start, end;
  PVector looseEnd;
  
  float hue;
  
  WaveTimeline(int index_) {
    index = index_;
    
    xBase = 20 * index;
    end = new PVector(0, 0, 0);
    start = new PVector(0, 0, 0);
    looseEnd = new PVector(xBase, 0, 0);
    
    hue = map(index, 0, 7, 70, 0);
  }
  
  void goForward() {
    looseEnd.y = start.y + (end.y - start.y) * forwardDistance;
    looseEnd.z = start.z + (end.z - start.z) * forwardDistance;
  }
  
  void update() {
    trace = append(trace, end.y);
    
    start.y = end.y;
    start.z = end.z;
    
    end.y = fft.getAvg(index) * scale;
    end.z += progression;
  }
  
  void display() {
    
    stroke(hue, 100, 100);
    beginShape();
    for(int i = 0; i < trace.length; i++) {
      vertex(xBase, trace[i], progression * i);
    }
    vertex(looseEnd.x, looseEnd.y, looseEnd.z);
    endShape();
  }
}

int savedTime = 0;

void keyPressed() {
  if(key == ' ') {
    savedTime++;
    String name = "fftTrial-" + savedTime;
    saveFrame(name + ".png");
  }
}