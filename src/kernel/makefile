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

KERNASM = \
		$(wildcard *.asm) \
		$(wildcard addition/*.asm)

KERNOBJ = \
		$(patsubst %.asm, %.o, $(KERNASM))

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

%.o: %.asm
	@$(MKDIR) $(KERNOBJDIR)/$(@D)
	@$(ECHO) "[ASM   ]" $(KERNOBJDIR)/$@
	@$(ASM) $< $(AFLAGS) -o $(KERNOBJDIR)/$@

kernel.bin: linker.ld $(KERNOBJ)
	@$(ECHO) "[LD    ]" $(KERNBUILDDIR)/$@
	@$(ECHO) "[\033[0;31mDEBUG \033[0;37m] Obj file: " $(KERNOBJ)
	@ld -m elf_i386 -T$< --oformat binary -o $(KERNBUILDDIR)/$@ $(KOBJF)
	@size=$$(stat -L -c %s $(KERNBUILDDIR)/$@);\
	newsize=$$(expr $$size - $$(expr $$size % 512) + 512);\
	echo "[\033[0;31mDEBUG \033[0;37m] $@" "$$size ($$(printf '0x%02X' $$(expr $$size / 512)) sectors) ->" "$$newsize ($$(printf '0x%02X' $$(expr $$newsize / 512)) sectors)";\
	chronic dd if=/dev/zero of=$(KERNBUILDDIR)/$@ bs=1 seek=$$size count=$$(expr $$newsize - $$size)

clean:
	@rm -r $(KERNBUILDDIR) || true