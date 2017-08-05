//Constants
0 => int KEY_C;
1 =>  int KEY_CS;
2 =>  int KEY_D;
3 =>  int KEY_DS;
4 =>  int KEY_E;
5 =>  int KEY_F;
6 =>  int KEY_FS;
7 => int KEY_G;
8 =>  int KEY_GS;
9 =>  int KEY_A;
10 =>  int KEY_AS;
11 =>  int KEY_B;

[0,2,4,5,7,9,11,12] @=> int ionian[];
[0,2,3,5,7,9,10,12] @=>  int dorian[];
[0,1,3,5,7,8,10,12] @=>  int phrygian[];
[0,2,4,6,7,9,11,12] @=>  int lydian[];
[0,2,4,5,7,9,10,12] @=>  int mixolydian[];
[0,2,3,5,7,8,10,12] @=>  int aeolian[];
[0,1,3,5,6,8,10,12] @=>  int locrian[];
[0,3,5,6,7,10,12] @=> int minpent[];
[0,2,4,7,9,12] @=>  int majpent[];
[0,2,3,5,7,8,11,12] @=>   int harmminor[];
[0,2,3,5,7,9,11,12] @=>   int melodminor[];
[0,2,3,6,7,8,11,12] @=>   int hungarian[];
[0,1,4,5,6,8,11,12] @=>   int persian[];
[0,1,4,5,7,8,11,12] @=>   int byzantine[];
[0,1,4,5,6,9,10,12] @=>  int oriental[];
[0,1,3,5,7,8,10,12] @=>   int indian[];
[0,2,3,6,7,8,11,12] @=>   int gypsy[];
[0,1,4,5,7,8,10,12] @=>   int ahava[];

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

58 => int F1;
69 => int F12;
30 => int NUM_1;
31 => int NUM_2;
39 => int NUM_0;
42 => int BACK_SPACE;
81 => int DOWN_ARROW;
82 => int UP_ARROW;
45 => int DASH;
46 => int EQUALS;
53 => int TILDE;
41 => int ESC;
4 => int KB_A;
5 => int KB_B;
6 => int KB_C;
7 => int KB_D;
8 => int KB_E;
9 => int KB_F;
10 => int KB_G;

12 => int KB_I;
14 => int KB_K;
16 => int KB_M;
19 => int KB_P;
22 => int KB_S;
89 => int NUMPAD_1;
92 => int NUMPAD_4;
97 => int NUMPAD_9;

400 => int BEND_START;
600 => int BEND_END;
(BEND_START + BEND_END) / 2 => int BEND_MID;
1500 => int VIBRATO_START;
2500 => int VIBRATO_END;
(VIBRATO_START + VIBRATO_END) / 2 => int VIBRATO_MID;
0 => int semitoneAdj;


8 => int OCTAVE_RANGE;


//declare variables
int currentKey;
int currentScale[];
int startOctave;
int previousMsg;
float frequency;
float instrGain;

//main instrument set up
// StkInstrument inst[1];
// Flute inst0 @=> inst[0];
inst[0] @=> StkInstrument instr;
// instr =>  NRev rev => Chorus chorus => Gain g =>  Pan2 p =>    dac;
instr =>Gain g =>  dac;
// 0.2 => chorus.modDepth;
0.9 => instrGain;
// 0.0 => rev.mix;
// 0.0 => chorus.mix;
// 0 => p.pan;

//set initial values
KEY_A => currentKey;
ionian @=> currentScale;
5 => startOctave;
int fullScale[currentScale.cap() * (OCTAVE_RANGE)];

populateScale();

//custom event that returns a value.  spork instance of event to both keyboard and arduino broadcaster and wait for one to return response
class MandoEvent extends Event
{
  int value; //for usb, this will be msg.key
}
MandoEvent event;
spork ~ getKeyboardEvent(event);
spork ~ getArduinoEvent(event);

//MAIN PROGRAM
while( true )
{
  //wait for event
  event => now;

  //check if incoming value is to be used as a command value
  if (previousMsg == KB_S || previousMsg == KB_K || previousMsg == KB_I )
  {
    //changing scale
    if (previousMsg == KB_S)
    {
      if (event.value == KB_I) {
        ionian @=> currentScale;
      }
      else if (event.value == KB_D) {
        dorian @=> currentScale;
      }
      else if (event.value == KB_M) {
        mixolydian @=> currentScale;
      }
      else if (event.value == KB_A) {
        aeolian @=> currentScale;
      }
      else if (event.value == KB_B) {
        minpent @=> currentScale;
      }
      else if (event.value == KB_P) {
        majpent @=> currentScale;
      }
      populateScale();
    }

    //changing instrument
    else if (previousMsg == KB_I){
      changeInstrument(event.value - NUM_1);//pass in value 1-10
    }

    //changing keys
    else if (previousMsg == KB_K)
    {
      if (event.value == KB_A) {
        KEY_A => currentKey;
      }
      else if (event.value == KB_C) {
        KEY_C => currentKey;
      }
      else if (event.value == KB_G) {
        KEY_G => currentKey;
      }
      else if (event.value == KB_E) {
        KEY_E => currentKey;
      }
      else if (event.value == KB_D) {
        KEY_D => currentKey;
      }
      populateScale();
    } -1 => previousMsg; //reset previousMsg
  } 
  //otherwise, just a one key command
  else{

    //top keys 1-0
    if (event.value >=NUM_1 && event.value <= NUM_0)
    {
      play(event.value - NUM_1); //sends step of scale, 0-7
    }
    //function keys
    else if (event.value >=F1 && event.value <= F12)
    {
      play(event.value - F1 + currentScale.cap() - 1);  //sends step of scale + octave: 7-14
    }
    else if (event.value == TILDE)
    {
      play(-1);  //sends step of scale + octave: 7-14
    }
    else if (event.value == ESC)
    {
      play(6);  //sends step of scale + octave: 7-14
    }
    //volume
   else if (event.value >= NUMPAD_4 && event.value <= NUMPAD_9)
{
      (event.value - NUMPAD_4) * 0.2 => instrGain; 
}

//turn off sound
    else if (event.value == BACK_SPACE) {
      instrGain => instr.noteOff;
    }
    //raise octave
    else if (event.value == UP_ARROW) {
      startOctave + 1 => startOctave;
    }
    //lower octave
    else if (event.value == DOWN_ARROW) {
      startOctave - 1 => startOctave;
    }
    //lower semitone
    else if (event.value == DASH) {
      -1 => semitoneAdj;
    }
    //raise semitone
    else if (event.value == EQUALS) {
      1 => semitoneAdj;
    }

    //nunchuck messages
    //bend pitch
    if (event.value > BEND_START && event.value < BEND_END) {
      (event.value - BEND_MID) => int normalizedValue; //-100 to 100
      map(normalizedValue, -100, 100, frequency * 8/9, frequency*8/7)=> float newFreq;
      // <<< frequency, ":old | ", newFreq, ":new" >>>;
      newFreq => instr.freq;
    }

    //vibrato
    if (event.value > VIBRATO_START && event.value < VIBRATO_END) {
      (event.value - VIBRATO_MID) => int normalizedValue; //-500 to 500
      map(normalizedValue, -500, 500, frequency * 22/23, frequency*20/19)=> float newFreq;
      // <<< frequency, ":old | ", newFreq, ":new" >>>;
      newFreq => instr.freq;
    }
    event.value => previousMsg;
  }
}

//wait for arduino serial line.  once you get one, signal main program and send value back to main program via passed in mando event
fun void getArduinoEvent(MandoEvent e)
{

// list serial devices
SerialIO.list() @=> string list[];

// no serial devices available
if(list.cap() == 0)
{
    cherr <= "no serial devices available\n";
    me.exit();
}

// print list of serial devices
chout <= "Available devices\n";
for(int i; i < list.cap(); i++)
{
    chout <= i <= ": " <= list[i] <= IO.newline();
}

  SerialIO cereal;
  cereal.open(0, SerialIO.B9600, SerialIO.ASCII);
  while(true)
  {
    cereal.onLine() => now;
    cereal.getLine() => string line;
    Std.atoi(line) => e.value;
    e.signal();
  }
}

//wait for keypress. once you get one, signal main program and send value back to main program via passed in mando event
fun void getKeyboardEvent(MandoEvent e)
{
  Hid hi;
  HidMsg msg;
  0 => int device;
  if( !hi.openKeyboard( device ) ) me.exit();
  while( true )
  {
    hi => now;
    while( hi.recv( msg ) )
    {
      if( msg.isButtonDown() )
      {
        // <<< "down:",  msg.key >>>;
        msg.key => e.value;
        e.signal();
      }
    }
  }
}

fun float map(float x, float in_min, float in_max, float out_min, float out_max)
{
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

fun void populateScale()
{
  for(0 => int i; i < currentScale.cap(); i++)
  {
    for(0 => int j; j < OCTAVE_RANGE; j++)
    {
      currentScale[i] + j*12 + currentKey @=> fullScale[i + (currentScale.cap()-1)*j];
    }
  }
}

fun void changeInstrument(int num)
{
  instrGain => instr.noteOff;
  instr =< g;
  inst[num] @=> instr;
  instr =>  g ;
}


fun void play(int scaleStep)
{
	if(scaleStep == -1){
		Std.mtof(fullScale[6] + (startOctave-1)*12 + semitoneAdj) => frequency;
	}
	else{
		Std.mtof(fullScale[scaleStep] + startOctave*12 + semitoneAdj) => frequency;
	}
  // <<< scaleStep, frequency >>>;
  instrGain => instr.noteOn;
  frequency => instr.freq;
  1::samp => now;
  0 => semitoneAdj;
}
