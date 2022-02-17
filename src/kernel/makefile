export

ifeq ($(KERNDIR),)
KERNDIR != pwd
endif

ifeq ($(KERNBUILDDIR),)
KERNBUILDDIR := $(BUILDDIR)/kernel
endif

ifeq ($(KERNOBJDIR),)
KERNOBJDIR := $(KERNBUILDDIR)/obj
endif

KERNC = \
	  $(wildcard drivers/*/*.c) \
	  $(wildcard *.c)

KERNCPP = \
		$(wildcard drivers/*/*.cpp) \
		$(wildcard *.cpp)

KERNASM = \
		$(wildcard drivers/*/*.asm) \
		$(wildcard *.asm)

KERNOBJ = \
		$(patsubst %.c, %.o, $(KERNC)) \
		$(patsubst %.asm, %.s.o, $(KERNASM)) \
		$(patsubst %.cpp, %.o, $(KERNCPP))

KOBJF = $(KERNOBJ:%=$(KERNOBJDIR)/%)

CCFLAGS += \
		-I$(SOLUTIONDIR)/libs/vlib \
		-I$(KERNDIR)
CPPFLAGS= $(CCFLAGS) \
		-fno-rtti
AFLAGS =-f elf32

.PHONY: all makekerndir clean
all: \
	kernel.bin

%.s.o: %.asm
	@$(MKDIR) $(KERNOBJDIR)/$(@D)
	@$(ECHO) "[ASM   ]" $(KERNOBJDIR)/$@
	@$(ASM) $< $(AFLAGS) -o $(KERNOBJDIR)/$@
%.o: %.c
	@$(MKDIR) $(KERNOBJDIR)/$(@D)
	@$(ECHO) "[C     ]" $(KERNOBJDIR)/$@
	@$(CC) $(CCFLAGS) -c -o $(KERNOBJDIR)/$@ $<
%.o: %.cpp
	@$(MKDIR) $(KERNOBJDIR)/$(@D)
	@$(ECHO) "[CPP   ]" $(KERNOBJDIR)/$@
	@$(CC) $(CPPFLAGS) -c -o $(KERNOBJDIR)/$@ $<

kernel.bin: linker.ld $(KERNOBJ)
	@$(ECHO) "[LD    ]" $(KERNBUILDDIR)/$@
	@ld -m elf_i386 -T$< --oformat binary -o $(KERNBUILDDIR)/$@ $(KOBJF)
	@size=$$(stat -L -c %s $(KERNBUILDDIR)/$@);\
	newsize=$$(expr $$size - $$(expr $$size % 512) + 512);\
	echo "[\033[0;31mDEBUG \033[0;37m] $@" "$$size ($$(printf '0x%02X' $$(expr $$size / 512)) sectors) ->" "$$newsize ($$(printf '0x%02X' $$(expr $$newsize / 512)) sectors)";\
	chronic dd if=/dev/zero of=$(KERNBUILDDIR)/$@ bs=1 seek=$$size count=$$(expr $$newsize - $$size)

clean:
	@rm -r $(KERNBUILDDIR) || true