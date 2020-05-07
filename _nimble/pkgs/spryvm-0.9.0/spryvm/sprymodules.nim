import spryvm

# Spry Modules module
proc addModules*(spry: Interpreter) =
  # Modules Spry support code
  discard spry.evalRoot """[
    # Load a Module from a string
    loadString: = func [:code
      map = eval parse code
      loadMap: map as: ((map at: '_meta) at: 'name)
    ]

    loadString:as: = func [:code :name
      loadMap: (eval parse code) as: name
    ]

    loadFile: = func [
      loadString: readFile :fileName]

    loadFile:as: = func [
      loadString: (readFile :fileName) as: :name]

    loadMap:as: = func [:map :name
      # Make a module of the map (tagging it)
      m = module map
      # Insert module at given name
      root at: name put: m
      # Add module last in modules (for shadowed global lookup)
      modules add: m
      true
    ]

    existsFile "spry.sy" then: [
      #echo "Loading spry.sy ..."
      loadFile: "spry.sy"
    ]
  ]"""

