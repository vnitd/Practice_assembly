export

# CONFIG PART

OS_VERSION=0.2
OS_NAME=Base
OS_FILE_NAME=VNITDos-$(OS_NAME)_v$(OS_VERSION)
OS_IMG_FILE_TMP=$(OS_FILE_NAME).img
OS_ISO_FILE=$(OS_FILE_NAME).iso

# MAKE FILE PART

ifeq ($(SOLUTIONDIR),)
SOLUTIONDIR != pwd
endif

ifeq ($(SOURCEDIR),)
SOURCEDIR = $(SOLUTIONDIR)/src
endif

ifeq ($(BUILDDIR),)
BUILDDIR = $(SOLUTIONDIR)/build
endif

ifeq ($(CONFIG),)
CONFIG := vconfig
endif

include $(SOLUTIONDIR)/configs/$(CONFIG).mk

ifeq ($(CP),)
CP=cp
endif

ifeq ($(MKDIR),)
MKDIR=mkdir -p
endif

ifeq ($(ECHO),)
ECHO=echo
endif

ifeq ($(LN),)
LN=ln
endif

ifeq ($(BOOTDIR),)
BOOTDIR=$(SOURCEDIR)/boot
endif

ifeq ($(KERNDIR),)
KERNDIR=$(SOURCEDIR)/kernel
endif

OS_IMG_FILE = $(SOLUTIONDIR)/$(OS_IMG_FILE_TMP)

MAKEFLAGS += --no-print-directory


.PHONY: all clean
all: \
	clean \
	run
clean: \
	clean-all

.PHONY: build-all clean-all
build-all: \
	build-boot \
	build-kernel
clean-all: \
	clean-boot \
	clean-kernel
	@rm -r $(BUILDDIR) || true
	@rm -rf $(OS_ISO_FILE)

#
# boot target
#
.PHONY: build-boot clean-boot
build-boot:
	@$(ECHO) "\033[0;37m[MK    ]" $(BOOTDIR)/
	@$(MAKE) -C $(BOOTDIR)
clean-boot:
	@$(MAKE) -C $(BOOTDIR) clean

#
# kernel target
#
.PHONY: build-kernel clean-kernel
build-kernel:
	@$(ECHO) "[MK    ]" $(KERNDIR)/
	@$(MAKE) -C $(KERNDIR)
clean-kernel:
	@$(MAKE) -C $(KERNDIR) clean

#
# IMG Target
#
$(OS_IMG_FILE): build-all
	@$(ECHO) "[IMG   ]" $(OS_IMG_FILE)
	@cat $(wildcard build/*/*.bin) > $(BUILDDIR)/tmp.bin
	@$(ECHO) "[\033[0;31mDEBUG \033[0;37m]" $(wildcard build/*/*.bin)
	@chronic dd if=/dev/zero of=$@ bs=512 count=2880
	@chronic dd if=$(BUILDDIR)/tmp.bin of=$@ conv=notrunc

$(OS_ISO_FILE): $(OS_IMG_FILE)
	@$(ECHO) "[ISO   ]" $(OS_ISO_FILE)
	@$(MKDIR) ./iso
	@cp $< ./iso/VNITDos
	@mkisofs -b VNITDos -o $@ ./iso
	@rm -rf ./iso


run: $(OS_IMG_FILE)
	@qemu-system-x86_64 -drive format=raw,file=$<,if=ide,index=0,media=disk
#	@qemu-system-i386 $<

