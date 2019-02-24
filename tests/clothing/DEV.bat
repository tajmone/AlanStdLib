:: -----------------------------------------------------------------------------
:: Carry out only tests for "DEV*.a3sol" scripts, targetting the current work
:: on the new clothing system.
:: -----------------------------------------------------------------------------
@ECHO OFF & CLS
:: Code Page 28591 = ISO 8859-1 Latin 1; Western European (ISO)
CHCP 28591 > nul

ECHO COMPILE: ega.alan
CALL alan.exe -import ..\..\  ega.alan
FOR %%i IN (DEV*.a3sol) DO (
  ECHO TEST WITH:  %%i
  CALL :ExecTest %%i
)

EXIT /B

:ExecTest
CALL arun.exe -r ega.a3c < %1 > %~n1.a3log
EXIT /B
