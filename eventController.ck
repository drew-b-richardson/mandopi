Constants c;
Pan2 master;

StkInstrument inst[12];
// make each instrument a different type
Flute inst0 @=> inst[0];
Rhodey inst1 @=> inst[1];
Moog inst2 @=> inst[2];
BeeThree inst3 @=> inst[3];
Wurley inst4 @=> inst[4];
FMVoices inst5 @=> inst[5];
TubeBell inst6 @=> inst[6];
PercFlut inst7 @=> inst[7];
StifKarp inst8 @=> inst[8];
ModalBar inst9 @=> inst[9];
VoicForm inst11 @=> inst[11];

0 => int currentInst;
0 => int currentInstNum;


//main instrument
inst[0] @=> StkInstrument instr;
instr =>  NRev rev => Chorus chorus => Gain g =>  Pan2 p =>    dac;
0.2 => chorus.modDepth;
0.1 => float instrGain;
0.2 => rev.mix;
0.0 => chorus.mix;
0 => p.pan;


//set initial values
c.a =>   c.key;
c.minpent @=> c.scale;
80.0 => c.bpm;
16 => c.numBeats;
4 => c.baseBeat;
c.setTempo();

Delay delay;
rev => delay => delay => p;
0 => int isDelay;
0.0 => delay.gain;
c.tempo::second * c.numBeatsPerMeasure => delay.max => delay.delay;

5 => int startOctave;

0 => int isPolyphonic;

//vars to make LiSa start at beginning of next measure
//NOTE:  ONCE THIS SHRED IS REMOVED, MEASURES ARE NO LONGER ACCURATE.  STARTTIME IS FROM START OF VM, NOT SHRED
1 => int playFromMeasure;
220 => int lag;
c.numBeats * c.tempo::second => dur durPerMeasure;
time timeStartDrum;

//GLOBAL VARIABLES
0 => int value;
100 => float frequency;
0.0 => float percentage;
0.0 => float offset;
.4 => float volume;
1=> int noteNumber;
0.0 => float pan;
-1 => int drumMachineId;
-1 => int bassId;
"" => string cmd;
int noteOn;
"" => string prevCmd;
1 => int isBend;
0 => int isVolume;

int previousMsg;

//do we need this?!?
now => timeStartDrum;

-1 => int f1Id;
[-1,-1,-1,-1,-1,-1,-1,-1,-1] @=> int fileIds[]; //position in array corresponds to file #
1 => int currentSection;

float curMeasure; //current measure after start of drums as float
float measureLeft;  //fraction of a measure until next measure starts
dur tillNextMeasure;//time until next measure starts
-1 => int eventValue;
// infinite event loop
while( true )
{
  // cereal.onLine() => now;
  // cereal.getLine() => string line;
  // chout <= "line: " <= line;
  //

  // wait for custom event
    <<< "test" >>>;
  c.event => now;
    <<< "eventValue" >>>;
  c.event.value => eventValue;
  <<< eventValue >>>;

  c.populateScale();



      //function keys for octave above notes
      if (eventValue >=c.F1 && eventValue <= c.F12)
      {
        play(eventValue - c.F1 + c.scale.cap());  //sends step of scale + octave: 7-14
      }
      //top keys 1-0
      if (eventValue >=c.NUM_1 && eventValue <= c.NUM_0)
      {
        //check if 1-0 is used to set reverb value
        if (previousMsg == c.KB_R)
        {
          (eventValue - c.NUM_1)/10.0 => rev.mix;
          -1 => previousMsg;
        }

        //if no 'previousMsg' just being used to play a note
        else{
          play(eventValue - c.NUM_1); //sends step of scale, 0-7
        }
      }

      //turn off sound
      if (eventValue == c.BACK_SPACE) {
        instrGain => instr.noteOff;
      }

      //raise octave
      if (eventValue == c.UP_ARROW) {
        startOctave + 1 => startOctave;
      }

      //lower octave
      if (eventValue == c.DOWN_ARROW) {
        startOctave - 1 => startOctave;
      }

      //set reverb
      if (eventValue == c.KB_R) {
        eventValue => previousMsg;
      }
      // //raise semitone
      // if (msg.key == c.EQUALS) {
      //   Std.mtof(c.fullScale[value-1] + startOctave*12 + 1) => frequency;
      // }
      //
      // //lower semitone
      // if (msg.key == c.EQUALS) {
      //    Std.mtof(c.fullScale[value-1] + startOctave*12 - 1) => frequency;
      // }
    }



fun void play(int scaleStep)
{
  Std.mtof(c.fullScale[scaleStep] + startOctave*12) => frequency;
  // <<< scaleStep, frequency >>>;
  instrGain => instr.noteOn;
  frequency => instr.freq;
  // " " => cmd;
  1::samp => now;
}

fun void waitTillNextMeasure()
{
  now - timeStartDrum => dur durSinceDrums;
  durSinceDrums/durPerMeasure => curMeasure; //current measure after start of drums as float

  Math.ceil(curMeasure) - curMeasure => measureLeft;  //fraction of a measure until next measure starts
  measureLeft * durPerMeasure => tillNextMeasure;//time until next measure starts
  tillNextMeasure => now; //wait until start of next measure and start looper
}

fun int toggle(int bool)
{
  if (bool == 1)
  {
    0 => bool;
  }
  else if (bool == 0)
  {
    1 => bool;
  }
  return bool;
}


fun void changeInstrument(int num)
{
  instrGain => instr.noteOff;
  instr =< rev;
  inst[num] @=> instr;
  instr =>  rev ;
  num => currentInst;
}
fun void getPreset(int num)
{
  if (num == 1)
  {
    changeInstrument(0);
    0.2 => rev.mix;
    0 => chorus.mix;
    0.5 => delay.gain;
    0.17 => instrGain;
    5 => startOctave;
  }
  else if (num == 2)
  {
    changeInstrument(1);
    0.2 => rev.mix;
    0.2 => chorus.mix;
    0.3 => delay.gain;
    0.4  => instrGain;
    6 => startOctave;
  }
  else if (num == 3)
  {
    changeInstrument(2);
    0.0 => rev.mix;
    0.0 => chorus.mix;
    0.3 => delay.gain;
    0.7 => instrGain;
    2 => startOctave;
  }
  else if (num == 4)
  {
    changeInstrument(4);
    0.1 => rev.mix;
    0.0 => chorus.mix;
    0.0 => delay.gain;
    0.8 => instrGain;
    2 => startOctave;
  }
}
