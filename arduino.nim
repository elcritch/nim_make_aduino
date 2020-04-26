# Translated with c2nim from Arduino.h and friends

import macros
import strutils except `formatFloat`


const LED_BUILTIN* = 13
const HIGH* = 1
const LOW* = 0
const INPUT* = 0
const OUTPUT* = 1

type
  cuchar = uint8
  String* {.importcpp: "String", header: "WString.h", bycopy.} = object ##  use a function pointer to allow for "if (s)" without the

proc constructString*(a1: float32; decimalPlaces: cuchar = 2): String {.cdecl,
    constructor, importcpp: "String(@)", header: "WString.h".}
proc constructString*(a1: float64; decimalPlaces: cuchar = 2): String {.cdecl,
    constructor, importcpp: "String(@)", header: "WString.h".}
proc destroyString*(this: var String) {.cdecl, importcpp: "#.~String()",
                                    header: "WString.h".}
proc length*(this: String): cuint {.noSideEffect, cdecl, importcpp: "length",
                                header: "WString.h".}
proc charAt*(this: String; index: cuint): char {.noSideEffect, cdecl,
    importcpp: "charAt", header: "WString.h".}
proc setCharAt*(this: var String; index: cuint; c: char) {.cdecl, importcpp: "setCharAt",
    header: "WString.h".}
proc `[]`*(this: String; index: cuint): char {.noSideEffect, cdecl, importcpp: "#[@]",
    header: "WString.h".}
proc `[]`*(this: var String; index: cuint): var char {.cdecl, importcpp: "#[@]",
    header: "WString.h".}
proc getBytes*(this: String; buf: ptr cuchar; bufsize: cuint; index: cuint = 0) {.
    noSideEffect, cdecl, importcpp: "getBytes", header: "WString.h".}
proc toCharArray*(this: String; buf: cstring; bufsize: cuint; index: cuint = 0) {.
    noSideEffect, cdecl, importcpp: "toCharArray", header: "WString.h".}
proc c_str*(this: String): cstring {.noSideEffect, cdecl, importcpp: "c_str",
                                 header: "WString.h".}
proc toInt*(this: String): clong {.noSideEffect, cdecl, importcpp: "toInt",
                               header: "WString.h".}
proc toFloat*(this: String): cfloat {.noSideEffect, cdecl, importcpp: "toFloat",
                                  header: "WString.h".}
proc toDouble*(this: String): cdouble {.noSideEffect, cdecl, importcpp: "toDouble",
                                    header: "WString.h".}


# Override built-in float to string conversion 
proc formatFloat*(f: float, format: FloatFormatMode = ffDefault,
                  precision: range[-1..32] = 16; decimalSep = '.'): string {.noSideEffect.} =
  var prec:cuchar = precision.cuchar
  var ff = constructString(f, prec)
  var fstr = $ff.c_str()
  var fnew = fstr
  ff.destroyString()
  return fnew

proc formatValue*(result: var string; value: SomeFloat; specifier: string) =
  result = formatFloat(value)

# proc `$`*(f: float): string = formatFloat(f)
# macro init_arduino*() =
  # result = quote do:
    # template `$`*(f: float32): string = formatFloat(f, precision=4)
    # template `$`*(f: float64): string = formatFloat(f, precision=6)

proc F_CPU*(): culong {.importcpp: "F_CPU@".}

template interrupts*() = {.emit:"sei();".}
template nointerrupts*() = {.emit:"cli();".}

proc pinMode*(pin: uint8; mode: uint8) {.importcpp: "pinMode(@)",
                                        header: "Arduino.h".}
proc digitalWrite*(pin: uint8; val: uint8) {.importcpp: "digitalWrite(@)",
    header: "Arduino.h".}
proc digitalRead*(pin: uint8): cint {.importcpp: "digitalRead(@)",
                                    header: "Arduino.h".}
proc analogRead*(pin: uint8): cint {.importcpp: "analogRead(@)", header: "Arduino.h".}
proc analogReference*(mode: uint8) {.importcpp: "analogReference(@)",
                                    header: "Arduino.h".}
proc analogWrite*(pin: uint8; val: cint) {.importcpp: "analogWrite(@)",
                                        header: "Arduino.h".}
proc millis*(): culong {.importcpp: "millis(@)", header: "Arduino.h".}
proc micros*(): culong {.importcpp: "micros(@)", header: "Arduino.h".}
proc delay*(ms: culong) {.importcpp: "delay(@)", header: "Arduino.h".}
proc delay*(ms: int) = delay(ms.culong)
proc delayMicroseconds*(us: cuint) {.importcpp: "delayMicroseconds(@)",
                                  header: "Arduino.h".}
proc pulseIn*(pin: uint8; state: uint8; timeout: culong): culong {.
    importcpp: "pulseIn(@)", header: "Arduino.h".}
proc pulseInLong*(pin: uint8; state: uint8; timeout: culong): culong {.
    importcpp: "pulseInLong(@)", header: "Arduino.h".}
proc shiftOut*(dataPin: uint8; clockPin: uint8; bitOrder: uint8; val: uint8) {.
    importcpp: "shiftOut(@)", header: "Arduino.h".}
proc shiftIn*(dataPin: uint8; clockPin: uint8; bitOrder: uint8): uint8 {.
    importcpp: "shiftIn(@)", header: "Arduino.h".}
proc attachInterrupt*(interruptNum: uint8; userFunc: proc (); mode: cint) {.
    importcpp: "attachInterrupt(@)", header: "Arduino.h".}
proc detachInterrupt*(interruptNum: uint8) {.importcpp: "detachInterrupt(@)",
    header: "Arduino.h".}

type
  # HardwareSerial* {.importcpp: "HardwareSerial", header: "Arduino.h", bycopy.} = object
  Stream* {.importcpp: "Stream", header: "Arduino.h", bycopy.} = object

var Serial* {.importcpp: "Serial", header: "Arduino.h".}: Stream
proc begin*(this: var Stream; baud: cint) {.importcpp: "begin", header: "Arduino.h".}
proc available*(this: var Stream): cint {.importcpp: "available", header: "Arduino.h".}
proc read*(this: var Stream): cint {.importcpp: "read", header: "Arduino.h".}
proc write*(this: var Stream; n: uint8): csize_t {.importcpp: "write", header: "HardwareSerial.h".}
proc print*(this: var Stream; s: cstring) {.importcpp: "print", header: "Arduino.h".}
proc println*(this: var Stream; s: cstring) {.importcpp: "println", header: "Arduino.h".}
proc pgmReadByte*(a: ptr uint8): uint8 {.importc:"pgm_read_byte", header:"avr/pgmspace.h" .}

# proc `$`*(f: float): string = WString.formatFloat(f)
# proc `$`*(f: float32): string = WString.formatFloat(f)
# proc `$`*(f: float64): string = WString.formatFloat(f)

var Stdout*: ptr Stream 
var Stdin*: ptr Stream 

proc write*(this: ptr Stream, msg: string) =
  this[].print(msg)
proc readLine*(this: ptr Stream): string =
  result = ""
  while (this[].available() > 0):
    result.add(this[].read().char)
  
proc echo*(msg: string) =
  Serial.println(msg)

# proc myputchar*(c: char, f: FILE): cint {.exportc,cdecl.} =
#   discard Serial.write(c.uint8).cint
#   result = 0

# proc fdevopen*(put: proc (a1: char; a2: FILE): cint {.cdecl.};
#                get: proc (a1: FILE): cint {.cdecl.} ): FILE {.importcpp: "fdevopen(@)", header: "stdio.h".}

# Convenience macros for the setup() and loop() functions

template setup*(code: untyped) =
  proc setup*() {.exportc.} =
    code 

template loop*(code: untyped) =
  proc loop*() {.exportc.} =
    code 

# Macro to move let sections in to PROGMEM

macro progmem*(n: untyped): untyped =
  n.expectKind(nnkStmtList)
  var n2 = nnkLetSection.newTree()
  for nl in n:
    nl.expectKind(nnkLetSection)
    n2.add nnkIdentDefs.newTree(
      nnkPragmaExpr.newTree(
        nl[0][0],
        nnkPragma.newTree(nnkExprColonExpr.newTree( newIdentNode("codegenDecl"), newLit("const $# PROGMEM $#")))
      ),
      nl[0][1], nl[0][2]
    )
  n2


