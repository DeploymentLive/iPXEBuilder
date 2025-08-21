# ipxe build system for DeploymentLive.com

iPXE is an open-source Network Boot loader that is run before the OS Starts. However it does require a Linux system to build the binaries. We can accomplish this on a Windows machine by installing the Windows Subsystem or Linux (WSL) and building from there. 

WSL is ideal in the scenario, because we can copy files back and forth between WSL and Windows to perform additional build tasks. 

## Design Goals:

We will need several customizations of iPXE for DeploymentLive and other customers, this can be performed by turing on and off iPXE features with `#define XXXX` statements within the source code or made at the command line.

All customizations required by Deployment Live will be kept in this repo. We will accomplish this with just a few symbolic links made from our settings folder to the ipxe `/src/config/local/DeploymentLive` folder. This allows for the ipxe repro to be kept clean of all changes made for Delployment Live. for more information see: https://ipxe.org/buildcfg.

There is only one code change I have made to iPXE, which is to add the command `sha256sum` with the argument `-sum`. 
See: https://github.com/ipxe/ipxe/compare/master...DeploymentLive:ipxe:master
I anticipate submitting a Pull Request into iPXE soon.

## Installation

Run `Install-WSLandiPXE.ps1` on your local Windows machine to start the build process. This script will:
* Install WSL, Ubuntu, and update all components.
* Install the necessary c/c++ build environment into Ubuntu.
* Clone a repo of ipxe into ~/ipxe.
* Create Symbolic Links back to this build environment.

## Build Notes

When ready we can build using the command `new-iPXEBuild.ps1`. The list of targets will be kept in the CSV file for each customer `.\customers\DeploymentLive\Assets\Build.csv`

For now, Deployment Live will target the following iPXE binaries:

See: https://ipxe.org/appnote/buildtargets

<!-- import-csv .\assets\DeploymentLive\Build.csv | select FriendlyName,Certs,Sign,'free/paid','Use case' | convertto-csv -->
|FriendlyName        |Certs |Sign  |Free/Paid           |Use Case                           |
|--------------------|------|------|--------------------|-----------------------------------|
|ipxe.lkrn           |Full  |FALSE |Free Community      |BIOS for Linux BootLoaders         |
|undionly.kpxe       |Full  |FALSE |Free Community      |BIOS with internal UNDI driver ONLY|
|ipxe.pxe            |Full  |FALSE |Free Community      |BIOS with FULL drivers             |
|ipxe_x86.efi        |Full  |FALSE |Free Community      |UEFI with FULL drivers             |
|snp_x86.efi         |Full  |FALSE |Free Community      |UEFI with SNP driver               |
|snp_DRV_x86.efi     |Full  |FALSE |Free Community      |UEFI with SNP, USB & other drivers |
|ipxe_x64.efi        |Full  |FALSE |Free Community      |UEFI with FULL drivers             |
|snp_CA_x64.efi      |CA    |TRUE  |Free Community      |UEFI with SNP driver               |
|snp_DRV_CA_x64.efi  |CA    |TRUE  |Free Community      |UEFI with SNP, USB & other drivers |
|snp_x64.efi         |Full  |TRUE  |Future Use?         |UEFI with SNP driver               |
|snp_DRV_x64.efi     |Full  |TRUE  |Future Use?         |UEFI with SNP, USB & other drivers |
|snp_CA_aa64.efi     |CA    |TRUE  |Free Community      |UEFI with SNP driver               |
|snp_DRV_CA_aa64.efi |CA    |TRUE  |Free Community      |UEFI with SNP, USB & other drivers |
|snp_aa64.efi        |Full  |TRUE  |Future Use?         |UEFI with SNP driver               |
|snp_DRV_aa64.efi    |Full  |TRUE  |Future Use?         |UEFI with SNP, USB & other drivers |

**Notes:** There are a wide range of iPXE targets that *can* be made, but not all targets will be included.

|Scenario|Rationale|
|--------|---------|
|SNPOnly|Not Included, use SNP instead. Embedded scripts can prioritize primary NIC.|
|SNP i386 not Signed|Can't find any examples of UEFI Class 3 devices with Intel i386 **only** (No x64)| 
|ipxe.efi not Signed|ipxe.efi is 350% larger than snp.efi. Excluded so it won't hold back MSFT signing.|
|snp_DRV_*|A small set of drivers to add to snp for compatibility (_From Public sources_).<br>**ecm--acm--ncm--axge--bnxt--tg3--intel--intelxl--ice--vmxnet3--netfront**<br> ecm--acm--ncm--axge - USB Network Drivers<br> bnxt--tg3 - Broadcom<br> intel--intelxl--ice - Intel <br> vmxnet3--netfront - Network Drivers for Virtual Hosts|
|CA Cert Only|Deployment Live Certificate Authority (CA) Trusted by default. <br>Allows HTTPS to DeploymentLive.com <br> Allows download signature verification with **imgverify**|
|iPXE Cert|iPXE root CA Cert https://ipxe.org/_media/certs/ca.crt Not included in all scenarios (Future)|
|Full Certs|Deployment Live CA and standard Mozilla list of public CA Certificates|
|PeerDist|FUTURE: With and without?!?!|

## What is added to Deployment Live binaries:
|Component|Use Case|
|------|------
|Base Functionality|Components are turned on and off via c/c++ precompiler directives found:<br>https://github.com/DeploymentLive/ipxe/tree/master/src/config/local|
|Certificates|Deployment Live Certificate Authority (CA) Cert is built in (See above)|
|Embedded iPXE Script|Some custom processing and help to connect to iPXE server|
|Secure Boot Signature|All the UEFI Bianries are signed either by a test CA, or by Microsoft (Future)|
|Other Files|Background Bitmap (PNG) file|

## Other Media Targets
Once the base iPXE binaries have been built and signed, we can deploy them in several scenarios:
|Deployment Scenario|Use Case|
|------|------|
|USB|Can be added to a USB stick for booting.<br>Will require an AutoExec.ipxe script to find the iPXE Server.|
|ISO|Can be added burnt or mounted to a CD/DVD for booting.<br>Will require an AutoExec.ipxe script to find the iPXE Server.|
|HP Sure Recover|Can be added to a HP Sure Recover Manifest and signed.<br>Will then be pointed back to the iPXE Server.|
|HTTPS Server|iPXE can be added to an HTTPS server for UEFI HTTPS Booting (FUTURE)|
|PXE Booting|FUTURE|

# Links:
* https://ipxe.org
* https://github.com/ipxe/ipxe
* https://boot.deploymentlive.com
* https://github.com/DeploymentLive/ipxe-dl



