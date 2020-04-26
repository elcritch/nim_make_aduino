
NIMLIB := $(shell nim dump file.json 2>&1 | tail -n1)
NIMCACHE := nimcache
ARDUINO_BOARD := adafruit:samd:adafruit_itsybitsy_m4
NIM_PROGRAM := nim_test.nim

all: nim
	arduino-cli compile --fqbn $(ARDUINO_BOARD) -v $(PWD)/

nim: clean
	nim cpp --cpu:arm --os:any --gc:arc \
		--exceptions:goto --no_main --dead_code_elim:on --threads:off --tls_emulation:off \
		-d:no_signal_handler -d:use_malloc \
		--nim_cache:"$(PWD)/$(NIMCACHE)" \
		--compile_only --gen_script $(NIM_PROGRAM)

	@echo ls $(NIMCACHE)/*.cpp 
	cp -v $(NIMLIB)/nimbase.h  $(PWD)/nimbase.h
	ls $(NIMCACHE)/*.cpp | sed 's/.cpp/.h/' | sed 's|$(NIMCACHE)/||' | xargs -I%% touch %%
	ls $(NIMCACHE)/*.cpp | xargs -I%% ln -sf %% ./

upload:
	arduino-cli upload --fqbn $(ARDUINO_BOARD) -p $(device) $(PWD)

old:
	# cp -v $(NIMCACHE)/*.nim.cpp $(PWD)/.
	# ls nimcache/*.cpp | sed 's/.cpp/.h/' | xargs -I%% ln -sf %% ./


clean:
	rm -Rf $(NIMCACHE)
	rm -f *.bin *.elf
	rm -f *.cpp *.h
	# rm -Rf $(PWD)/*.cpp
	# rm -Rf $(PWD)/*.h

distclean: clean
	arduino-cli cache clean


deps:
	# arduino-cli lib install "Adafruit ADS1X15"
	# arduino-cli lib install ArduinoUniqueID 

