# Interactive Spry REPL
#
# Copyright (c) 2015 Göran Krampe
#
# I am not fond of REPLs, since I think they are silly dumb approximations
# of the real thing - a fully live environment like Smalltalk!
#
# But ok, its nice as a starter and for going through a tutorial :)

import strutils

# Basic Spry
import spryvm/spryvm

# Spry extra modules, as much as possible!
import spryvm/sprycore
import spryvm/sprylib
import spryvm/spryextend
import spryvm/sprymath
# import spryvm/spryos
# import spryvm/spryio
# import spryvm/sprymemfile
# import spryvm/sprythread
import spryvm/spryoo
# import spryvm/sprydebug
# import spryvm/sprycompress
import spryvm/sprystring
# import spryvm/sprymodules
# import spryvm/spryreflect
import spryvm/spryblock
# import spryvm/sprynet
# import spryvm/sprysmtp
# import spryvm/spryjson
# import spryvm/sprysqlite
# import spryvm/sprypython
# import spryvm/spryrocksdb

const Prompt = ">>> "

proc getLine(prompt: string): string =
  # Primitive fallback
  stdout.write(prompt)
  result = stdin.readline()

proc repl*() =
  # Let's create a Spry interpreter. It also holds all state.
  let spry = newInterpreter()

  # Add extra modules
  # spry.addCore()
  # spry.addString()
  # spry.addBlock()
  # spry.addLib()

  # spry.addExtend()
  # spry.addMath()
  # spry.addOS()
  # spry.addIO()
  # spry.addModules()
  # spry.addOO()

  # spry.addMemfile()
  # spry.addThread()
  # spry.addPython()
  # spry.addDebug()
  # spry.addCompress()
  # spry.addReflect()
  #spry.addRawUI()
  #spry.addUI() I think it does not play nice with readline etc
  # spry.addNet()
  # spry.addSMTP()
  # spry.addJSON()
  #spry.addSophia()
  # spry.addSqlite()
  # spry.addRocksDB()

  var
    lines, stashed = newSeq[string]()
    suspended: bool = true

  # Check if a file was given as input, if so collect lines
  # and set suspended = false which means we start out following the given
  # script instead of interactively.

  echo "Welcome to interactive Spry!"
  echo "An empty line will evaluate previous lines, so hit enter twice."
  # We collect lines until an empty line is entered, easy way to enter
  # multiline code.

  while true:
    var line: string
    line = getLine(Prompt)

    # Finally time to eval
    if line.strip().len() == 0:
      let code = lines.join("\n")
      lines = newSeq[string]()
      #try:
      # Let the interpreter eval the code. We need to eval whatever we
      # get (ispry acting as a func). The surrounding block is just because we only
      # want to pass one Node.
      var result = spry.evalRoot("[" & code & "]")
      #discard spry.setBinding(newEvalWord("@"), result)
      var output = $result
      # Print any result
      # if output.isNil:
        # output = if suspended: "nil" else: ""
      stdout.write(output & "\n")
#      except:
 #       echo "Oops, sorry about that: " & getCurrentExceptionMsg() & "\n"
  #      echo getStackTrace()
    else:
      lines.add(line)

repl()

