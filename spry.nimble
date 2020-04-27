# Package
version       = "0.8.0"
author        = "Göran Krampe"
description   = "Homoiconic dynamic language in Nim"
license       = "MIT"
bin           = @["spry","ispry"]
srcDir        = "src"
binDir        = "bin"
skipExt       = @["nim"]
backend       = "cpp"

# Deps
requires "https://github.com/elcritch/spryvm.git"

