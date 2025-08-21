
/** 
 * configuration file for console.h
 *
 * Overrides default iPXE Behaviour for Deployment Live
 *
 */
 

/*
 * Default console types
 *
 * These are all enabled by default for the appropriate platforms.
 * You may disable them if needed.
 *
 */

//#undef	CONSOLE_PCBIOS		/* Default BIOS console */
//#undef	CONSOLE_EFI		/* Default EFI console */
//#undef	CONSOLE_LINUX		/* Default Linux console */

/*
 * Additional console types
 *
 * These are not enabled by default, but may be useful in your
 * environment.
 *
 */

//#define	CONSOLE_SERIAL		/* Serial port console */
#define	CONSOLE_FRAMEBUFFER	/* Graphical framebuffer console */
//#define	CONSOLE_SYSLOG		/* Syslog console */
//#define	CONSOLE_SYSLOGS		/* Encrypted syslog console */
//#define	CONSOLE_VMWARE		/* VMware logfile console */
//#define	CONSOLE_DEBUGCON	/* Bochs/QEMU/KVM debug port console */
//#define	CONSOLE_INT13		/* INT13 disk log console */
//#define	CONSOLE_SBI		/* RISC-V SBI debug console */

/*
 * Very obscure console types
 *
 * You almost certainly do not need to enable these.
 *
 */

//#define	CONSOLE_DIRECT_VGA	/* Direct access to VGA card */
//#define	CONSOLE_PC_KBD		/* Direct access to PC keyboard */

/* Keyboard map (available maps in hci/keymap/) */

// From: https://ipxe.org/buildcfg/keyboard_map
#undef KEYBOARD_MAP
#define KEYBOARD_MAP dynamic

/* Control which syslog() messages are generated.
 *
 * Note that this is not related in any way to CONSOLE_SYSLOG.
 */
// #define	LOG_LEVEL	LOG_NONE

