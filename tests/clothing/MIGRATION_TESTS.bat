:: -----------------------------------------------------------------------------
:: Run the "MIGRATION_TESTS.a3sol" only, targetting the WIP development fo the
:: new clothing system that doesn't use the 'worn' entity.
:: -----------------------------------------------------------------------------
@ECHO OFF & CLS
:: Code Page 28591 = ISO 8859-1 Latin 1; Western European (ISO)
CHCP 28591 > nul

ECHO COMPILING: ega.alan
CALL alan.exe -import ..\..\ ega.alan
ECHO TESTING:   MIGRATION_TESTS.a3sol
CALL arun.exe -r ega.a3c < MIGRATION_TESTS.a3sol > MIGRATION_TESTS.a3log

EXIT /B
