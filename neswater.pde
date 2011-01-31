#include <Servo.h>
#include <LiquidCrystal.h>

#define ERROR_WINDOW 50  // +/- this value
#define BUTTONDELAY 200
#define DEBUG_OFF


LiquidCrystal lcd(12, 11, 10, 9, 8, 7);


// Servo who control flow of sirup & water
Servo sirup1Servo;
Servo sirup2Servo;
Servo sirup3Servo;
Servo waterServo;

int sirup1ServoPin = 2;
int sirup2ServoPin = 3;
int sirup3ServoPin = 4;
int waterServoPin = 5;

int servoOpen = 100;
int servoClose = 50;

int vidangeButtonPin = 6;
int vidangeState = 0;

int ledPin = 5;      // LED connected to digital pin 9
int analogPin = 1;   // switch circuit input connected to analog pin 3
long buttonLastChecked = 0; // variable to limit the button getting checked every cycle
int position = 0;

void setup()
{
  pinMode(ledPin, OUTPUT);   // sets the pin as output on a PWM capable pin
  pinMode(vidangeButtonPin, INPUT);     
  sirup1Servo.attach(sirup1ServoPin);
  sirup2Servo.attach(sirup2ServoPin);
  sirup3Servo.attach(sirup3ServoPin);
  waterServo.attach(waterServoPin);

  // Set all the switch to the close position
  sirup1Servo.write(servoClose);
  sirup2Servo.write(servoClose);
  sirup3Servo.write(servoClose);
  waterServo.write(servoClose);

  lcd.begin(16, 2);
  // Print a message to the LCD.
  lcd.print("Welcome !");
  
  Serial.begin(115200);

}

void loop()
{
  if( buttonLastChecked == 0 ) // see if this is the first time checking the buttons
    buttonLastChecked = millis()+BUTTONDELAY;  // force a check this cycle

  if( millis() - buttonLastChecked > BUTTONDELAY )
  { 
    if(digitalRead(vidangeButtonPin) == HIGH)
    {
      vidange();
    }
    // make sure a reasonable delay passed
    if( int buttNum = buttonPushed(analogPin) ) 
    {
      Serial.print("Button ");
      Serial.print(buttNum);
      Serial.println(" was pushed.");  
    }
    buttonLastChecked = millis(); // reset the lastChecked value
  }
}

/*
 *
 *   analogPin                 +5 V
 *      |                         |
 *      |                         \
 *      ----------------          /  
 *                     |          \    .5K
 *                     |          /
 *                     |          \
 *                     |____ \____|
 *                     |   SW1    |
 *                     |          \
 *                     |          /  
 *                     |          \    .5K
 *                     |          /
 *                     |          \
 *                     |____ \____|
 *                     |   SW2    |
 *                     |          |
 *                     |          \
 *                     |          /  
 *                     |          \    .5K
 *                     |          /
 *                     |          \
 *                     |____ \____|
 *                     |   SW3    |
 *                                |
 *                                |
 *                              _____  
 *                               ___     ground
 *                                _
 *
 */

int buttonPushed(int pinNum) {
  int val = 0;         // variable to store the read value
  digitalWrite((14+pinNum), HIGH); // enable the 20k internal pullup
  val = analogRead(pinNum);   // read the input pin

#ifdef DEBUG_ON
  Serial.println(val);
  analogWrite(ledPin, val/4); // analog input 0-1023 while analogWrite 0-255
#endif
  // we don't use the upper position because that is the same as the
  // all-open switch value when the internal 20K ohm pullup is enabled.
  //if( val >= 923 and val <= 1023 )
  //  Serial.println("switch 0 pressed/triggered");
  if( val >= (711-ERROR_WINDOW) and val <= (711+ERROR_WINDOW) ) {  // 830
#ifdef DEBUG_ON
    Serial.println("switch 1 pressed/triggered");
#endif
    //position = position + 10;
    //Serial.println(position);
   // waterServo.write(servoOpen);
  //  sirup2Servo.write(servoOpen);
   // sirup3Servo.write(servoOpen);
   // Serial.println(sirup1Servo.read());
     sirup1Action();
    return 1;
  }
  else if ( val >= (400-ERROR_WINDOW) and val <= (400+ERROR_WINDOW) ) { // 630
#ifdef DEBUG_ON
    Serial.println("switch 2 pressed/triggered");
#endif
    //position = position - 10;
    //Serial.println(position);
    //waterServo.write(servoClose);
   // sirup2Servo.write(servoClose);
   // sirup3Servo.write(servoClose);
    //Serial.println(sirup1Servo.read());
     sirup2Action();
    return 2;
  }
  else if ( val >= (14-ERROR_WINDOW) and val <= (14+ERROR_WINDOW) ) { // 430
#ifdef DEBUG_ON
    Serial.println("switch 3 pressed/triggered");
#endif
      sirup3Action();
    return 3;
  }
  else
    return 0;  // no button found to have been pushed
}

void sirup1Action()
{
  lcd.print("Mint -> Plz wait !");
  sirup1Servo.write(servoOpen);
  delay(5000);
  waterServo.write(servoOpen);
  delay(3000);

  // close all !
  sirup1Servo.write(servoClose);
  delay(2000);
  waterServo.write(servoClose);
  lcd.print("Enjoy !");
}

void sirup2Action()
{
  lcd.print("Grenade -> Plz wait !");
  sirup2Servo.write(servoOpen);
  delay(7000);
  waterServo.write(servoOpen);
  delay(3000);

  // close all !
  sirup2Servo.write(servoClose);
  delay(2000);
  waterServo.write(servoClose);
  lcd.print("Enjoy !");
}

void sirup3Action()
{
  lcd.print("Rasberry -> Plz wait !");
  sirup3Servo.write(servoOpen);
  delay(5000);
  waterServo.write(servoOpen);
  delay(3000);

  // close all !
  sirup3Servo.write(servoClose);
  delay(2000);
  waterServo.write(servoClose);
  lcd.print("Enjoy !");
}

void vidange()
{
  if(!vidangeState){
    sirup1Servo.write(servoOpen);
    sirup2Servo.write(servoOpen);
    sirup3Servo.write(servoOpen);
    waterServo.write(servoOpen);
    vidangeState = 1;
  }
  else{
    sirup1Servo.write(servoClose);
    sirup2Servo.write(servoClose);
    sirup3Servo.write(servoClose);
    waterServo.write(servoClose);
    vidangeState = 0;
  }

}

