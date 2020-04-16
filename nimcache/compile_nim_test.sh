g++ -c  -w -w -fpermissive  -std=gnu++14 -funsigned-char  -I/home/elcritch/.asdf/installs/nim/1.2.0/lib -I/home/elcritch/Arduino/nim_test -o stdlib_system.nim.cpp.o stdlib_system.nim.cpp
g++ -c  -w -w -fpermissive  -std=gnu++14 -funsigned-char  -I/home/elcritch/.asdf/installs/nim/1.2.0/lib -I/home/elcritch/Arduino/nim_test -o @marduino.nim.cpp.o @marduino.nim.cpp
g++ -c  -w -w -fpermissive  -std=gnu++14 -funsigned-char  -I/home/elcritch/.asdf/installs/nim/1.2.0/lib -I/home/elcritch/Arduino/nim_test -o @mnim_test.nim.cpp.o @mnim_test.nim.cpp
g++   -o nim_test  stdlib_system.nim.cpp.o @marduino.nim.cpp.o @mnim_test.nim.cpp.o    
