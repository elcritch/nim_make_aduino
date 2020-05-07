clang++ -c -std=gnu++14 -funsigned-char  -w -pthread -g  -I/Users/elcritch/.asdf/installs/nim/devel/lib -I/Volumes/datastore/projects/pt/third-party/nim_test -o stdlib_system.nim.cpp.o stdlib_system.nim.cpp
clang++ -c -std=gnu++14 -funsigned-char  -w -pthread -g  -I/Users/elcritch/.asdf/installs/nim/devel/lib -I/Volumes/datastore/projects/pt/third-party/nim_test -o @marduino.nim.cpp.o @marduino.nim.cpp
clang++ -c -std=gnu++14 -funsigned-char  -w -pthread -g  -I/Users/elcritch/.asdf/installs/nim/devel/lib -I/Volumes/datastore/projects/pt/third-party/nim_test -o @mnim_test.nim.cpp.o @mnim_test.nim.cpp
clang++   -o nim_test  stdlib_system.nim.cpp.o @marduino.nim.cpp.o @mnim_test.nim.cpp.o  -lm -pthread   -ldl
