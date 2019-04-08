:: "BUILD_SASS.bat"                     v2.0.0 | 2019/03/14 | by Tristano Ajmone
:: -----------------------------------------------------------------------------
:: This script requires Dart Sass to be installed on the system:
::      https://github.com/sass/dart-sass
::
:: You can use Chocolatey to install Dart Sass and keep it updated:
::      https://chocolatey.org/packages/sass
:: -----------------------------------------------------------------------------
@ECHO OFF
ECHO.

SET "SRC=styles.scss"
SET "OUT=../css/styles.css"

ECHO =================================
ECHO Building CSS stylesheet from SCSS
ECHO =================================
ECHO SOURCE: %SRC%
ECHO OUTPUT: %OUT%

CALL SASS %SRC% %OUT%

ECHO /// Finished ///
EXIT /B

:: EOF ::
