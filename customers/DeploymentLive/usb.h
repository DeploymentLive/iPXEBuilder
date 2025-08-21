
/** 
 * configuration file for usb.h
 *
 * Overrides default iPXE Behaviour for Deployment Live
 *
 */


/*
 * USB host controllers (all enabled by default)
 *
 */
//#undef	USB_HCD_XHCI	/* xHCI USB host controller */
//#undef	USB_HCD_EHCI	/* EHCI USB host controller */
//#undef	USB_HCD_UHCI	/* UHCI USB host controller */
//#define	USB_HCD_USBIO	/* Very slow EFI USB host controller */

/*
 * USB peripherals
 *
 */
//#undef	USB_KEYBOARD	/* USB keyboards */
//#undef	USB_BLOCK	/* USB block devices */

/*
 * USB external interfaces
 *
 */
//#undef	USB_EFI		/* Provide EFI_USB_IO_PROTOCOL interface */
