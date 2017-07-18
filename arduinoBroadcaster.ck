//arduino setup
SerialIO cereal;
cereal.open(2, SerialIO.B9600, SerialIO.ASCII);
Constants c;

while(true)
{
<<< "1">>>;
cereal.onLine() => now;
<<< "2">>>;
cereal.getLine() => string line;
chout <= "line: " <= line;
    // c.event.value = c.F1;
    // c.event.signal();
    // 1::samp => now;

}
