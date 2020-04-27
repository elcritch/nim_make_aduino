import arduino

const ledPin = 5

setup:
  ledPin.pinMode OUTPUT

loop:
  ledPin.digitalWrite HIGH
  delay 1000
  ledPin.digitalWrite LOW  
  delay 500

