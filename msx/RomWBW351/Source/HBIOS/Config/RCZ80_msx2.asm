;
;==================================================================================================
;   ROMWBW CUSTOM USER BUILD SETTINGS FOR MSX 2 OR NEWER
;==================================================================================================
;
#DEFINE PLATFORM_NAME "MSX Computer", " [", CONFIG, "]"
;
#INCLUDE "Config/RCZ80_msx.asm"		; INHERIT FROM DEFAULT MSX BUILD SETTINGS
;
RP5RTCENABLE	.SET	TRUE		; RP5C01 RTC BASED CLOCK (RP5RTC.ASM) (MSX_NOTE: MSX 2 ALWAYS HAS ONE)
;
TMS80COLS	.SET	TRUE		; TMS: ENABLE 80 COLUMN SCREEN, REQUIRES V9958 (MSX_NOTE: WHAT ABOUT V9938?)
