
NIMLIB := $(shell nim dump file.json 2>&1 | tail -n1)
NIMCACHE := nimcache

all: clean
	nim cpp --cpu:arm --os:any --gc:arc --exceptions:goto --no_main \
		-d:no_signal_handler -d:use_malloc --nimCache:"$(PWD)/$(NIMCACHE)" \
		--compile_only --gen_script nim_test.nim

	@echo ls $(NIMCACHE)/*.cpp 
	cp -v $(NIMLIB)/nimbase.h  $(PWD)/nimbase.h
	ls $(NIMCACHE)/*.cpp | sed 's/.cpp/.h/' | sed 's|$(NIMCACHE)/||' | xargs -I%% touch %%
	ls $(NIMCACHE)/*.cpp | xargs -I%% ln -sf %% ./

old:
	# cp -v $(NIMCACHE)/*.nim.cpp $(PWD)/.
	# ls nimcache/*.cpp | sed 's/.cpp/.h/' | xargs -I%% ln -sf %% ./

clean:
	rm -Rf $(NIMCACHE)
	# rm -Rf $(PWD)/*.cpp
	# rm -Rf $(PWD)/*.h


