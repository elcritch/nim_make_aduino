import
  std/macros

export
  macros

type
  FieldDescription* = object
    name*: NimNode
    isPublic*: bool
    isDiscriminator*: bool
    typ*: NimNode
    pragmas*: NimNode
    caseField*: NimNode
    caseBranch*: NimNode

const
  nnkPragmaCallKinds = {nnkExprColonExpr, nnkCall, nnkCallStrLit}

proc findPragma*(pragmas: NimNode, pragmaSym: NimNode): NimNode =
  for p in pragmas:
    if p.kind in {nnkSym, nnkIdent} and eqIdent(p, pragmaSym):
      return p
    if p.kind in nnkPragmaCallKinds and p.len > 0 and eqIdent(p[0], pragmaSym):
      return p

func isTuple*(t: NimNode): bool =
  t.kind == nnkBracketExpr and t[0].kind == nnkSym and eqIdent(t[0], "tuple")

macro isTuple*(T: type): untyped =
  newLit(isTuple(getType(T)[1]))

template readPragma*(field: FieldDescription, pragmaName: static string): NimNode =
  let p = findPragma(field.pragmas, bindSym(pragmaName))
  if p != nil and p.len == 2: p[1] else: p

proc recordFieldsAux(result: var seq[FieldDescription],
                     n: NimNode,
                     parentCaseField: NimNode = nil,
                     parentCaseBranch: NimNode = nil,
                     isDiscriminator = false) =
  case n.kind
  of nnkRecList:
    for entry in n:
      recordFieldsAux result, entry,
                      parentCaseField, parentCaseBranch
  of nnkRecWhen:
    for branch in n:
      case branch.kind:
      of nnkElifBranch:
        recordFieldsAux result, branch[1],
                        parentCaseField, parentCaseBranch
      of nnkElse:
        recordFieldsAux result, branch[0],
                        parentCaseField, parentCaseBranch
      else:
        doAssert false

  of nnkRecCase:
    recordFieldsAux result, n[0],
                    parentCaseField,
                    parentCaseBranch,
                    isDiscriminator = true

    for i in 1 ..< n.len:
      let branch = n[i]
      case branch.kind
      of nnkOfBranch:
        recordFieldsAux result, branch[^1], n[0], branch
      of nnkElse:
        recordFieldsAux result, branch[0], n[0], branch
      else:
        doAssert false

  of nnkIdentDefs:
    let fieldType = n[^2]
    for i in 0 ..< n.len - 2:
      var field: FieldDescription
      field.name = n[i]
      field.typ = fieldType
      field.caseField = parentCaseField
      field.caseBranch = parentCaseBranch
      field.isDiscriminator = isDiscriminator

      if field.name.kind == nnkPragmaExpr:
        field.pragmas = field.name[1]
        field.name = field.name[0]

      if field.name.kind == nnkPostfix:
        field.isPublic = true
        field.name = field.name[1]

      result.add field

  of nnkNilLit, nnkDiscardStmt, nnkCommentStmt, nnkEmpty:
    discard

  else:
    doAssert false, "Unexpected nodes in recordFields:\n" & n.treeRepr

proc recordFields*(typeImpl: NimNode): seq[FieldDescription] =
  # TODO: This doesn't support inheritance yet
  if typeImpl.isTuple:
    for i in 1 ..< typeImpl.len:
      result.add FieldDescription(typ: typeImpl[i], name: ident("Field" & $(i - 1)))
    return

  var objectType = typeImpl[2]
  if objectType.kind == nnkRefTy:
    objectType = objectType[0]

  let recList = objectType[2]
  recordFieldsAux result, recList

macro field*(obj: typed, fieldName: static string): untyped =
  newDotExpr(obj, ident fieldName)

proc skipPragma*(n: NimNode): NimNode =
  if n.kind == nnkPragmaExpr: n[0]
  else: n

macro hasCustomPragmaFixed*(T: type, field: static string, pragma: typed{nkSym}): untyped =
  let Tresolved = getType(T)[1]
  if isTuple(Tresolved):
    return newLit(false)

  for f in recordFields(Tresolved.getImpl):
    var fieldName = f.name
    # TODO: Fix this in eqIdent
    if fieldName.kind == nnkAccQuoted: fieldName = fieldName[0]
    if eqIdent(fieldName, field):
      return newLit(f.pragmas.findPragma(pragma) != nil)

  error "The type " & $Tresolved & " doesn't have a field named " & field

proc humaneTypeName*(typedescNode: NimNode): string =
  var t = getType(typedescNode)[1]
  if t.kind != nnkBracketExpr:
    let tImpl = t.getImpl
    if tImpl != nil and tImpl.kind notin {nnkEmpty, nnkNilLit}:
      t = tImpl

  repr(t)

macro inspectType*(T: typed): untyped =
  echo "Inspect type: ", humaneTypeName(T)

# FIXED NewLit

proc newLitFixed*(c: char): NimNode {.compileTime.} =
  ## Produces a new character literal node.
  result = newNimNode(nnkCharLit)
  result.intVal = ord(c)

proc newLitFixed*(i: int): NimNode {.compileTime.} =
  ## Produces a new integer literal node.
  result = newNimNode(nnkIntLit)
  result.intVal = i

proc newLitFixed*(i: int8): NimNode {.compileTime.} =
  ## Produces a new integer literal node.
  result = newNimNode(nnkInt8Lit)
  result.intVal = i

proc newLitFixed*(i: int16): NimNode {.compileTime.} =
  ## Produces a new integer literal node.
  result = newNimNode(nnkInt16Lit)
  result.intVal = i

proc newLitFixed*(i: int32): NimNode {.compileTime.} =
  ## Produces a new integer literal node.
  result = newNimNode(nnkInt32Lit)
  result.intVal = i

proc newLitFixed*(i: int64): NimNode {.compileTime.} =
  ## Produces a new integer literal node.
  result = newNimNode(nnkInt64Lit)
  result.intVal = i

proc newLitFixed*(i: uint): NimNode {.compileTime.} =
  ## Produces a new unsigned integer literal node.
  result = newNimNode(nnkUIntLit)
  result.intVal = BiggestInt(i)

proc newLitFixed*(i: uint8): NimNode {.compileTime.} =
  ## Produces a new unsigned integer literal node.
  result = newNimNode(nnkUInt8Lit)
  result.intVal = BiggestInt(i)

proc newLitFixed*(i: uint16): NimNode {.compileTime.} =
  ## Produces a new unsigned integer literal node.
  result = newNimNode(nnkUInt16Lit)
  result.intVal = BiggestInt(i)

proc newLitFixed*(i: uint32): NimNode {.compileTime.} =
  ## Produces a new unsigned integer literal node.
  result = newNimNode(nnkUInt32Lit)
  result.intVal = BiggestInt(i)

proc newLitFixed*(i: uint64): NimNode {.compileTime.} =
  ## Produces a new unsigned integer literal node.
  result = newNimNode(nnkUInt64Lit)
  result.intVal = BiggestInt(i)

proc newLitFixed*(b: bool): NimNode {.compileTime.} =
  ## Produces a new boolean literal node.
  result = if b: bindSym"true" else: bindSym"false"

proc newLitFixed*(s: string): NimNode {.compileTime.} =
  ## Produces a new string literal node.
  result = newNimNode(nnkStrLit)
  result.strVal = s

when false:
  # the float type is not really a distinct type as described in https://github.com/nim-lang/Nim/issues/5875
  proc newLitFixed*(f: float): NimNode {.compileTime.} =
    ## Produces a new float literal node.
    result = newNimNode(nnkFloatLit)
    result.floatVal = f

proc newLitFixed*(f: float32): NimNode {.compileTime.} =
  ## Produces a new float literal node.
  result = newNimNode(nnkFloat32Lit)
  result.floatVal = f

proc newLitFixed*(f: float64): NimNode {.compileTime.} =
  ## Produces a new float literal node.
  result = newNimNode(nnkFloat64Lit)
  result.floatVal = f

when declared(float128):
  proc newLitFixed*(f: float128): NimNode {.compileTime.} =
    ## Produces a new float literal node.
    result = newNimNode(nnkFloat128Lit)
    result.floatVal = f

proc newLitFixed*(arg: enum): NimNode {.compileTime.} =
  result = newCall(
    arg.type.getTypeInst[1],
    newLitFixed(int(arg))
  )

proc newLitFixed*[N,T](arg: array[N,T]): NimNode {.compileTime.}
proc newLitFixed*[T](arg: seq[T]): NimNode {.compileTime.}
proc newLitFixed*[T](s: set[T]): NimNode {.compileTime.}
proc newLitFixed*(arg: tuple): NimNode {.compileTime.}

proc newLitFixed*(arg: object): NimNode {.compileTime.} =
  result = nnkObjConstr.newTree(arg.type.getTypeInst[1])
  for a, b in arg.fieldPairs:
    result.add nnkExprColonExpr.newTree( newIdentNode(a), newLitFixed(b) )

proc newLitFixed*(arg: ref object): NimNode {.compileTime.} =
  ## produces a new ref type literal node.
  result = nnkObjConstr.newTree(arg.type.getTypeInst[1])
  for a, b in fieldPairs(arg[]):
    result.add nnkExprColonExpr.newTree(newIdentNode(a), newLitFixed(b))

proc newLitFixed*[N,T](arg: array[N,T]): NimNode {.compileTime.} =
  result = nnkBracket.newTree
  for x in arg:
    result.add newLitFixed(x)

proc newLitFixed*[T](arg: seq[T]): NimNode {.compileTime.} =
  let bracket = nnkBracket.newTree
  for x in arg:
    bracket.add newLitFixed(x)
  result = nnkPrefix.newTree(
    bindSym"@",
    bracket
  )
  if arg.len == 0:
    # add type cast for empty seq
    var typ = getTypeInst(typeof(arg))[1]
    result = newCall(typ,result)

proc newLitFixed*[T](s: set[T]): NimNode {.compileTime.} =
  result = nnkCurly.newTree
  for x in s:
    result.add newLitFixed(x)

proc newLitFixed*(arg: tuple): NimNode {.compileTime.} =
  result = nnkPar.newTree
  for a,b in arg.fieldPairs:
    result.add nnkExprColonExpr.newTree(newIdentNode(a), newLitFixed(b))

iterator typedParams*(n: NimNode, skip = 0): (NimNode, NimNode) =
  let params = n[3]
  for i in (1 + skip) ..< params.len:
    let paramNodes = params[i]
    let paramType = paramNodes[^2]

    for j in 0 ..< paramNodes.len - 2:
      yield (paramNodes[j], paramType)

macro unpackArgs*(callee: typed, args: untyped): untyped =
  result = newCall(callee)
  for arg in args:
    let arg = if arg.kind == nnkHiddenStdConv: arg[1]
              else: arg
    if arg.kind == nnkArgList:
      for subarg in arg:
        result.add subarg
    else:
      result.add arg

template genCode*(body: untyped) =
  iterator generator: NimNode = body

  macro payload: untyped =
    result = newStmtList()
    for node in generator():
      result.add node

  payload()

template genExpr*(body: untyped) =
  macro payload: untyped = body
  payload()

