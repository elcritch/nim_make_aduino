import arduino

setup:
  pinMode LED_BUILTIN, OUTPUT

loop:
  digitalWrite LED_BUILTIN, HIGH
  delay 1000
  digitalWrite LED_BUILTIN, LOW  
  delay 500

