/* Generated by Nim Compiler v1.2.0 */
/*   (c) 2020 Andreas Rumpf */
/* The generated code is subject to the original license. */
#define NIM_INTBITS 32
#define NIM_EmulateOverflowChecks

#include "nimbase.h"
#include <stdio.h>
#include "stdio.h"
#include "Arduino.h"
#undef LANGUAGE_C
#undef MIPSEB
#undef MIPSEL
#undef PPC
#undef R3000
#undef R4000
#undef i386
#undef linux
#undef mips
#undef near
#undef far
#undef powerpc
#undef unix
  #  define nimfr_(proc, file) \
      TFrame FR_; \
      FR_.procname = proc; FR_.filename = file; FR_.line = 0; FR_.len = 0; nimFrame(&FR_);

  #  define nimfrs_(proc, file, slots, length) \
      struct {TFrame* prev;NCSTRING procname;NI line;NCSTRING filename; NI len; VarSlot s[slots];} FR_; \
      FR_.procname = proc; FR_.filename = file; FR_.line = 0; FR_.len = length; nimFrame((TFrame*)&FR_);

  #  define nimln_(n, file) \
      FR_.line = n; FR_.filename = file;
  extern "C" N_LIB_PRIVATE N_NIMCALL(void, setup)(void);
extern "C" N_LIB_PRIVATE N_CDECL(int, myputchar)(NIM_CHAR c, FILE* f);
static N_INLINE(void, nimFrame)(TFrame* s);
N_LIB_PRIVATE N_NOINLINE(void, callDepthLimitReached__mMRdr4sgmnykA9aWeM9aDZlw)(void);
static N_INLINE(void, popFrame)(void);
extern "C" N_LIB_PRIVATE N_NIMCALL(void, loop)(void);
N_LIB_PRIVATE N_NIMCALL(void, nimTestErrorFlag)(void);
static N_INLINE(void, initStackBottomWith)(void* locals);
N_LIB_PRIVATE N_NIMCALL(void, systemDatInit000)(void);
N_LIB_PRIVATE N_NIMCALL(void, systemInit000)(void);
N_LIB_PRIVATE N_NIMCALL(void, NimMainModule)(void);
extern TFrame* framePtr__HRfVMH3jYeBJz6Q6X9b6Ptw;
extern TFrame* framePtr__HRfVMH3jYeBJz6Q6X9b6Ptw;
extern TFrame* framePtr__HRfVMH3jYeBJz6Q6X9b6Ptw;
extern TFrame* framePtr__HRfVMH3jYeBJz6Q6X9b6Ptw;
extern TFrame* framePtr__HRfVMH3jYeBJz6Q6X9b6Ptw;
extern TFrame* framePtr__HRfVMH3jYeBJz6Q6X9b6Ptw;
static N_INLINE(void, nimFrame)(TFrame* s) {
	{
		if (!(framePtr__HRfVMH3jYeBJz6Q6X9b6Ptw == NIM_NIL)) goto LA3_;
{		(*s).calldepth = ((NI16) 0);
}	}
	goto LA1_;
	LA3_: ;
	{
		(*s).calldepth = (NI16)((*framePtr__HRfVMH3jYeBJz6Q6X9b6Ptw).calldepth + ((NI16) 1));
	}
	LA1_: ;
	(*s).prev = framePtr__HRfVMH3jYeBJz6Q6X9b6Ptw;
	framePtr__HRfVMH3jYeBJz6Q6X9b6Ptw = s;
	{
		if (!((*s).calldepth == ((NI16) (((NI) 2000))))) goto LA8_;
{		callDepthLimitReached__mMRdr4sgmnykA9aWeM9aDZlw();
}	}
	LA8_: ;
}
static N_INLINE(void, popFrame)(void) {
	framePtr__HRfVMH3jYeBJz6Q6X9b6Ptw = (*framePtr__HRfVMH3jYeBJz6Q6X9b6Ptw).prev;
}
N_LIB_PRIVATE N_NIMCALL(void, setup)(void) {
	nimfr_("setup", "/home/elcritch/Arduino/nim_test/arduino.nim");
	nimln_(72, "/home/elcritch/Arduino/nim_test/arduino.nim");
	stdout = fdevopen(myputchar, NIM_NIL);
	nimln_(4, "/home/elcritch/Arduino/nim_test/nim_test.nim");
	pinMode(((NU8) 13), ((NU8) 1));
	popFrame();
}
N_LIB_PRIVATE N_NIMCALL(void, loop)(void) {
	nimfr_("loop", "/home/elcritch/Arduino/nim_test/arduino.nim");
	nimln_(7, "/home/elcritch/Arduino/nim_test/nim_test.nim");
	digitalWrite(((NU8) 13), ((NU8) 1));
	nimln_(8, "/home/elcritch/Arduino/nim_test/nim_test.nim");
	delay(((unsigned long) 500));
	nimln_(9, "/home/elcritch/Arduino/nim_test/nim_test.nim");
	digitalWrite(((NU8) 13), ((NU8) 0));
	nimln_(10, "/home/elcritch/Arduino/nim_test/nim_test.nim");
	delay(((unsigned long) 500));
	popFrame();
}
static N_INLINE(void, initStackBottomWith)(void* locals) {
}

N_LIB_PRIVATE void PreMainInner(void) {
}

N_LIB_PRIVATE int cmdCount;
N_LIB_PRIVATE char** cmdLine;
N_LIB_PRIVATE char** gEnv;
N_LIB_PRIVATE void PreMain(void) {
	void (*volatile inner)(void);
	inner = PreMainInner;
	systemDatInit000();
	initStackBottomWith((void *)&inner);
	systemInit000();
	(*inner)();
}

N_LIB_PRIVATE N_CDECL(void, NimMainInner)(void) {
	NimMainModule();
}

N_CDECL(void, NimMain)(void) {
	void (*volatile inner)(void);
	PreMain();
	inner = NimMainInner;
	initStackBottomWith((void *)&inner);
	(*inner)();
}

N_LIB_PRIVATE N_NIMCALL(void, NimMainModule)(void) {
{
}
}

