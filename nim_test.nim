import arduino

const ledPin = 5

setup:
  ledPin.pinMode OUTPUT
  # for i in 1..1000:
    # var x = "test"
    # echo "echo: " & x


loop:
  ledPin.digitalWrite HIGH
  delay 1000
  ledPin.digitalWrite LOW  
  delay 500

