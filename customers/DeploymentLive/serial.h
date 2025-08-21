
/** 
 * configuration file for serial.h
 *
 * Overrides default iPXE Behaviour for Deployment Live
 *
 */
 
#define	COMCONSOLE	COM1		/* I/O port address */

/* Keep settings from a previous user of the serial port (e.g. lilo or
 * LinuxBIOS), ignoring COMSPEED, COMDATA, COMPARITY and COMSTOP.
 */
#undef	COMPRESERVE

#ifndef COMPRESERVE
#define	COMSPEED	115200		/* Baud rate */
#define	COMDATA		8		/* Data bits */
#define	COMPARITY	0		/* Parity: 0=None, 1=Odd, 2=Even */
#define	COMSTOP		1		/* Stop bits */
#endif
