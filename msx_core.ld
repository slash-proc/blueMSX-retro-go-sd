/*
 * MSX (blueMSX) core linker script.
 *
 * R800 + SlotManager .text run from ITCM. Also park the tiny
 * vdpCommandPortLatchPending() there: R800_IRQ_PENDING polls it from the
 * interpreter loop while VDP IRQ is asserted (-ffunction-sections gives
 * .text.vdpCommandPortLatchPending).
 *
 * Hot state uses dtc_malloc/dtc_calloc (DTCM bump); ITCM stays code-only.
 *
 * .core_itcm is listed before .core_entry so GNU ld claims those input
 * sections first; .core_entry's *(.text*) then skips them.
 *
 * Object paths must match BUILD_DIR (build/core with PROJECT_KIND=core).
 */

INCLUDE gnw_ram_emu.ld
INCLUDE gnw_itcm_core.ld

MEMORY
{
  RAM_EMU (xrw) : ORIGIN = __RAM_EMU_START__, LENGTH = __RAM_EMU_LENGTH__
  ITCM    (xrw) : ORIGIN = __ITCM_CORE_START__, LENGTH = __ITCM_CORE_LENGTH__
}

PHDRS
{
  text PT_LOAD FLAGS(5); /* PF_R | PF_X */
  data PT_LOAD FLAGS(6); /* PF_R | PF_W */
  itcm PT_LOAD FLAGS(5);
}

SECTIONS
{
  /* Claim ITCM-resident .text first (absolute VMA; order is for matching). */
  .core_itcm __ITCM_CORE_START__ :
  {
    __CORE_ITCM_CODE_START__ = .;
    build/core/R800.o(.text*)
    build/core/SlotManager.o(.text*)
    build/core/VDP_MSX.o(.text.vdpCommandPortLatchPending)
    . = ALIGN(4);
    __CORE_ITCM_CODE_END__ = .;
  } >ITCM AT>RAM_EMU :itcm

  __CORE_ITCM_BSS_END__ = __CORE_ITCM_CODE_END__;

  ASSERT(__CORE_ITCM_BSS_END__ <= __ITCM_CORE_START__ + __ITCM_CORE_LENGTH__,
         "Error: MSX core ITCM segment (code) overflows the 64K ITCM region")

  .core_entry __RAM_EMU_START__ :
  {
    KEEP(*(.core_entry))
    KEEP(*(.gw_core_bridge_probe))
    . = ALIGN(4);
    EXCLUDE_FILE(build/core/R800.o build/core/SlotManager.o) *(.text*)
    *(.rodata*)
    *(.glue_7)
    *(.glue_7t)

    . = ALIGN(4);
    __CORE_INIT_ARRAY_START__ = .;
    KEEP(*(SORT(.init_array.*)))
    KEEP(*(.init_array*))
    __CORE_INIT_ARRAY_END__ = .;
  } >RAM_EMU :text

  .data :
  {
    *(.data*)
  } >RAM_EMU :data

  __CORE_CODE_END__ = .;

  .bss (NOLOAD) :
  {
    . = ALIGN(8);
    *(.bss*)
    *(COMMON)
    . = ALIGN(8);
  } >RAM_EMU :data

  __CORE_BSS_END__ = .;

  ASSERT(__CORE_BSS_END__ <= __RAM_EMU_END__,
         "Error: MSX core RAM_EMU segment (code+data+bss) overflows RAM_EMU")

  __exidx_start = .;
  __exidx_end = .;

  /DISCARD/ :
  {
    *(.fini_array*)
    *(.preinit_array*)
    *(.ARM.exidx*)
    *(.ARM.extab*)
    *(.comment)
    *(.ARM.attributes)
  }
}
