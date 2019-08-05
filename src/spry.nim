# Spry Language executable
#
# Copyright (c) 2015 Göran Krampe

# Enable when profiling
when defined(profiler):
  import nimprof

import os, parseopt

import spryvm/spryvm

import spryvm/sprycore, spryvm/sprylib, spryvm/spryextend, spryvm/sprymath,
  spryvm/spryos, spryvm/spryio, spryvm/sprymemfile, spryvm/sprythread,
  spryvm/spryoo, spryvm/sprydebug, spryvm/sprycompress, spryvm/sprystring,
  spryvm/sprymodules, spryvm/spryreflect, spryvm/spryui, spryvm/spryblock, spryvm/sprynet,
  spryvm/sprysmtp, spryvm/spryjson, spryvm/sprysqlite, spryvm/sprypython

var spry = newInterpreter()

# Add extra modules
spry.addCore()
spry.addExtend()
spry.addMath()
spry.addOS()
spry.addIO()
spry.addMemfile()
spry.addThread()
spry.addPython()
spry.addOO()
spry.addDebug()
spry.addCompress()
spry.addString()
spry.addModules()
spry.addReflect()
#spry.addRawUI()
spry.addUI()
spry.addBlock()
spry.addNet()
spry.addSMTP()
spry.addJSON()
#spry.addSophia()
spry.addSqlite()
spry.addLib()

let doc = """

Usage:
  spry [options] <path-or-stdin>

Options:
  -e --eval "code"    Evaluates Spry code given as string
  -h --help           Show this screen
  -v --version        Show version of Spry
"""

proc writeVersion() =
  echo "Spry 0.8.0"

proc writeHelp() =
  writeVersion()
  echo doc
  quit()

var
  filename: string
  eval = false
  code: string

for kind, key, val in getopt():
  case kind
  of cmdArgument:
    filename = key
  of cmdLongOption, cmdShortOption:
    case key
    of "help", "h":
      writeHelp()
    of "version", "v":
      writeVersion()
      quit()
    of "eval", "e": eval = true
    else: discard
  of cmdEnd: assert(false) # cannot happen

if eval:
  if filename == nil:
    writeHelp()
  else:
    code = filename
else:
  code =
    if filename == nil:
      # no filename has been given, so we use stdin
      readAll stdin
    else:
      readFile(filename)

discard spry.eval("[" & code & "]")
