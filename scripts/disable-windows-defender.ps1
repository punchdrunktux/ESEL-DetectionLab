
    #reg import "c:\vagrant\resources\windows\Disable_Windows_Defender_Real-Time_Protection.reg" 2>&1 | out-null
    secedit.exe /configure /db %windir%\security\database\local.sdb /cfg c:\vagrant\resources\windows\group-policy.inf