
NIMLIB := $(shell nim dump file.json 2>&1 | tail -n1)
NIMCACHE := $(PWD)/nimcache/

all: clean
	nim cpp --cpu:arm --os:any --gc:arc --exceptions:goto --no_main \
		-d:no_signal_handler -d:use_malloc --nimCache:"$(PWD)/nimcache" \
		--compile_only --gen_script nim_test.nim

	ls nimcache/*.cpp | sed 's/.cpp/.h/' | xargs -I%% touch %%
	cp -v $(NIMCACHE)/*.nim.cpp $(PWD)/.
	cp -v $(NIMLIB)/nimbase.h  $(PWD)/nimbase.h


clean:
	rm -Rf $(NIMCACHE)
	rm $(PWD)/*.cpp
	rm $(PWD)/*.h


