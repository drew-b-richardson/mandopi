//SERIAL INPUT FROM ARDUINO
SerialIO cereal;
cereal.open(0, SerialIO.B9600, SerialIO.ASCII);
1 => int firstTime;
<<< "start" >>>;
while(true)
{

  cereal.onLine() => now;
  cereal.getLine() => string line;
  chout <= "line: " <= line;

}
