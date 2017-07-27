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
21 => int KB_R;
14 => int KB_K;
6 => int KB_C;
4 => int KB_A;
22 => int KB_S;

400 => int BEND_START;
600 => int BEND_END;
(BEND_START + BEND_END) / 2 => int BEND_MID;
1500 => int VIBRATO_START;
2500 => int VIBRATO_END;
(VIBRATO_START + VIBRATO_END) / 2 => int VIBRATO_MID;

8 => int OCTAVE_RANGE;


//declare variables
int currentKey;
int currentScale[];
int startOctave;
int previousMsg;
float frequency;
float instrGain;

//main instrument set up
StkInstrument inst[1];
Flute inst0 @=> inst[0];
inst[0] @=> StkInstrument instr;
instr =>  NRev rev => Chorus chorus => Gain g =>  Pan2 p =>    dac;
0.2 => chorus.modDepth;
0.1 => instrGain;
0.2 => rev.mix;
0.0 => chorus.mix;
0 => p.pan;

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
  // <<<  event.value >>>;
  //function keys for octave above notes
  if (event.value >=F1 && event.value <= F12)
  {
    play(event.value - F1 + currentScale.cap());  //sends step of scale + octave: 7-14
  }
  //top keys 1-0
  if (event.value >=NUM_1 && event.value <= NUM_0)
  {
    //check if 1-0 is used to set reverb value
    if (previousMsg == KB_R)
    {
      (event.value - NUM_1)/10.0 => rev.mix;
      -1 => previousMsg;
    }
    //check if 1-0 is used to set scale
    if (previousMsg == KB_S)
    {
      if (event.value == NUM_1) {
        ionian @=> currentScale;
      }
      else if (event.value == NUM_2) {
        dorian @=> currentScale;
      }
      populateScale();
      -1 => previousMsg;
    }

    //if no 'previousMsg' just being used to play a note
    else{
      play(event.value - NUM_1); //sends step of scale, 0-7
    }
  }

  //turn off sound
  if (event.value == BACK_SPACE) {
    instrGain => instr.noteOff;
  }

  //raise octave
  if (event.value == UP_ARROW) {
    startOctave + 1 => startOctave;
  }

  //lower octave
  if (event.value == DOWN_ARROW) {
    startOctave - 1 => startOctave;
  }

  //set reverb
  if (event.value == KB_R) {
    event.value => previousMsg;
  }

  //set scale
   if (event.value == KB_S) {
     event.value => previousMsg;
   }

  //set key
  if (event.value == KB_K) {
    event.value => previousMsg;
  }
  if (event.value == KB_C && previousMsg == KB_K) {
      KEY_C => currentKey;
      -1 => previousMsg;
      populateScale();
    }
    else if (event.value == KB_A && previousMsg == KB_K) {
      KEY_A => currentKey;
      -1 => previousMsg;
      populateScale();
    }


    //bend pitch
    if (event.value > BEND_START && event.value < BEND_END) {
      (event.value - BEND_MID) => int normalizedValue; //-100 to 100
        map(normalizedValue, -100, 100, frequency * 8/9, frequency*8/7)=> float newFreq;
        <<< frequency, ":old | ", newFreq, ":new" >>>;
        newFreq => instr.freq;
    }

  //vibrato
  if (event.value > VIBRATO_START && event.value < VIBRATO_END) {
    (event.value - VIBRATO_MID) => int normalizedValue; //-500 to 500
    map(normalizedValue, -500, 500, frequency * 22/23, frequency*20/19)=> float newFreq;
    <<< frequency, ":old | ", newFreq, ":new" >>>;
    newFreq => instr.freq;
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
  cereal.open(2, SerialIO.B9600, SerialIO.ASCII);
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
        <<< "down:",  msg.key >>>;
        msg.key => e.value;
        e.signal();
        // 1::samp => now;
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


fun void play(int scaleStep)
{
  Std.mtof(fullScale[scaleStep] + startOctave*12) => frequency;
  // <<< scaleStep, frequency >>>;
  instrGain => instr.noteOn;
  frequency => instr.freq;
  // " " => cmd;
  1::samp => now;
}
