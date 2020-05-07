#
#
#            Nim's Runtime Library
#        (c) Copyright 2017 Nim Authors
#        (c) Copyright 2019 Status Research
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

## This module implements a series of low level methods for bit manipulation.
## By default, this module use compiler intrinsics to improve performance
## on supported compilers: ``GCC``, ``LLVM_GCC``, ``CLANG``, ``VCC``, ``ICC``.
##
## The module will fallback to pure nim procs incase the backend is not supported.
## You can also use the flag `noIntrinsicsBitOpts` to disable compiler intrinsics.
##
## This module is also compatible with other backends: ``Javascript``, ``Nimscript``
## as well as the ``compiletime VM``.

{.push raises: [].}

const
  useBuiltins = not defined(noIntrinsicsBitOpts)

template bitsof*(T: typedesc[SomeInteger]): int = 8 * sizeof(T)
template bitsof*(x: SomeInteger): int = 8 * sizeof(x)

type BitIndexable = SomeUnsignedInt

# #### Pure Nim version ####

func nextPow2Nim(x: SomeUnsignedInt): SomeUnsignedInt =
  var v = x - 1

  # round down, make sure all bits are 1 below the threshold, then add 1
  v = v or v shr 1
  v = v or v shr 2
  v = v or v shr 4
  when bitsof(x) > 8:
    v = v or v shr 8
  when bitsof(x) > 16:
    v = v or v shr 16
  when bitsof(x) > 32:
    v = v or v shr 32

  v + 1

func firstOneNim(x: uint32): int =
  ## Returns the 1-based index of the least significant set bit of x, or if x is zero, returns zero.
  # https://graphics.stanford.edu/%7Eseander/bithacks.html#ZerosOnRightMultLookup
  const lookup = [0'u8, 1, 28, 2, 29, 14, 24, 3, 30, 22, 20, 15,
    25, 17, 4, 8, 31, 27, 13, 23, 21, 19, 16, 7, 26, 12, 18, 6, 11, 5, 10, 9]
  if x == 0:
    0
  else:
    let k = not x + 1 # get two's complement
    1 + lookup[((x and k) * 0x077CB531'u32) shr 27].int

func firstOneNim(x: uint8|uint16): int = firstOneNim(x.uint32)
func firstOneNim(x: uint64): int =
  ## Returns the 1-based index of the least significant set bit of x, or if x is zero, returns zero.
  # https://graphics.stanford.edu/%7Eseander/bithacks.html#ZerosOnRightMultLookup

  template convert[T](x: uint64): T =
    when nimvm:
      T(x and high(T))
    else:
      cast[T](x)

  if convert[uint32](x) == 0:
    32 + firstOneNim(uint32(x shr 32'u32))
  else:
    firstOneNim(uint32(x))

func log2truncNim(x: uint8|uint16|uint32): int =
  ## Quickly find the log base 2 of a 32-bit or less integer.
  # https://graphics.stanford.edu/%7Eseander/bithacks.html#IntegerLogDeBruijn
  # https://stackoverflow.com/questions/11376288/fast-computing-of-log2-for-64-bit-integers
  const lookup: array[32, uint8] = [0'u8, 9, 1, 10, 13, 21, 2, 29, 11, 14, 16, 18,
    22, 25, 3, 30, 8, 12, 20, 28, 15, 17, 24, 7, 19, 27, 23, 6, 26, 5, 4, 31]
  var v = x.uint32
  v = v or v shr 1 # first round down to one less than a power of 2
  v = v or v shr 2
  v = v or v shr 4
  v = v or v shr 8
  v = v or v shr 16
  lookup[uint32(v * 0x07C4ACDD'u32) shr 27].int

func log2truncNim(x: uint64): int =
  ## Quickly find the log base 2 of a 64-bit integer.
  # https://graphics.stanford.edu/%7Eseander/bithacks.html#IntegerLogDeBruijn
  # https://stackoverflow.com/questions/11376288/fast-computing-of-log2-for-64-bit-integers
  const lookup: array[64, uint8] = [0'u8, 58, 1, 59, 47, 53, 2, 60, 39, 48, 27, 54,
    33, 42, 3, 61, 51, 37, 40, 49, 18, 28, 20, 55, 30, 34, 11, 43, 14, 22, 4, 62,
    57, 46, 52, 38, 26, 32, 41, 50, 36, 17, 19, 29, 10, 13, 21, 56, 45, 25, 31,
    35, 16, 9, 12, 44, 24, 15, 8, 23, 7, 6, 5, 63]
  var v = x
  v = v or v shr 1 # first round down to one less than a power of 2
  v = v or v shr 2
  v = v or v shr 4
  v = v or v shr 8
  v = v or v shr 16
  v = v or v shr 32
  lookup[(v * 0x03F6EAF2CD271461'u64) shr 58].int

func countOnesNim(x: uint8|uint16|uint32): int =
  ## Counts the set bits in integer. (also called Hamming weight.)
  # generic formula is from: https://graphics.stanford.edu/~seander/bithacks.html#CountBitsSetParallel

  var v = x.uint32
  v = v - ((v shr 1) and 0x55555555)
  v = (v and 0x33333333) + ((v shr 2) and 0x33333333)
  (((v + (v shr 4) and 0xF0F0F0F) * 0x1010101) shr 24).int

func countOnesNim(x: uint64): int =
  ## Counts the set bits in integer. (also called Hamming weight.)
  # generic formula is from: https://graphics.stanford.edu/~seander/bithacks.html#CountBitsSetParallel
  var v = x
  v = v - ((v shr 1'u64) and 0x5555555555555555'u64)
  v = (v and 0x3333333333333333'u64) + ((v shr 2'u64) and 0x3333333333333333'u64)
  v = (v + (v shr 4'u64) and 0x0F0F0F0F0F0F0F0F'u64)
  ((v * 0x0101010101010101'u64) shr 56'u64).int

func parityNim(x: SomeUnsignedInt): int =
  # formula id from: https://graphics.stanford.edu/%7Eseander/bithacks.html#ParityParallel
  var v = x
  when sizeof(v) == 8:
    v = v xor (v shr 32)
  when sizeof(v) >= 4:
    v = v xor (v shr 16)
  when sizeof(v) >= 2:
    v = v xor (v shr 8)
  v = v xor (v shr 4)
  v = v and 0xf
  ((0x6996'u shr v) and 1).int

when (defined(gcc) or defined(llvm_gcc) or defined(clang)) and useBuiltins:

  # Returns the number of set 1-bits in value.
  func builtin_popcount(x: cuint): cint {.importc: "__builtin_popcount", nodecl.}
  func builtin_popcountll(x: culonglong): cint {.importc: "__builtin_popcountll", nodecl.}

  # Returns the bit parity in value
  func builtin_parity(x: cuint): cint {.importc: "__builtin_parity", nodecl.}
  func builtin_parityll(x: culonglong): cint {.importc: "__builtin_parityll", nodecl.}

  # Returns one plus the index of the least significant 1-bit of x, or if x is zero, returns zero.
  func builtin_ffs(x: cint): cint {.importc: "__builtin_ffs", nodecl.}
  func builtin_ffsll(x: clonglong): cint {.importc: "__builtin_ffsll", nodecl.}

  # Returns the number of leading 0-bits in x, starting at the most significant bit position. If x is 0, the result is undefined.
  func builtin_clz(x: cuint): cint {.importc: "__builtin_clz", nodecl.}
  func builtin_clzll(x: culonglong): cint {.importc: "__builtin_clzll", nodecl.}

  func countOnesBuiltin(x: SomeUnsignedInt): int =
    when bitsof(x) == bitsof(culonglong):
      builtin_popcountll(x).int
    else:
      builtin_popcount(x).int

  func parityBuiltin(x: SomeUnsignedInt): int =
    when bitsof(x) == bitsof(culonglong):
      builtin_parityll(x)
    else:
      builtin_parity(x)

  func firstOneBuiltin(x: SomeUnsignedInt): int =
    when bitsof(x) == bitsof(culonglong):
      builtin_ffsll(x)
    else:
      builtin_ffs(x.cuint.cint)

  func log2truncBuiltin(v: uint8|uint16|uint32): int = 31 - builtin_clz(v.uint32)
  func log2truncBuiltin(v: uint64): int = 63 - builtin_clzll(v)

elif defined(icc) and useBuiltins:
  const arch64 = sizeof(int) == 8

  # Counts the number of one bits (population count) in a 16-, 32-, or 64-byte unsigned integer.
  func builtin_popcnt16(a2: uint16): uint16 {.importc: "__popcnt16" header: "<intrin.h>".}
  func builtin_popcnt32(a2: uint32): uint32 {.importc: "__popcnt" header: "<intrin.h>".}

  # Search the mask data from most significant bit (MSB) to least significant bit (LSB) for a set bit (1).
  func bitScanReverse(index: ptr culong, mask: culong): cuchar {.importc: "_BitScanReverse", header: "<intrin.h>".}

  # Search the mask data from least significant bit (LSB) to the most significant bit (MSB) for a set bit (1).
  func bitScanForward(index: ptr culong, mask: culong): cuchar {.importc: "_BitScanForward", header: "<intrin.h>".}

  when arch64:
    func builtin_popcnt64(a2: uint64): uint64 {.importc: "__popcnt64" header: "<intrin.h>".}
    func bitScanReverse64(index: ptr culong, mask: uint64): cuchar {.importc: "_BitScanReverse64", header: "<intrin.h>".}
    func bitScanForward64(index: ptr culong, mask: uint64): cuchar {.importc: "_BitScanForward64", header: "<intrin.h>".}

  template checkedScan(fnc: untyped, x: typed, def: typed): int =
    var index{.noinit.}: culong
    if fnc(index.addr, v) == 0: def
    else: index.int

  template checkedScan(fnc: untyped, x: typed, def: typed): int =
    var index{.noinit.}: culong
    discard fnc(index.addr, v)
    index.int

  func countOnesBuiltin(v: uint8|uint16): int = builtin_popcnt16(v.uint16).int
  func countOnesBuiltin(v: uint32): int = builtin_popcnt32(v).int
  func countOnesBuiltin(v: uint64): int =
    when arch64:
      builtin_popcnt64(v).int
    else:
      builtin_popcnt32((v and 0xFFFFFFFF'u64).uint32).int +
        builtin_popcnt32((v shr 32'u64).uint32).int

  func firstOneBuiltin(v: uint8|uint16|uint32): int =
    1 + checkedScan(bitScanForward, v.culong, -1)

  func firstOneBuiltin(v: uint64): int =
    when arch64:
      1 + checkedScan(bitScanForward64, v.culong, -1)
    else:
      firstOneNim(v)

  func log2truncBuiltin(v: uint8|uint16|uint32): int =
    bitScan(bitScanReverse, v.culong)

  func log2truncBuiltin(v: uint64): int =
    when arch64:
      bitScan(bitScanReverse64, v.culong)
    else:
      log2truncNim(v)

elif defined(vcc) and useBuiltins:
  const arch64 = sizeof(int) == 8

  # Intel compiler intrinsics: http://fulla.fnal.gov/intel/compiler_c/main_cls/intref_cls/common/intref_allia_misc.htm
  # see also: https://software.intel.com/en-us/node/523362
  # Count the number of bits set to 1 in an integer a, and return that count in dst.
  func builtin_popcnt32(x: cint): cint {.importc: "_popcnt" header: "<immintrin.h>".}

  # Returns the number of trailing 0-bits in x, starting at the least significant bit position. If x is 0, the result is undefined.
  func bitScanForward(p: ptr uint32, b: uint32): cuchar {.importc: "_BitScanForward", header: "<immintrin.h>".}

  # Returns the number of leading 0-bits in x, starting at the most significant bit position. If x is 0, the result is undefined.
  func bitScanReverse(p: ptr uint32, b: uint32): cuchar {.importc: "_BitScanReverse", header: "<immintrin.h>".}

  when arch64:
    func builtin_popcnt64(x: uint64): cint {.importc: "_popcnt64" header: "<immintrin.h>".}
    func bitScanForward64(p: ptr uint32, b: uint64): cuchar {.importc: "_BitScanForward64", header: "<immintrin.h>".}
    func bitScanReverse64(p: ptr uint32, b: uint64): cuchar {.importc: "_BitScanReverse64", header: "<immintrin.h>".}

  template checkedScan(fnc: untyped, x: typed, def: typed): int =
    var index{.noinit.}: culong
    if fnc(index.addr, v) == 0: def
    else: index.int

  template bitScan(fnc: untyped, x: typed): int =
    var index{.noinit.}: culong
    if fnc(index.addr, v) == 0: 0
    else: index.int

  func countOnesBuiltin(v: uint8|uint16|uint32): int = builtin_popcnt32(v.uint32).int
  func countOnesBuiltin(v: uint64): int =
    when arch64:
      builtin_popcnt64(v).int
    else:
      builtin_popcnt32((v and 0xFFFFFFFF'u64).uint32).int +
        builtin_popcnt32((v shr 32'u64).uint32).int

  func firstOneBuiltin(v: uint8|uint16|uint32): int =
    1 + checkedScan(bitScanForward, v.culong, -1)

  func firstOneBuiltin(v: uint64): int =
    when arch64:
      1 + checkedScan(bitScanForward64, v.culong, -1)
    else:
      firstOneNim(v)

  func log2truncBuiltin(v: uint8|uint16|uint32): int =
    bitScan(bitScanReverse, v.culong)

  func log2truncBuiltin(v: uint64): int =
    when arch64:
      bitScan(bitScanReverse64, v.culong)
    else:
      log2truncNim(v)

func countOnes*(x: SomeUnsignedInt): int {.inline.} =
  ## Counts the set bits in integer. (also called `Hamming weight`:idx:.)
  ##
  ## Example:
  ## doAssert countOnes(0b01000100'u8) == 2
  # TODO: figure out if ICC support _popcnt32/_popcnt64 on platform without POPCNT.
  # like GCC and MSVC
  when nimvm:
    countOnesNim(x)
  else:
    when defined(countOnesBuiltin):
      countOnesBuiltin(x)
    else:
      countOnesNim(x)

func countZeros*(x: SomeUnsignedInt): int {.inline.} =
  sizeof(x) - countOnes(x)

func parity*(x: SomeUnsignedInt): int {.inline.} =
  ## Calculate the bit parity in integer. If number of 1-bit
  ## is odd parity is 1, otherwise 0.
  ##
  ## Example:
  ## doAssert parity(0b00000001'u8) == 1
  # Can be used a base if creating ASM version.
  # https://stackoverflow.com/questions/21617970/how-to-check-if-value-has-even-parity-of-bits-or-odd
  when nimvm:
    parityNim(x)
  else:
    when defined parityBuiltin:
      parityBuiltin(x)
    else:
      parityNim(x)

func firstOne*(x: SomeUnsignedInt): int {.inline.} =
  ## Returns the 1-based index of the least significant set bit of x.
  ## If `x` is zero result is 0
  ##
  ## firstOne(x) == trailingZeros(x) + 1
  ##
  ## Example:
  ## doAssert firstOneBit(0b00000010'u8) == 2
  ##
  when nimvm:
    firstOneNim(x)
  else:
    when defined(firstOneBuiltin):
      firstOneBuiltin(x)
    else:
      firstOneNim(x)

func log2trunc*(x: SomeUnsignedInt): int {.inline.} =
  ## Return the truncated base 2 logarithm of `x` - this is the zero-based
  ## index of the last set bit.
  ##
  ## If `x` is zero result is -1
  ##
  ## log2trunc(x) == bitsof(x) - leadingZeros(x) - 1.
  ##
  ## Example:
  ## doAssert log2trunc(0b01001000'u8) == 6
  if x == 0: -1
  else:
    when nimvm:
      log2truncNim(x)
    else:
      when defined(log2truncBuiltin):
        log2truncBuiltin(x)
      else:
        log2truncNim(x)

template bitWidth*(x: SomeUnsignedInt): int =
  ## Returns the number of bits needed to write down the
  ## number `x` in binary. If `x` is zero, the result is 0.
  log2trunc(x) + 1

func leadingZeros*(x: SomeInteger): int {.inline.} =
  ## Returns the number of leading zero bits in integer.
  ## If `x` is zero, result is bitsof(x)
  ##
  ## Example:
  ## doAssert leadingZeros(0b00000000'u8) == 8
  ## doAssert leadingZeros(0b00100000'u8) == 2
  ##
  # Performance note:
  # On recent x86_64 cpu's, this translates to the LZCNT instruction
  bitsof(x) - 1 - log2trunc(x)

func trailingZeros*(x: SomeUnsignedInt): int {.inline.} =
  ## Returns the number of trailing zeros in integer.
  ## If `x` is zero, result is sizeof(x) * 8
  ##
  ## Example:
  ## doAssert trailingZeros(0b00000010'u8) == 1
  ##
  # Performance note:
  # On recent x86_64 cpu's, this translates to the TZCNT instruction
  if x == 0:
    bitsof(x)
  else:
    firstOne(x) - 1

func nextPow2*(x: SomeUnsignedInt): SomeUnsignedInt {.inline.} =
  ## Calculate the next power-of-2 of x - wraps to 0
  ##
  ## Examples:
  ## doAssert nextPow2(3) == 4
  ## doAssert nextPow2(4) == 4
  nextPow2Nim(x)

func rotateLeft*(v: SomeUnsignedInt, amount: SomeInteger):
    SomeUnsignedInt {.inline.} =
  ## Left-rotate bits in an unsigned value
  # using this form instead of the one below should handle any value
  # out of range as well as negative values.
  # taken from: https://en.wikipedia.org/wiki/Circular_shift#Implementing_circular_shifts
  const mask = 8 * sizeof(v) - 1
  let amount = int(amount and mask)
  (v shl amount) or (v shr ( (-amount) and mask))

func rotateRight*(v: SomeUnsignedInt, amount: SomeInteger):
    SomeUnsignedInt {.inline.} =
  ## Right-rotate bits in an unsigned value.
  const mask = bitsof(v) - 1
  let amount = int(amount and mask)
  (v shr amount) or (v shl ( (-amount) and mask))

template mostSignificantBit(T: type): auto =
  const res = 1 shl (sizeof(T) * 8 - 1)
  T(res)

template getBit*(x: BitIndexable, bit: Natural): bool =
  ## reads a bit from `x`, assuming 0 to be the position of the
  ## least significant bit
  type T = type(x)
  ((x shr bit) and T(1)) != 0

template getBitLE*(x: BitIndexable, bit: Natural): bool =
  getBit(x, bit)

template getBitBE*(x: BitIndexable, bit: Natural): bool =
  ## Reads a bit from `x`, assuming 0 to be the position of
  ## the most significant bit.
  ##
  ## This indexing may be natural when you are considering the
  ## string representation of a bit field. For example, 72 can
  ## be written in binary as 0b01001000. The first bit here is
  ## zero, while the second bit is one.
  ##
  ## Since the string representation will depend on the size of
  ## the operand, using `getBitBE` with the same numeric value
  ## and a bit position may produce different results depending
  ## on the machine type used to store the value. For this reason,
  ## this indexing scheme is considered more error-prone and
  ## `getBitLE` is considering the default indexing scheme.
  (x and mostSignificantBit(x.type) shr bit) != 0

func changeBit*(x: var BitIndexable, bit: Natural, val: bool) {.inline.} =
  ## changes a bit in `x` to val, assuming 0 to be the position of the
  ## least significant bit
  type T = type(x)
  x = (x and not (T(1) shl bit)) or (T(val) shl bit)

template changeBitLE*(x: var BitIndexable, bit: Natural, val: bool) =
  setBit(x, bit, val)

func changeBitBE*(x: var BitIndexable, bit: Natural, val: bool) {.inline.} =
  ## changes a bit in `x` to val, assuming 0 to be the position of the
  ## most significant bit
  changeBit(x, bitsof(x) - 1 - bit, val)

func setBit*(x: var BitIndexable, bit: Natural) {.inline.} =
  ## sets bit in `x`, assuming 0 to be the position of the
  ## least significant bit
  type T = type(x)
  let mask = T(1) shl bit
  x = x or mask

template setBitLE*(x: var BitIndexable, bit: Natural) =
  setBit(x, bit)

func setBitBE*(x: var BitIndexable, bit: Natural) {.inline.} =
  ## sets a bit in `x`, assuming 0 to be the position of the
  ## most significant bit
  let mask = mostSignificantBit(x.type) shr bit
  x = x or mask

func clearBit*(x: var BitIndexable, bit: Natural) {.inline.} =
  ## clears bit in a byte, assuming 0 to be the position of the
  ## least significant bit
  type T = type(x)
  let mask = T(1) shl bit
  x = x and not mask

template clearBitLE*(x: var BitIndexable, bit: Natural) =
  clearBit(x, bit)

func clearBitBE*(x: var BitIndexable, bit: Natural) {.inline.} =
  ## clears a bit in `x`, assuming 0 to be the position of the
  ## most significant bit
  let mask = mostSignificantBit(x.type) shr bit
  x = x and not mask

func toggleBit*(x: var BitIndexable, bit: Natural) {.inline.} =
  ## toggles (inverts) bit in `x`, assuming 0 to be the position of the
  ## least significant bit
  type T = type(x)
  let mask = T(1) shl bit
  x = x xor mask

template toggleBitLE*(x: var BitIndexable, bit: Natural) =
  toggleBit(x, bit)

func toggleBitBE*(x: var BitIndexable, bit: Natural) {.inline.} =
  ## toggles (inverts) a bit in `x`, assuming 0 to be the position of the
  ## most significant bit
  let mask = mostSignificantBit(x.type) shr bit
  x = x xor mask

template byteIndex(pos: Natural): int =
  pos shr 3 # same as pos div 8

template bitIndex(pos: Natural): int =
  pos and 0b111 # same as pos mod 8

func getBit*(bytes: openarray[byte], pos: Natural): bool {.inline.} =
  getBit(bytes[byteIndex pos], bitIndex pos)

template getBitLE*(bytes: openarray[byte], pos: Natural): bool =
  getBit(bytes, pos)

func getBitBE*(bytes: openarray[byte], pos: Natural): bool {.inline.} =
  getBitBE(bytes[byteIndex pos], bitIndex pos)

func changeBit*(bytes: var openarray[byte], pos: Natural, value: bool) {.inline.} =
  changeBit(bytes[byteIndex pos], bitIndex pos, value)

template changeBitLE*(bytes: var openarray[byte], pos: Natural, value: bool) =
  changeBit(bytes, pos, value)

func changeBitBE*(bytes: var openarray[byte], pos: Natural, value: bool) {.inline.} =
  changeBitBE(bytes[byteIndex pos], bitIndex pos, value)

func setBit*(bytes: var openarray[byte], pos: Natural) {.inline.} =
  setBit(bytes[byteIndex pos], bitIndex pos)

template setBitLE*(bytes: var openarray[byte], pos: Natural) =
  setBit(bytes, pos)

func setBitBE*(bytes: var openarray[byte], pos: Natural) {.inline.} =
  setBitBE(bytes[byteIndex pos], bitIndex pos)

func clearBit*(bytes: var openarray[byte], pos: Natural) {.inline.} =
  clearBit(bytes[byteIndex pos], bitIndex pos)

template clearBitLE*(bytes: var openarray[byte], pos: Natural) =
  clearBit(bytes, pos)

func clearBitBE*(bytes: var openarray[byte], pos: Natural) {.inline.} =
  clearBitBE(bytes[byteIndex pos], bitIndex pos)

func toggleBit*(bytes: var openarray[byte], pos: Natural) {.inline.} =
  toggleBit(bytes[byteIndex pos], bitIndex pos)

template toggleBitLE*(bytes: var openarray[byte], pos: Natural) =
  toggleBit(bytes, pos)

func toggleBitBE*(bytes: var openarray[byte], pos: Natural) {.inline.} =
  toggleBitBE(bytes[byteIndex pos], bitIndex pos)

template setBit*(x: var BitIndexable, bit: Natural, val: bool) {.deprecated: "changeBit".} =
  changeBit(x, bit, val)
template setBitLE*(x: var BitIndexable, bit: Natural, val: bool) {.deprecated: "changeBitLE".} =
  changeBitLE(x, bit, val)
template setBitBE*(x: var BitIndexable, bit: Natural, val: bool) {.deprecated: "changeBitBE".} =
  changeBitBE(x, bit, val)

template raiseBit*(x: var BitIndexable, bit: Natural) {.deprecated: "setBit".} =
  setBit(x, bit)
template raiseBitLE*(x: var BitIndexable, bit: Natural) {.deprecated: "setBitLE".} =
  setBitLE(x, bit)
template raiseBitBE*(x: var BitIndexable, bit: Natural) {.deprecated: "setBitBE".} =
  setBitBE(x, bit)

func lowerBit*(x: var BitIndexable, bit: Natural) {.inline, deprecated: "clearBit".} =
  clearBit(x, bit)
template lowerBitLE*(x: var BitIndexable, bit: Natural) {.deprecated: "clearBitLE".} =
  clearBit(x, bit)
template lowerBitBE*(x: var BitIndexable, bit: Natural) {.deprecated: "clearBitBE".} =
  clearBitBE(x, bit)

template setBit*(bytes: var openarray[byte], pos: Natural, val: bool) {.deprecated: "changeBit".} =
  changeBit(bytes, pos, val)
template setBitLE*(bytes: var openarray[byte], pos: Natural, val: bool) {.deprecated: "changeBitLE".} =
  changeBitLE(bytes, pos, val)
template setBitBE*(bytes: var openarray[byte], pos: Natural, val: bool) {.deprecated: "changeBitBE".} =
  changeBitBE(bytes, pos, val)

template raiseBit*(bytes: var openarray[byte], pos: Natural) {.deprecated: "setBit".} =
  setBit(bytes, pos)
template raiseBitLE*(bytes: var openarray[byte], pos: Natural) {.deprecated: "setBitLE".} =
  setBitLE(bytes, pos)
template raiseBitBE*(bytes: var openarray[byte], pos: Natural) {.deprecated: "setBitBE".} =
  setBitBE(bytes, pos)

template lowerBit*(bytes: var openarray[byte], pos: Natural) {.deprecated: "clearBit".} =
  clearBit(bytes, pos)
template lowerBitLE*(bytes: var openarray[byte], pos: Natural) {.deprecated: "clearBitLE".} =
  clearBitLE(bytes, pos)
template lowerBitBE*(bytes: var openarray[byte], pos: Natural) {.deprecated: "clearBitBE".} =
  clearBitBE(bytes, pos)
