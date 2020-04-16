import arduino

setup:
  pinMode LED_BUILTIN, OUTPUT

loop:
  digitalWrite LED_BUILTIN, HIGH
  delay 1500
  digitalWrite LED_BUILTIN, LOW  
  delay 1500

