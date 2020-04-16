
NIMLIB := $(shell nim dump file.json 2>&1 | tail -n1)
NIMCACHE := $(PWD)/nimcache/

all:
	rm -Rf $(NIMCACHE)
	nim cpp --cpu:arm --os:any --gc:arc --exceptions:goto --no_main \
		-d:no_signal_handler -d:use_malloc --nimCache:"$(PWD)/nimcache" \
		--compile_only --gen_script nim_test.nim

	touch $(NIMCACHE)/stdlib_system.nim.h $(NIMCACHE)/@marduino.nim.h $(NIMCACHE)/@mnim_test.nim.h

	# touch stdlib_system.nim.h @marduino.nim.h @mnim_test.nim.h
	# cp -v $(NIMCACHE)/*.nim.cpp $(PWD)/.
	# cp -v $(NIMLIB)/nimbase.h  $(NIMCACHE)/nimbase.h
	# cp -v $(NIMLIB)/nimbase.h  $(PWD)/nimbase.h



