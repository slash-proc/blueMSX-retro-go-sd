# blueMSX — standalone Retro-Go SD dynamic core
#
#   make              — build + pack → blueMSX.bin
#   make host         — SDL desktop preview (Linux/macOS)
#   make docker       — same device build inside Docker
#
# BIOS ROMs live under /bios/msx/ on the SD card; msxromdb.bin too.
# Build a local tree (also used by host later + release zip):
#   make bios
# Verbose compiler lines: make V=

#######################################
# Project identity
#######################################
PROJECT_KIND ?= core

CORE_NAME  := msx
CORE_ENTRY := app_main_msx

CORE_MSX := src/blueMSX-go
LIBRETRO_COMM_DIR := $(CORE_MSX)/libretro-common
CORE_PORTING_MSX := src/porting/msx

CORE_C_SOURCES := \
$(CORE_MSX)/Src/Libretro/Timer.c \
$(CORE_MSX)/Src/Libretro/Emulator.c \
$(CORE_MSX)/Src/Bios/Patch.c \
$(CORE_MSX)/Src/Memory/DeviceManager.c \
$(CORE_MSX)/Src/Memory/IoPort.c \
$(CORE_MSX)/Src/Memory/MegaromCartridge.c \
$(CORE_MSX)/Src/Memory/ramNormal.c \
$(CORE_MSX)/Src/Memory/ramMapper.c \
$(CORE_MSX)/Src/Memory/ramMapperIo.c \
$(CORE_MSX)/Src/Memory/RomLoader.c \
$(CORE_MSX)/Src/Memory/romMapperASCII8.c \
$(CORE_MSX)/Src/Memory/romMapperASCII16.c \
$(CORE_MSX)/Src/Memory/romMapperASCII16X.c \
$(CORE_MSX)/Src/Memory/romMapperNEO16.c \
$(CORE_MSX)/Src/Memory/romMapperASCII16nf.c \
$(CORE_MSX)/Src/Memory/romMapperBasic.c \
$(CORE_MSX)/Src/Memory/romMapperCasette.c \
$(CORE_MSX)/Src/Memory/romMapperDRAM.c \
$(CORE_MSX)/Src/Memory/romMapperF4device.c \
$(CORE_MSX)/Src/Memory/romMapperKoei.c \
$(CORE_MSX)/Src/Memory/romMapperKonami4.c \
$(CORE_MSX)/Src/Memory/romMapperKonami4nf.c \
$(CORE_MSX)/Src/Memory/romMapperKonami5.c \
$(CORE_MSX)/Src/Memory/romMapperLodeRunner.c \
$(CORE_MSX)/Src/Memory/romMapperMsxDos2.c \
$(CORE_MSX)/Src/Memory/romMapperMsxMusic.c \
$(CORE_MSX)/Src/Memory/romMapperNormal.c \
$(CORE_MSX)/Src/Memory/romMapperPlain.c \
$(CORE_MSX)/Src/Memory/romMapperRType.c \
$(CORE_MSX)/Src/Memory/romMapperStandard.c \
$(CORE_MSX)/Src/Memory/romMapperSunriseIDE.c \
$(CORE_MSX)/Src/Memory/romMapperSCCplus.c \
$(CORE_MSX)/Src/Memory/romMapperTC8566AF.c \
$(CORE_MSX)/Src/Memory/SlotManager.c \
$(CORE_MSX)/Src/VideoChips/VDP_YJK_gnw.c \
$(CORE_MSX)/Src/VideoChips/VDP_MSX.c \
$(CORE_MSX)/Src/VideoChips/V9938.c \
$(CORE_MSX)/Src/VideoChips/VideoManager.c \
$(CORE_MSX)/Src/Z80/R800.c \
$(CORE_MSX)/Src/Z80/R800SaveState.c \
$(CORE_MSX)/Src/Input/JoystickPort.c \
$(CORE_MSX)/Src/Input/MsxJoystick.c \
$(CORE_MSX)/Src/IoDevice/Disk.c \
$(CORE_MSX)/Src/IoDevice/HarddiskIDE.c \
$(CORE_MSX)/Src/IoDevice/I8255.c \
$(CORE_MSX)/Src/IoDevice/MsxPPI.c \
$(CORE_MSX)/Src/IoDevice/RTC.c \
$(CORE_MSX)/Src/IoDevice/SunriseIDE.c \
$(CORE_MSX)/Src/IoDevice/TC8566AF.c \
$(CORE_MSX)/Src/SoundChips/AudioMixer.c \
$(CORE_MSX)/Src/SoundChips/AY8910.c \
$(CORE_MSX)/Src/SoundChips/SCC.c \
$(CORE_MSX)/Src/SoundChips/MsxPsg.c \
$(CORE_MSX)/Src/SoundChips/YM2413_msx.c \
$(CORE_MSX)/Src/SoundChips/emu2413_msx.c \
$(CORE_MSX)/Src/Emulator/AppConfig.c \
$(CORE_MSX)/Src/Emulator/LaunchFile.c \
$(CORE_MSX)/Src/Emulator/Properties.c \
$(CORE_MSX)/Src/Utils/IsFileExtension.c \
$(CORE_MSX)/Src/Utils/StrcmpNoCase.c \
$(CORE_MSX)/Src/Utils/TokenExtract.c \
$(CORE_MSX)/Src/Board/Board.c \
$(CORE_MSX)/Src/Board/Machine.c \
$(CORE_MSX)/Src/Board/MSX.c \
$(CORE_MSX)/Src/Input/InputEvent.c \
$(CORE_PORTING_MSX)/main_msx.c \
$(CORE_PORTING_MSX)/msx_i18n.c \
$(CORE_PORTING_MSX)/msx_database.c \
$(CORE_PORTING_MSX)/save_msx.c

CORE_C_INCLUDES := \
-I$(CORE_MSX) \
-I$(LIBRETRO_COMM_DIR)/include \
-I$(CORE_MSX)/Src/Arch \
-I$(CORE_MSX)/Src/Bios \
-I$(CORE_MSX)/Src/Board \
-I$(CORE_MSX)/Src/BuildInfo \
-I$(CORE_MSX)/Src/Common \
-I$(CORE_MSX)/Src/Debugger \
-I$(CORE_MSX)/Src/Emulator \
-I$(CORE_MSX)/Src/IoDevice \
-I$(CORE_MSX)/Src/Language \
-I$(CORE_MSX)/Src/Media \
-I$(CORE_MSX)/Src/Memory \
-I$(CORE_MSX)/Src/Resources \
-I$(CORE_MSX)/Src/SoundChips \
-I$(CORE_MSX)/Src/TinyXML \
-I$(CORE_MSX)/Src/Utils \
-I$(CORE_MSX)/Src/VideoChips \
-I$(CORE_MSX)/Src/VideoRender \
-I$(CORE_MSX)/Src/Z80 \
-I$(CORE_MSX)/Src/Input \
-I$(CORE_MSX)/Src/Libretro \
-I$(CORE_PORTING_MSX)/include

# Relative path so Docker bind-mounts work (do NOT use $(abspath)).
GNW_CORE_SDK ?= sdk
BUILD_DIR ?= build/$(PROJECT_KIND)

#######################################
# Kind-specific compile defs + packing
#######################################
ifeq ($(PROJECT_KIND),core)
# COVERFLOW+CHEAT_CODES must match firmware layout (ACTIVE_FILE->cheat_*).
# blueMSX SlotManager references MAX_CHEAT_CODES.
CORE_C_DEFS := \
-DPROJECT_KIND_CORE=1 \
-DTARGET_GNW \
-D__LIBRETRO__ \
-DZ80_CUSTOM_CONFIGURATION \
-DNO_EMBEDDED_SAMPLES \
-DMSX_NO_ZIP \
-DMSX_NO_FILESYSTEM \
-DMSX_NO_MALLOC \
-DMAX_VIDEO_WIDTH_320 \
-DPIXEL_WIDTH=8 \
-DMSX_NO_STEREO \
-DMSX_USE_BANK_2=0 \
-DCOVERFLOW=1 \
-DCHEAT_CODES=1 \
-DMAX_CHEAT_CODES=13

PACKED_BIN  := blueMSX.bin
PAD_LOGO    := src/assets/pad.bmp
HEADER_LOGO := src/assets/header.bmp

# ITCM for R800 + SlotManager; hot structs use DTCM (dtc_*), not ITCM data.
CORE_LDSCRIPT := msx_core.ld
CORE_EXTRA_SEGMENTS := itcm:core_itcm

# emu2413 rate converter builds a sinc table with sin/cos at init.
CORE_LDLIBS := -lm

else
$(error This project builds PROJECT_KIND=core only (got '$(PROJECT_KIND)'))
endif

include $(GNW_CORE_SDK)/Makefile

PACK_CORE := $(GNW_CORE_SDK)/tools/pack_core.py

# Hot-path units at -O2 (default OPT is -Os).
MSX_CFLAGS_O2 = $(filter-out -Os,$(CFLAGS)) -O2

$(BUILD_DIR)/R800.o:              CFLAGS := $(MSX_CFLAGS_O2)
$(BUILD_DIR)/SlotManager.o:       CFLAGS := $(MSX_CFLAGS_O2)
$(BUILD_DIR)/IoPort.o:            CFLAGS := $(MSX_CFLAGS_O2)
$(BUILD_DIR)/DeviceManager.o:     CFLAGS := $(MSX_CFLAGS_O2)
$(BUILD_DIR)/ramNormal.o:         CFLAGS := $(MSX_CFLAGS_O2)
$(BUILD_DIR)/ramMapper.o:         CFLAGS := $(MSX_CFLAGS_O2)
$(BUILD_DIR)/romMapperNormal.o:   CFLAGS := $(MSX_CFLAGS_O2)
$(BUILD_DIR)/romMapperASCII8.o:   CFLAGS := $(MSX_CFLAGS_O2)
$(BUILD_DIR)/romMapperASCII16.o:  CFLAGS := $(MSX_CFLAGS_O2)
$(BUILD_DIR)/romMapperKonami4.o:  CFLAGS := $(MSX_CFLAGS_O2)
$(BUILD_DIR)/romMapperKonami5.o:  CFLAGS := $(MSX_CFLAGS_O2)
$(BUILD_DIR)/romMapperSCCplus.o:  CFLAGS := $(MSX_CFLAGS_O2)
$(BUILD_DIR)/VDP_MSX.o:           CFLAGS := $(MSX_CFLAGS_O2)
$(BUILD_DIR)/V9938.o:             CFLAGS := $(MSX_CFLAGS_O2)
$(BUILD_DIR)/VDP_YJK_gnw.o:       CFLAGS := $(MSX_CFLAGS_O2)
$(BUILD_DIR)/AudioMixer.o:        CFLAGS := $(MSX_CFLAGS_O2)
$(BUILD_DIR)/AY8910.o:            CFLAGS := $(MSX_CFLAGS_O2)
$(BUILD_DIR)/SCC.o:               CFLAGS := $(MSX_CFLAGS_O2)
$(BUILD_DIR)/MsxPsg.o:            CFLAGS := $(MSX_CFLAGS_O2)
$(BUILD_DIR)/YM2413_msx.o:        CFLAGS := $(MSX_CFLAGS_O2)
$(BUILD_DIR)/emu2413_msx.o:       CFLAGS := $(MSX_CFLAGS_O2)
$(BUILD_DIR)/main_msx.o:          CFLAGS := $(MSX_CFLAGS_O2)

#######################################
# Pack
#######################################
.PHONY: pack

pack: $(TARGET_BIN) $(BUILD_DIR)/$(CORE_NAME)_core_itcm.bin $(PAD_LOGO) $(HEADER_LOGO)
	$(V)$(ECHO) [ PACK CORE ] $(PACKED_BIN)
	$(V)python3 $(PACK_CORE) \
		--elf $(TARGET_ELF) --bin $(TARGET_BIN) \
		--system name="MSX",dirname=msx,pad_logo=$(PAD_LOGO),header_logo=$(HEADER_LOGO),ext="dsk rom mx1 mx2 cdk lzma",parse=rom,cheat_ext=mcf \
		--logo-invert \
		--core-name "blueMSX" \
		--version 1.0.0 \
		--out $(PACKED_BIN)

all: pack

.PHONY: print-PROJECT_KIND print-PACKED_BIN print-SIDECARS print-RO_BIN print-CORE_NAME print-DOCKER_IMAGE \
	print-TARGET_ELF print-TARGET_MAP print-CORE_VERSION
print-PROJECT_KIND:
	@echo $(PROJECT_KIND)
print-PACKED_BIN:
	@echo $(PACKED_BIN)
# Empty here: only a project that installs a second device file beside its
# binary sets RO_BIN. The shared stage_release.py reads it for every project
# so the script itself needs no per-project variant.
# Extra device files installed beside PACKED_BIN, space separated.
print-SIDECARS:
	@echo $(SIDECARS)
print-RO_BIN:
	@echo $(RO_BIN)
print-CORE_NAME:
	@echo $(CORE_NAME)
print-DOCKER_IMAGE:
	@echo $(DOCKER_IMAGE)
print-TARGET_ELF:
	@echo $(TARGET_ELF)
print-TARGET_MAP:
	@echo $(BUILD_DIR)/$(CORE_NAME)_core.map

clean::
	$(V)rm -f $(PACKED_BIN)

#######################################
# BIOS (/bios/msx for SD + host)
#######################################
.PHONY: bios prepare_msx_bios

# Copies Shared Roms from vendored src/blueMSX-go/system (or BLUEMSX_SYSTEM=…).
# Builds msxromdb.bin into bios/msx/.
bios prepare_msx_bios:
	$(V)$(ECHO) [ BIOS ] bios/msx
	$(V)python3 scripts/prepare_msx_bios.py \
		$(if $(BLUEMSX_SYSTEM),--source $(BLUEMSX_SYSTEM),)

#######################################
# Docker (same image as firmware repo)
#######################################
.PHONY: docker docker_pull docker_shell

RELEASE_VERSION ?= v1.5
DOCKER_REPOSITORY ?= sylverb/retro-go-sd-builder
DOCKER_IMAGE ?= $(DOCKER_REPOSITORY):$(RELEASE_VERSION)

DOCKER_TTY_FLAG := $(shell if [ -t 0 ]; then echo -it; else echo; fi)
DOCKER_USER := $(shell id -u):$(shell id -g)
DOCKER_RUN := docker run --rm $(DOCKER_TTY_FLAG) \
	--user $(DOCKER_USER) \
	-v "$(CURDIR):/opt/workdir" \
	-w /opt/workdir \
	$(DOCKER_IMAGE)

docker:
	$(V)$(ECHO) "[ DOCKER ]" $(DOCKER_IMAGE) "PROJECT_KIND=$(PROJECT_KIND)"
	$(V)$(DOCKER_RUN) make --no-print-directory -j$$(nproc) PROJECT_KIND=$(PROJECT_KIND)

docker_pull:
	$(V)$(ECHO) "[ PULL ]" $(DOCKER_IMAGE)
	$(V)docker pull $(DOCKER_IMAGE)

docker_shell:
	$(DOCKER_RUN) bash

#######################################
# Host SDL preview (Linux / macOS)
#######################################
HOST_BIN := blueMSX_host
include host/Makefile.host
