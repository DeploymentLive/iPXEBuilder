
/** 
 * configuration file for crypto.h
 *
 * Overrides default iPXE Behaviour for Deployment Live
 *
 */
 
/** Default cross-signed certificate source
 *
 * This is the default location from which iPXE will attempt to
 * download cross-signed certificates in order to complete a
 * certificate chain.
 */
// #define CROSSCERT "http://ca.ipxe.org/auto"

/** Perform OCSP checks when applicable
 *
 * Some CAs provide non-functional OCSP servers, and some clients are
 * forced to operate on networks without access to the OCSP servers.
 * Allow the user to explicitly disable the use of OCSP checks.
 */
#undef OCSP_CHECK

