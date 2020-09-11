@echo off

    if exist "FTFRN_2.0.obj" del "FTFRN_2.0.obj"
    if exist "FTFRN_2.0.exe" del "FTFRN_2.0.exe"

    \masm32\bin\ml /c /coff "FTFRN_2.0.asm"
    if errorlevel 1 goto errasm

    \masm32\bin\PoLink /SUBSYSTEM:CONSOLE "FTFRN_2.0.obj"
    if errorlevel 1 goto errlink
    dir "FTFRN_2.0.*"
    goto TheEnd

  :errlink
    echo _
    echo Link error
    goto TheEnd

  :errasm
    echo _
    echo Assembly Error
    goto TheEnd
    
  :TheEnd
    del *.obj
pause
