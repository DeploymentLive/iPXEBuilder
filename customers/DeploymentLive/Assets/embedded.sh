#!ipxe

# Copyright Deployment Live LLC, All Rights Reserved
# No redistribution without written permission

#region Init

# When booting from HTTPS, ${cwduri} will point to source Server. 
# DHCP can overwrite ${cwduri}, so save the value if the string starts with 'http'.
## The next line is a hack. ipxe scripting does NOT allow for string comparison.
## But that is OK, we only need to know if the first 4 characters are 'http'.
## ${cwduri:ipv4} converts the first 4 characters of the string to a dot delimited array of decimal integers.
## 104.116.116.112 is a dot delimited representation of the string 'http'
if ( iseq ${cwduri:ipv4} 104.116.116.112 )
    set force_filename ${cwduri}/cloudboot.ipxe ||
    echo HTTPS Boot: [${force_filename}]
end if

#include version.ipxe
set VendorName By DeploymentLive.com
set MaxFullRetries 10
set MaxServiceRetries 4

call InitializeConstants

call InitializeDebugging
call BreakPoint Initialize

call SetBackgroundPNG Logo.png

#endregion

#region Load autoexec.ipxe

if ( NOT isset ${cwduri} )
    ## There is no network path to reference where the iPXE server is. See if autoexec.ipxe knows...
    if ( imgstat autoexec.ipxe )
        call BreakPoint AutoExec
        chain autoexec.ipxe ||      # Load AutoExec.ipxe for USB scenarios
        iseq ${debug} true && echo autoexec.ipxe  [${force_filename}] ||
    else
        echo ${cls}
    end if
end if 

#endregion

#region Find best SNP adapter if IP address is assigned

clear SNPBest ||
set i:int32 0
while ( isset ${net${i}/mac} ) 
    if ( isset ${net${i}.dhcp/ip} )
        iseq ${debug} true && echo Found NIC: net${i} ||
        set SNPBest net${i}
    end if
    inc i ||
wend

#endregion

#region Full Boot Loop

#  Full Boot loop includes Network Initialization then calling a remote iPXE script.
set BootAttempts:int32 0
while ( NOT iseq ${BootAttempts} ${MaxFullRetries} )

    echo ${cls}${fgbold}iPXE ${version}[${script_version}] ${fgdefault}**${fgmagenta} ${VendorName} ${fgdefault}
    echo -n ${fggreen} Attempt: [${BootAttempts} / ${MaxFullRetries}]${fgdefault} ${} ${}

    if ( isset ${force_filename} )   # ManualBoot

        #region Network Initialization
        
        call BreakPoint ManualInit
        if ( isset ${SNPBest} )
            if ( NOT ifconf ${SNPBest} )
                call ErrorHandler ${errno:hexraw} "ifconf ${SNPBest}"
                ifclose ${SNPBest}
            end if
            clear SNPBest ||
        else
            if ( NOT ifconf )
                call ErrorHandler ${errno:hexraw} "ifconf ALL"
                ifclose
            end if
        end if

        #endregion

        #region Call iPXE Server

        if ( isset ${netX.dhcp/ip} )
            call BreakPoint ManualCall
            echo Found network Adapter: ${netX/ifname} IP: ${netX.dhcp/ip}

            set CallAttempts:int32 0
            clear LastConnectError ||
            while ( NOT iseq ${CallAttempts} ${MaxServiceRetries} )

                if ( NOT iseq ${CallAttempts} 0 )
                    echo ${fgyellow} ${} ${} Retry! [wait ${CallAttempts}0 sec] ...${fgdefault}
                    sleep ${CallAttempts}0   # Add A delay, increase every loop
                end if
                inc CallAttempts || 

                echo -n ${fgcyan}Connect [${CallAttempts}/4]: ${fgdefault}
                if ( NOT chain --name cloudboot.ipxe ${force_filename} )
                    set LastConnectError "chain call to ${force_filename}"
                    echo WARNING ${errno:hexraw} ${LastConnectError}
                    imgfree cloudboot.ipxe ||
                    continue
                end if

                set LastConnectError "chain call to ${force_filename}"
                echo WARNING ${errno:hexraw} ${LastConnectError}
                exit

            end while

            if ( iseq ${CallAttempts} ${MaxServiceRetries} ) 
                call ErrorHandler ${errno:hexraw} ${LastConnectError}
            end if

        end if

        #endregion
        
    else # NOT ${force_filename}     # AutoBoot

        # Call autoboot to initalize network and boot from iPXE Server.
        call BreakPoint AutoBoot
        echo ||
        if ( isset ${SNPBest} )
            autoboot ${SNPBest} && exit ||   # Should never return 
            call ErrorHandler ${errno:hexraw} "autoboot ${SNPBest}"
            clear SNPBest || 
        else
            autoboot && exit || # Should never return 
            call ErrorHandler ${errno:hexraw} "autoboot ALL"
        end if

    end if

    #region Cleanup for next attempt

    ifclose ||
    inc BootAttempts ||

    if( iseq ${BootAttempts} ${MaxFullRetries} )
        echo ${cls}
        call ErrorHandler Skip "Failed to boot ${MaxFullRetries} times."
        set BootAttempts:int32 0
        # Just reset back to zero and retry if selected by user
    end if

    #endregion

end while

#endregion

#include ..\..\_common\common.sh
