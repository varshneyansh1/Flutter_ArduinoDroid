#include <SoftwareSerial.h>
#include <LiquidCrystal_I2C.h>
#include <DHT.h>
LiquidCrystal_I2C lcd(0x27, 16, 2);
SoftwareSerial btSerial(0, 1);

#define ledpin 13
#define buzzpin 12
#define DHTPIN 8
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);


void scrolling_loop(String text) {
  String text1 = " Incoming Text  ";
  int i1, j1 = 0;
  for (i1 = 0; i1 < text1.length(); i1++) {
    if (i1 < 15) {
      lcd.setCursor(i1, 0);
      lcd.print(text1.charAt(i1));
    }
  }
  int i, j = 0;
  for (i = 0; i < text.length(); i++) {
    if (i < 15) {
      lcd.setCursor(i, 1);
      lcd.print(text.charAt(i));
      delay(150);
    }


    else {
      for (i = 16; i < text.length(); i++) {
        j++;
        lcd.setCursor(0, 1);
        lcd.print(text.substring(j, j + 16));
        delay(500);
      }
    }
  }
  return;
}

String chk;


void displaystatus(String status) {
  if (status.equals("onled")) {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Led is turned");
    lcd.setCursor(0, 1);
    lcd.print("on");
  }

  if (status.equals("ofled")) {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Led is turned");
    lcd.setCursor(0, 1);
    lcd.print("off");
    delay(4000);
  }

  if (status.equals("onbuz")) {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Buzzer is turned");
    lcd.setCursor(0, 1);
    lcd.print("on");
  }

  if (status.equals("ofbuz")) {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Buzzer is turned");
    lcd.setCursor(0, 1);
    lcd.print("off");
    delay(4000);
  }
}
void display() {
  // String username="ansh";
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("     Welcome");
  // lcd.setCursor(0, 1);
  // lcd.print(user);
}
void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  btSerial.begin(9600);

  dht.begin();
  lcd.init();
  lcd.backlight();
  lcd.setBacklight(HIGH);

  pinMode(ledpin, OUTPUT);
  pinMode(buzzpin, OUTPUT);
  digitalWrite(ledpin, LOW);
  digitalWrite(buzzpin, LOW);


  display();
}

void loop() {
  // put your main code here, to run repeatedly:
  if (btSerial.available() > 0) {



    String func = btSerial.readString();
    func.trim();
    int l = func.length();

    if (l == 5) {
      if (func.equals("onled")) {
        digitalWrite(ledpin, HIGH);
        displaystatus(func);
      }
      if (func.equals("ofled")) {
        digitalWrite(ledpin, LOW);
        displaystatus(func);
        display();
      }
      if (func.equals("onbuz")) {
        digitalWrite(buzzpin, HIGH);
        displaystatus(func);
      }
      if (func.equals("ofbuz")) {
        digitalWrite(buzzpin, LOW);
        displaystatus(func);
        display();
      }
      if (func.equals("ontmp")) {



        int h = dht.readHumidity();

        int t = dht.readTemperature();

        float f = dht.readTemperature(true);

        // Check if any reads failed and exit early (to try again).
        if (isnan(h) || isnan(t) || isnan(f)) {
          Serial.println("Failed to read from DHT sensor!");
          return;
        }

        lcd.setCursor(0, 0);
        lcd.print("Humidity:");
        lcd.print(h);
        lcd.print("%");


        lcd.setCursor(0, 1);
        lcd.print("Temperature:");
        lcd.print(t);
        lcd.print("C");
        delay(50);
      }
      if (func.equals("oftmp")) {
        display();
      }

    }

    else if (l > 5) {
      chk = func.substring(0, 6);

      if (chk.equals("onmsgg")) {
        String k = func.substring(6, l);


        lcd.clear();
        scrolling_loop(k);
        delay(1000);

        lcd.clear();
        scrolling_loop(k);
        delay(1000);










      } else if (chk.equals("ofmsgg")) {
        display();
      }
    }
  }
}
