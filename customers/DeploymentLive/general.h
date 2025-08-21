
/** 
 * configuration file for general.h
 *
 * Overrides define iPXE Behaviour for Deployment Live
 *
 */

 
//
// Reviewer's note:
// This file has been copied from the iPXE source tree.
// It has been modified to represent the OPPOSITE of the iPXE defaults. 
// IF you uncomment a line it will change the default iPXE behaviour.
//


/*
 * Banner timeout configuration
 *
 * This controls the timeout for the "Press Ctrl-B for the iPXE
 * command line" banner displayed when iPXE starts up.  The value is
 * specified in tenths of a second for which the banner should appear.
 * A value of 0 disables the banner.
 *
 * ROM_BANNER_TIMEOUT controls the "Press Ctrl-B to configure iPXE"
 * banner displayed only by ROM builds of iPXE during POST.  This
 * defines to being twice the length of BANNER_TIMEOUT, to allow for
 * BIOSes that switch video modes immediately before calling the
 * initialisation vector, thus rendering the banner almost invisible
 * to the user.
 */
//  #undef BANNER_TIMEOUT		20
//  #undef ROM_BANNER_TIMEOUT	( 2 * BANNER_TIMEOUT )

/*
 * Network protocols
 *
 */

//  #undef	NET_PROTO_IPV4		/* IPv4 protocol */
//#define NET_PROTO_IPV6	/* IPv6 protocol */
//  #define	NET_PROTO_FCOE		/* Fibre Channel over Ethernet protocol */
//  #undef	NET_PROTO_STP		/* Spanning Tree protocol */
//  #undef	NET_PROTO_LACP		/* Link Aggregation control protocol */
//  #undef	NET_PROTO_EAPOL		/* EAP over LAN protocol */
//#define NET_PROTO_LLDP	/* Link Layer Discovery protocol */

/*
 * PXE support
 *
 */
//#undef	PXE_STACK		/* PXE stack in iPXE - you want this! */
//#undef	PXE_MENU		/* PXE menu booting */

/*
 * Download protocols
 *
 */

//  #undef	DOWNLOAD_PROTO_TFTP	/* Trivial File Transfer Protocol */
//  #undef	DOWNLOAD_PROTO_HTTP	/* Hypertext Transfer Protocol */
#define	DOWNLOAD_PROTO_HTTPS	/* Secure Hypertext Transfer Protocol */
//  #define	DOWNLOAD_PROTO_FTP	/* File Transfer Protocol */
//  #define	DOWNLOAD_PROTO_SLAM	/* Scalable Local Area Multicast */
//  #define	DOWNLOAD_PROTO_NFS	/* Network File System Protocol */
//#undef DOWNLOAD_PROTO_FILE	/* Local filesystem access */

/*
 * SAN boot protocols
 *
 */

//#undef	SANBOOT_PROTO_ISCSI	/* iSCSI protocol */
//#undef	SANBOOT_PROTO_AOE	/* AoE protocol */
//#undef	SANBOOT_PROTO_IB_SRP	/* Infiniband SCSI RDMA protocol */
//#undef	SANBOOT_PROTO_FCP	/* Fibre Channel protocol */
//#undef	SANBOOT_PROTO_HTTP	/* HTTP SAN protocol */

/*
 * HTTP extensions
 *
 */
//  #undef HTTP_AUTH_BASIC		/* Basic authentication */
//  #undef HTTP_AUTH_DIGEST	/* Digest authentication */
#define HTTP_AUTH_NTLM	/* NTLM authentication */

// #define HTTP_ENC_PEERDIST	/* PeerDist content encoding */
//#define HTTP_HACK_GCE		/* Google Compute Engine hacks */

/*
 * 802.11 cryptosystems and handshaking protocols
 *
 */
// #undef	CRYPTO_80211_WEP	/* WEP encryption (deprecated and insecure!) */
// #undef	CRYPTO_80211_WPA	/* WPA Personal, authenticating with passphrase */
// #undef	CRYPTO_80211_WPA2	/* Add support for stronger WPA cryptography */

/*
 * 802.1x EAP authentication methods
 *
 */
//  #undef EAP_METHOD_MD5		/* MD5-Challenge port authentication */
//#define EAP_METHOD_MSCHAPV2	/* MS-CHAPv2 port authentication */

/*
 * Name resolution modules
 *
 */

//  #undef	DNS_RESOLVER		/* DNS resolver */

/*
 * Image types
 *
 * Etherboot supports various image formats.  Select whichever ones
 * you want to use.
 *
 */
//#define	IMAGE_NBI		/* NBI image support */
//#define	IMAGE_ELF		/* ELF image support */
//#define	IMAGE_MULTIBOOT		/* MultiBoot image support */
// #define	IMAGE_PXE		/* PXE image support */
//#define	IMAGE_SCRIPT		/* iPXE script image support */
//#define	IMAGE_BZIMAGE		/* Linux bzImage image support */
//#define	IMAGE_COMBOOT		/* SYSLINUX COMBOOT image support */
//#define	IMAGE_EFI		/* EFI image support */
//#define	IMAGE_SDI		/* SDI image support */
//#define	IMAGE_PNM		/* PNM image support */
//  #undef	IMAGE_PNG		/* PNG image support */
//  #undef	IMAGE_DER		/* DER image support */
//  #undef	IMAGE_PEM		/* PEM image support */
//#define	IMAGE_ZLIB		/* ZLIB image support */
#define	IMAGE_GZIP		/* GZIP image support */
//#define	IMAGE_UCODE		/* Microcode update image support */

/*
 * Command-line commands to include
 *
 */
//  #undef	AUTOBOOT_CMD		/* Automatic booting */
//  #undef	NVO_CMD			/* Non-volatile option storage commands */
//  #undef	CONFIG_CMD		/* Option configuration console */
//  #undef	IFMGMT_CMD		/* Interface management commands */
#undef	IWMGMT_CMD		/* Wireless interface management commands */
#undef IBMGMT_CMD		/* Infiniband management commands */
//  #undef FCMGMT_CMD		/* Fibre Channel management commands */
//  #undef	ROUTE_CMD		/* Routing table management commands */
#define  IMAGE_CMD		/* Image management commands */
//  #undef DHCP_CMD		/* DHCP management commands */
//  #undef SANBOOT_CMD		/* SAN boot commands */
//  #undef MENU_CMD		/* Menu commands */
#define FORM_CMD		/* Form commands */
//  #undef LOGIN_CMD		/* Login command */
//  #undef SYNC_CMD		/* Sync command */
//  #undef SHELL_CMD		/* Shell command */
#define NSLOOKUP_CMD		/* DNS resolving command */
//#define TIME_CMD		/* Time commands */
#define DIGEST_CMD		/* Image crypto digest commands */
//#define LOTEST_CMD		/* Loopback testing commands */
//#define VLAN_CMD		/* VLAN commands */
//#define PXE_CMD		/* PXE commands */
#define REBOOT_CMD		/* Reboot command */
#define POWEROFF_CMD		/* Power off command */
// #define IMAGE_TRUST_CMD	/* Image trust management commands */
//#define IMAGE_CRYPT_CMD	/* Image encryption management commands */
//#define PCI_CMD		/* PCI commands */
#define PARAM_CMD		/* Request parameter commands */
#define NEIGHBOUR_CMD		/* Neighbour management commands */
#define PING_CMD		/* Ping command */
#define CONSOLE_CMD		/* Console command */
#define IPSTAT_CMD		/* IP statistics commands */
//#define PROFSTAT_CMD		/* Profiling commands */
#define NTP_CMD		/* NTP commands */
#define CERT_CMD		/* Certificate management commands */
//#define IMAGE_MEM_CMD		/* Read memory command */
#define IMAGE_ARCHIVE_CMD	/* Archive image management commands */
//  #undef SHIM_CMD		/* EFI shim command (or dummy command) */
//#define USB_CMD		/* USB commands */

/*
 * ROM-specific options
 *
 */
//  #define	NONPNP_HOOK_INT19	/* Hook INT19 on non-PnP BIOSes */
//  #undef	AUTOBOOT_ROM_FILTER	/* Autoboot only devices matching our ROM */

/*
 * Virtual network devices
 *
 */
//  #undef VNIC_IPOIB		/* Infiniband IPoIB virtual NICs */
//#define VNIC_XSIGO		/* Infiniband Xsigo virtual NICs */

/*
 * Error message tables to include
 *
 */
//  #define	ERRMSG_80211		/* All 802.11 error descriptions (~3.3kb) */

/*
 * Obscure configuration options
 *
 * You probably don't need to touch these.
 *
 */

// #define	BUILD_SERIAL		
			    /* Include an automatic build serial
				 * number.  Add "bs" to the list of
				 * make targets.  For example:
				 * "make bin/rtl8139.dsk bs" */
#define	BUILD_ID    "dl_prod"
//  #define	NULL_TRAP		/* Attempt to catch NULL function calls */
//  #define	GDBSERIAL		/* Remote GDB debugging over serial */
//  #define	GDBUDP			/* Remote GDB debugging over UDP  * (both may be set) */
//#define EFI_DOWNGRADE_UX	/* Downgrade UEFI user experience */
//  #undef	TIVOLI_VMM_WORKAROUND	/* Work around the Tivoli VMM's garbling of SSE registers when iPXE traps to it due to privileged instructions */
