# Copyright Deployment Live LLC, All Rights Reserved

#region Debugging Commands

sub BreakPoint
    # arg1 = name
    if ( iseq ${debug} true ) 
        if ( prompt --key d --timeout 2000 BreakPoint [${arg1}] Press 'd' to enter shell [2sec] )
            echo Start ipxe Shell [${arg1}]. Enter "exit" to continue.
            shell || 
            # Continue...
        end if
    end if
end sub

sub ErrorHandler
    # arg1 = ${errno:hexraw}
    # arg2 = description of Command 

    clear error_retry ||
    echo
    echo "${fgred}ERROR:${fgdefault} ${arg2}"
    if ( NOT iseq ${arg1} Skip )
        echo "    See: ${fgcyan}https://ipxe.org/${arg1}${fgdefault}"
        echo
        if ( NOT goto error_${arg1} )
            # Error message was not found, display default message:
            echo "    Unknown error! ${fggreen}Take a Picture here for your support team.${fgdefault}"

        end if

        echo
        ifstat ||
        route ||
    end if

    :error_return_here
    if ( isset ${error_retry} )
        return
    end if

    echo
    if ( prompt --key 0x0a --timeout 300000 ${} ${} Press ${fgbold}[Enter]${fgdefault} to break into Debug Menu. Any other key to continue [5min]. )
        call DebugMenu
    else
        if ( iseq ${arg1} Skip )
            echo            
            if ( NOT prompt --timeout 300000 Shutdown Machine in [6min] Press any key to override. )
                ## Special Case, if after 1 hour we STILL haven't booted, shut the machine down. No Burn-in!
                poweroff
            end if
        end if 
    end if

end sub

sub InitializeDebugging
    ## Allow breaking into the shell at the start of embedded execution for debugging.
    ## May be turned off in production for security.

    if ( prompt --key d --timeout 500 ... )
        set debug true

        ## if we are in debugging mode, then turn off CLS.
        set cls %%%%%%%   Clear Screen  %%%%%%%%%%%%%%%

        echo %%%%%%%   DebugMode %%%%%%%
        ifstat ||
        imgstat ||
        certstat ||
        echo SecureBoot ( [01] is enabled / [00] is disabled ): ${efi/SecureBoot}
    end if
end sub 

#endregion

#region Error List

## #################################################
:error_2c1de087
echo ${} ${} ${} Link down: ${fgyellow}Networking Device Not Found.${fgdefault}
goto error_return_here

## #################################################
:error_38086193
:error_1a086194
echo ${} ${} ${} Link down: ${fgyellow}Ensure your machine is connected to network.${fgdefault}
goto error_return_here

## #################################################
:error_040ee186
echo ${} ${} ${} Configuration Failed: ${fgyellow}Ensure your machine is connected to Router/Internet.${fgdefault}
goto error_return_here

## #################################################
:error_3e11628e
echo ${} ${} ${} No DNS Servers responding: ${fgyellow}Ensure your machine is connected to Router/Internet.${fgdefault}
goto error_return_here

## #################################################
## From https://www.google.com/search?q=site%3Aipxe.org%2Ferr+bios+time
:error_0216e48f
:error_0216eb8f
echo ${} ${} ${} TLS Errors: ${fgyellow}Ensure the correct time is set on your machine.${fgdefault}
if ( NOT isset ${ntp_run} )
    echo Set clock using Network Time Protocol [pool.ntp.org]...
    ntp pool.ntp.org ||
    set error_retry 1
end if
set ntp_run 1

goto error_return_here

#endregion

#region DebugMenu

sub DebugMenu

    while ( isset ${version}  )
        menu Debug Menu

        item --gap Next Steps
        item debug_reboot ${} ${} Reboot System
        item debug_shutdown ${} ${} Shutdown System
        item --default debug_continue ${} ${} Continue Boot Order (Boot to disk)
        item debug_retry ${} ${} Retry Network Initialization
        item --gap
        item --gap Tools
        item debug_shell ${} ${} iPXE Shell (Advanced Users)
        item debug_config ${} ${} iPXE Config tool
        item debug_diagnostics ${} ${} Network Status and Diagnostics

        choose --timeout 120000 operation || set operation debug_retry
        if ( iseq ${operation} debug_retry )
            break
        end if

        call SetBackgroundPNG ""
        call ${operation}  || prompt Failed to call Debug Menu item ${operation}
        call SetBackgroundPNG Logo.png
        
    end while

end sub

sub debug_reboot
    echo "Reboot Machine..."
    reboot
end sub

sub debug_shutdown
    echo "Shutdown Machine..."
    poweroff
end sub 

sub debug_continue
    echo "Continue Boot Order (Boot to disk)"
    exit
end sub

sub debug_retry
    prompt ERROR: sub retry should not be called
end sub

sub debug_shell
    echo "Enter iPXE shell ( Type "help" for help, type "exit" to exit )."
    shell
end sub

sub debug_config
    echo "Enter ipxe config tool"
    config
end sub

sub debug_diagnostics

    echo "${cls}${fgbold}Network Diagnostics for Deployment Live iPXE${fgdefault}"

    #region Dump Current Status

    echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    echo   Take a picture of this page for your support team!
    echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ifstat ||
    route ||
    nstat ||
    # ipstat ||
    imgstat ||
    certstat ||
    echo SecureBoot ( [01] is enabled / [00] is disabled ): ${efi/SecureBoot}
    echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    #endregion 

    #region Check various custom settings

    ## Add more!!!
    if ( isset ${netX.dhcp/dns} )
        echo -n Ping DNS ${netX.dhcp/dns} ...
        if ( ping -c 1 -q ${netX.dhcp/dns} )
            echo "    ${fgbold}OK${fgdefault}"
        else
            echo "    Failed to Ping DNS ${netX.dhcp/dns}   Error: ${errno:hexraw}"
        end if
    end if 

    if ( isset ${netX.dhcp/gateway} )
        echo -n Ping IP Gateway ${netX.dhcp/gateway} ...
        if ( ping -c 1 -q ${netX.dhcp/gateway} )
            echo "    ${fgbold}OK${fgdefault}"
        else
            echo "    Failed to Ping IP Gateway ${netX.dhcp/gateway}   Error: ${errno:hexraw}"
        end if
    end if
    echo -n Ping 8.8.8.8...
    if ( ping -c 1 -q 8.8.8.8 )
        echo "    ${fgbold}OK${fgdefault}"
    else
        echo "    Failed to Ping DNS 8.8.8.8    Error: ${errno:hexraw}"
    end if
    echo -n Ping Google.com...
    if ( ping -c 1 -q google.com )
        echo "    ${fgbold}OK${fgdefault}"
    else
        echo "    Failed to Ping google.com    Error: ${errno:hexraw}"
    end if

    #endregion

    prompt Press Any key to continue...

end sub

#endregion

#region Common Subroutines

sub InitializeConstants

    clear BackgroundPNG || 

    #region Colors
    # https://en.wikipedia.org/wiki/ANSI_escape_code

    set esc:hex 1b            # ANSI escape character - "^["
    set sp:hex 20 && set sp ${sp:string}
    set cls ${esc:string}[2J  # ANSI clear screen sequence - "^[[2J"

    set reset ${esc:string}[0m
    set bold ${esc:string}[1m
    set notbold ${esc:string}[22m
    set fgbold ${esc:string}[1m
    set notbold ${esc:string}[22m

    set fgblack ${esc:string}[30m
    set fgred ${esc:string}[31m
    set fggreen ${esc:string}[32m
    set fgyellow ${esc:string}[33m
    set fgblue ${esc:string}[34m
    set fgmagenta ${esc:string}[35m
    set fgcyan ${esc:string}[36m
    set fgwhite ${esc:string}[37m
    set fgdefault ${esc:string}[39m

    set bgblack ${esc:string}[40m
    set bgred ${esc:string}[41m
    set bggreen ${esc:string}[42m
    set bgyellow ${esc:string}[43m
    set bgblue ${esc:string}[44m
    set bgmagenta ${esc:string}[45m
    set bgcyan ${esc:string}[46m
    set bgwhite ${esc:string}[47m
    set bgdefault ${esc:string}[49m

    #endregion

end sub

sub SetBackgroundPNG
    # arg1 - background bitmap

    if ( iseq ${buildarch} arm64 && iseq ${product} Virtual${sp}Machine )
        # BUGBUG TODO XXX - ARM64  Bug on Hyper-V
        echo ${cls}
        return
    end if 

    if ( iseq ${efi/DisableDeploymentLiveLogo} true )
        # For customer who do not want the logo
        set arg1 ""
    end if

    ## -----
    ## Increase sides by 288 pixels, and top/bottom by 66
    ## -----

    if ( NOT iseq ${arg1} "" ) 
        if ( isset ${BackgroundPNG} )
            echo ${cls}
            iseq ${debug} true && Echo background PNG already set || 
        else
            # Set console 1080p monitors and displays (Most Common)
            if ( console -x 1600 -y 900 -t 400 -l 300 -r 300 -b 100 -p ${arg1} -k )
                set BackgroundPNG 1
            else
                # set console for 1024x768 ( HyperV )
                if ( console -x 1024 -y 768 -t 350 -l 30 -r 30 -b 30 -p ${arg1} -k )
                    set BackgroundPNG 1
                else
                    iseq ${debug} true && Echo Unable to set background PNG || 
                end if
            end if
        end if
    else
        if ( isset ${BackgroundPNG} )
            if ( NOT console -x 1600 -y 900 -t 100 -l 300 -r 300 -b 100 )
                # set console for 1024x768 ( HyperV )
                if ( NOT console -x 1024 -y 768 -l 30 -r 30 -t 30 -b 30 )
                    console ||
                    iseq ${debug} true && Echo Unable to clear console || 
                end if
            end if
            clear BackgroundPNG ||
        else
            echo ${cls}
            iseq ${debug} true && Echo CLEAR background already set || 
        end if
    end if
end sub

#endregion
