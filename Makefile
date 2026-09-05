# Retro-Go SD — MSX / MSX2 / MSX2+ (blueMSX) standalone dynamic core.
#
#   make                  — build + pack → msx.bin
#   make docker           — same inside the firmware builder image
#
# Sources: external/blueMSX-go (submodule, pinned to the commit the firmware
# uses) plus the firmware's Core/Src/porting/msx glue, copied to src/porting.
#
# BIOS: this core reads up to ten files from /bios/msx/ at run time — the
# machine ROMs for MSX1/MSX2/MSX2+, PANASONICDISK.rom for disk images,
# Nextor.rom for large ones, and the optional msxromdb.bin game database.
# None ship here; blueMSX-go carries them under system/bluemsx/.

#######################################
# Project identity
#######################################
PROJECT_KIND ?= core

CORE_NAME  := msx
CORE_ENTRY := app_main_msx

CORE_MSX          := external/blueMSX-go
LIBRETRO_COMM_DIR := $(CORE_MSX)/libretro-common

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
src/porting/msx_i18n.c \
src/porting/msx_database.c \
src/porting/save_msx.c \
src/porting/main_msx.c

CORE_C_INCLUDES := \
-Isrc/porting \
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
-I$(CORE_MSX)/Src/Input

# Adds _MSX_ROM_UNPACK_BUFFER over the SDK default — see ld/msx_core.ld.
CORE_LDSCRIPT := ld/msx_core.ld
# emu2413's windowed_sinc() uses cos/sin; nothing else here needs libm.
CORE_LDLIBS := -lm

GNW_CORE_SDK ?= sdk
BUILD_DIR ?= build/$(PROJECT_KIND)

#######################################
# Kind-specific compile defs + packing
#######################################
ifeq ($(PROJECT_KIND),core)
# GNW_DISABLE_COMPRESSION: the SD build never decompresses a ROM, and the
# firmware defines it unconditionally for SD. It also drops the lzma.h
# include, which the SDK does not ship.
#
# ahb_only_malloc → ahb_malloc: UNVERIFIED ON HARDWARE. blueMSX's YJK colour
# table (VDP_YJK_gnw.c, 64 KiB) asks for AHB specifically, bypassing RAM_EMU.
# The firmware has that allocator; the dynamic-core ABI does not — mem_ctl's
# GW_MEM_AHB maps to ahb_calloc, which tries RAM_EMU first. So this 64 KiB may
# come out of the core's RAM_EMU budget instead of AHB, and MSX2+ Screen
# 10/11/12 is where that would show. Needs either an ABI append exposing an
# AHB-only pool, or confirmation that the budget absorbs it.
CORE_C_DEFS := \
-DPROJECT_KIND_CORE=1 \
-DCOVERFLOW=1 \
-DCHEAT_CODES=1 \
-DMAX_CHEAT_CODES=13 \
-DGNW_DISABLE_COMPRESSION \
-DTARGET_GNW \
-D__LIBRETRO__ \
-DZ80_CUSTOM_CONFIGURATION \
-DNO_EMBEDDED_SAMPLES \
-DMSX_NO_ZIP \
-DMSX_NO_FILESYSTEM \
-DMSX_NO_MALLOC \
-DMSX_NO_STEREO \
-DMAX_VIDEO_WIDTH_320 \
-DPIXEL_WIDTH=8 \
-DVIDEO_RGB565 \
-Dahb_only_malloc=ahb_malloc

PACKED_BIN  := $(CORE_NAME).bin
PAD_LOGO    := src/assets/pad.png
HEADER_LOGO := src/assets/header.png

else ifeq ($(PROJECT_KIND),homebrew)
$(error MSX is a dynamic core only — use PROJECT_KIND=core)
else
$(error PROJECT_KIND must be 'core' (got '$(PROJECT_KIND)'))
endif

include $(GNW_CORE_SDK)/Makefile

PACK_CORE := $(GNW_CORE_SDK)/tools/pack_core.py

#######################################
# Packed header version
#######################################
CORE_VERSION ?= $(shell git describe --tags --dirty 2>/dev/null || echo NOTAG)

#######################################
# Pack
#######################################
.PHONY: pack

pack: $(TARGET_BIN) $(PAD_LOGO) $(HEADER_LOGO)
	$(V)$(ECHO) [ PACK CORE ] $(PACKED_BIN) version=$(CORE_VERSION)
	$(V)python3 $(PACK_CORE) \
		--elf $(TARGET_ELF) --bin $(TARGET_BIN) \
		--system-name "MSX" --dirname msx \
		--extensions "dsk rom mx1 mx2 cdk" \
		--core-name "blueMSX" \
		--version "$(CORE_VERSION)" \
		--cheat-ext mcf \
		--pad-logo $(PAD_LOGO) \
		--header-logo $(HEADER_LOGO) \
		--out $(PACKED_BIN)

all: pack

.PHONY: print-PROJECT_KIND print-PACKED_BIN print-RO_BIN print-CORE_NAME print-DOCKER_IMAGE \
	print-TARGET_ELF print-TARGET_MAP print-CORE_VERSION
print-PROJECT_KIND:
	@echo $(PROJECT_KIND)
print-PACKED_BIN:
	@echo $(PACKED_BIN)
# Empty here: only a project that installs a second device file beside its
# binary sets RO_BIN. The shared stage_release.py reads it for every project
# so the script itself needs no per-project variant.
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
print-CORE_VERSION:
	@echo $(CORE_VERSION)

clean::
	$(V)rm -f $(PACKED_BIN)

#######################################
# Docker (same image as firmware repo)
#######################################
.PHONY: docker docker_pull docker_shell

RELEASE_VERSION ?= v1.5
DOCKER_REPOSITORY ?= sylverb/retro-go-sd-builder
DOCKER_IMAGE ?= $(DOCKER_REPOSITORY):$(RELEASE_VERSION)

DOCKER_TTY_FLAG := $(shell if [ -t 0 ]; then echo -it; else echo; fi)
# Host UID so build/ artifacts are not root-owned on the bind mount.
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
