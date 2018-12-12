CC=gcc
LINK=gcc

LDFLAGS=
#LDFLAGS=-static
#CFLAGS=-Wall -Wshadow -pedantic -std=gnu99 -I. -g
CFLAGS=-Wall -Wshadow -pedantic -std=gnu99 -Os
STRIP=strip --strip-all

TEST_TARGETS=\
	testcases/getppid\
	testcases/hello_world\
	testcases/pidgallore\
	testcases/sigalrm\
	testcases/sigpipe\
	testcases/sigsegv\
	testcases/sigalrm-sysv\
	testcases/highfd\
	testcases/noaddrrand\
	testcases/rdtsc\
	testcases/fork\
	testcases/exec\
	testcases/abort\
	testcases/sigalrm-uspace\
	testcases/sigalrm-sigsegv\
	testcases/nordtsc\
	testcases/timestamps\
	testcases/sigchld\
	testcases/sigprocmask\
	testcases/killsegv\
	testcases/fstat\
	testcases/rdtrunc\
	testcases/environ\
	testcases/newfs\
	testcases/newns\
	testcases/raise
#	testcases/intint\
#	testcases/sysall

TARGETS=$(TEST_TARGETS)\
	tools/hexdiff\
	examples/tracer/writeecho\
	examples/tracer/faketsc\
	examples/syscalls/nosignals\
	examples/maps/codecov\
	examples/syscalls/printregs

TRACER_OBJECTS=\
	tracer/dataset.o\
	tracer/debug.o\
	tracer/errors.o\
	tracer/signal_info.o\
	tracer/signal_queue.o\
	tracer/trace.o\
	tracer/trace_map.o\
	tracer/util.o\
	tracer/process.o

SYSCALLS_OBJECTS=\
	syscalls/debug_syscalls.o\
	syscalls/debug_wrap.o
#	syscalls/syscall_info.o\

MAPS_OBJECTS=\
	maps/maps.o

OBJECTS=$(TRACER_OBJECTS) $(SYSCALLS_OBJECTS) $(MAPS_OBJECTS)

CLEAN=$(TARGETS) $(OBJECTS)

.PHONY: depend clean strip

all: $(TARGETS)

strip: $(TARGETS)
	$(STRIP) --strip-all $^

$(OBJECTS): depend


tracer/%.o: tracer/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

maps/%.o: maps/%.c
	$(CC) $(CFLAGS) -Isyscalls -Itracer -c -o $@ $<

syscalls/%.o: syscalls/%.c
	$(CC) $(CFLAGS) -Itracer -c -o $@ $<



examples/tracer/%.o: examples/tracer/%.c
	$(CC) $(CFLAGS) -Itracer -c -o $@ $<

examples/tracer/%: examples/tracer/%.o $(TRACER_OBJECTS)
	$(LINK) -o $@ $^ $(LDFLAGS)



examples/syscalls/%.o: examples/syscalls/%.c
	$(CC) $(CFLAGS) -Isyscalls -Itracer -c -o $@ $<

examples/syscalls/%: examples/syscalls/%.o $(TRACER_OBJECTS) $(SYSCALLS_OBJECTS)
	$(LINK) -o $@ $^ $(LDFLAGS)



examples/maps/%.o: examples/maps/%.c
	$(CC) $(CFLAGS) -Imaps -Isyscalls -Itracer -c -o $@ $<

examples/maps/%: examples/maps/%.o $(TRACER_OBJECTS) $(SYSCALLS_OBJECTS) $(MAPS_OBJECTS)
	$(LINK) -o $@ $^ $(LDFLAGS)



tools/%.o: tools/%.c
	$(CC) $(CFLAGS) -Itracer -c -o $@ $<

tools/%: tools/%.o $(TRACER_OBJECTS)
	$(LINK) -o $@ $^ $(LDFLAGS)



testcases/%: testcases/%.c
	$(CC) $(CFLAGS) -o $@ $<

testcases/%: testcases/%.S
	$(CC) -nostdlib -o $@ $<


depend:
	#makedepend -- -Y. -- *.c test/*.c 2>/dev/null

clean:
	-rm $(CLEAN)
	#makedepend -- -Y. -- 2>/dev/null
	-rm Makefile.bak

# DO NOT DELETE
