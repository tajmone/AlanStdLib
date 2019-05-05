#!/bin/bash

# _update.sh              v1.1.0 | 2019/05/05 | by Tristano Ajmone, MIT License.
################################################################################
#                                                                              #
#                          BUILD STDLIB EXTRAS FOLDER                          #
#                                                                              #
################################################################################
# Build and deploy the contents of "/extras/tutorials/" folder:
# 
#  -- HTML documents
#  -- Alan example adventures

################################################################################
#                                   SETTINGS                                   #
################################################################################
# NOTE: All paths are relative to the folder of this script.

shopt -s nullglob # Set nullglob to avoid patterns matching null files

# Alan compiler options:
AlanOpts="-import ../StdLib/"

# Asciidoctor options:
adocDir="./adoc"
hamlDir="$adocDir/haml"

# Target Documentation Folder:
dirName="tutorials"

# Base Paths for Source & Destination
srcBasePath="."
outBasePath="../extras"
utfBasePath="./utf8"

# Source & Destination folders:
outDir="$outBasePath/$dirName"   # destination folder for HTML docs and examples
srcDir="$srcBasePath/$dirName"   # path of AsciiDoc sources and Alan examples
utfDir="$utfBasePath/$dirName"   # path of UTF-8 converted Alan files

################################################################################
#                            FUNCTIONS DEFINITIONS                             #
################################################################################

# Ornamental print functions
# --------------------------
source _print-funcs.sh

# Task functions
# --------------

function normalizeEOL {
  # ============================================================================
  # if OS is Windows normalize EOL to CRLF (because sed uses LF)
  # ----------------------------------------------------------------------------
  # Parameters:
  # - $1: the file to normalize.
  # ============================================================================
  if [[ $(uname -s) == MINGW* ]];then
    echo -e "\e[90mUNIX2DOS: \e[94m$1"
    unix2dos -q $1
  fi
}

function compile {
  # ============================================================================
  # Compile an Alan adventure
  # ----------------------------------------------------------------------------
  # Parameters and Env Vars:
  # - $1: the source adventure to compile.
  # - $AlanOpts: compiler options.
  # ============================================================================
  printSeparator
  echo -e "\e[90mCOMPILING: \e[93m$1"
  alan $AlanOpts $1 > /dev/null 2>&1 || (
    echo -e "\n\e[91m*** COMPILER ERROR!!! ********************************************************"
    alan $AlanOpts $1
    echo -e "******************************************************************************\e[97m"
    cmd_failed="true"
    return 1
  )
}

function runCommandsScripts {
  # ============================================================================
  # Given a target Alan adventure "<advname>.a3c", execute it against every
  # command script in the folder with a filename matching "<advname>*.a3sol" and
  # save the game transcript to "<advname>*.a3log".
  # ----------------------------------------------------------------------------
  # Parameters:
  # - $1: the target Alan adventure (".a3c").
  # ============================================================================
  scriptsPattern="${1%.*}*.a3sol"
  printSeparator
  echo -e "\e[90mADVENTURE: \e[93m$1"
  for script in $scriptsPattern ; do
    transcript="${script%.*}.a3log"
    echo -e "\e[90mPLAY WITH: \e[94m$script"
    arun.exe -r $1 < $script > $transcript
  done
}
  
function alan2utf8 {
  # ============================================================================
  # Create an UTF-8 coverted copy of an ISO-8859-1 Alan file (adventure,
  # commands script or transcript) inside $utfDir, to allow its inclusion in
  # AsciiDoc documents, because Asciidoctor won't handle ISO-8859-1 files. See:
  #
  #  https://github.com/asciidoctor/asciidoctor/issues/3248
  # ----------------------------------------------------------------------------
  # Parameters and Env Vars:
  # - $1: the input ISO-8859-1 file to convert.
  # - $utfDir: path to the base folder for all UTF-8 converted files.
  # ============================================================================
  outfile="$utfDir/$(basename $1)"
  printSeparator
  echo -e "\e[90mSOURCE FILE: \e[93m$1"
  echo -e "\e[90mDESTINATION: \e[34m$outfile"
  iconv -f ISO-8859-1 -t UTF-8 $1 > $outfile
}

function a3logSanitize {
  # ============================================================================
  # Takes a game transcript input file $1 "<filename>.a3log" and converts it to
  # "<filename>.a3ADocLog", a well formatted AsciiDoc example block.
  # ----------------------------------------------------------------------------
  # Parameters:
  # - $1: the input transcript file.
  # Required scripts:
  # - ./sanitize_a3log.sed
  # ============================================================================
  outfile="${1%.*}.a3ADocLog"
  printSeparator
  echo -e "\e[90mSOURCE FILE: \e[93m$1"
  echo -e "\e[90mDESTINATION: \e[34m$outfile"
  sed -E --file=sanitize_a3log.sed $1 > $outfile
  normalizeEOL $outfile
}

function adoc2html {
  # ============================================================================
  # Convert file $1 from AsciiDoc to HTML via Asciidoctor. Requires Highlight
  # for syntax highlighting code. Custom CSS via docinfo file.
  # ----------------------------------------------------------------------------
  # Parameters and Env Vars:
  # - $1: the input AsciiDOc file to convert.
  # - $outDir: path of output directory.
  # - $hamlDir: path to Haml templates.
  # - $adocDir: path to Asciidoctor custom extensions.
  # ============================================================================
  printSeparator
  echo -e "\e[90mCONVERTING: \e[93m$1"
  asciidoctor \
    --verbose \
    --safe-mode unsafe \
    --base-dir ./ \
    --destination-dir $outDir \
    --template-dir $hamlDir \
    --require $adocDir/highlight-treeprocessor_mod.rb \
     -a docinfodir@=$adocDir \
     -a docinfo@=shared-head \
     -a utf8dir=$utfDir \
      $1
}

function deployAlan {
  # ============================================================================
  # Takes the Alan source file of $1, and creates in $outDir a copy stripped of
  # all region-tag comment lines.
  # ----------------------------------------------------------------------------
  # Parameters and Env Vars:
  # - $1: the input Alan source adventure file to deploy.
  # - $outDir: path of output directory.
  # ============================================================================
  outfile="$outDir/$(basename $1)"
  printSeparator
  echo -e "\e[90mSOURCE FILE: \e[93m$1"
  echo -e "\e[90mDESTINATION: \e[94m$outfile"
  sed -r '/^ *-- *(tag|end)::\w+\[/ d' $1 > $outfile
  normalizeEOL $outfile
}
  
################################################################################
#                                  MAIN CODE                                   #
################################################################################

printBanner "Build StdLib Extras Folder"

# ==============================================================================
printHeading1 "Process Alan Adventures"
# ==============================================================================

# ------------------------------------------------------------------------------
printHeading2 "Compile Adventures"
# ------------------------------------------------------------------------------
for sourcefile in $srcDir/*.alan ; do
  compile $sourcefile
  if [ $? -ne 0 ] ; then
    printAborting ; exit 1
  fi
done

# ------------------------------------------------------------------------------
printHeading2 "Run Commands Scripts"
# ------------------------------------------------------------------------------

for adventure in $srcDir/*.a3c ; do
  runCommandsScripts $adventure
done

# ------------------------------------------------------------------------------
printHeading2 "Deploy Alan Source Files"
# ------------------------------------------------------------------------------
echo -e "Copy to target folder every Alan source, but stripped of all lines containing"
echo -e "AsciiDoc region-tag comments."

for file in $srcDir/*.alan ; do
  deployAlan $file
done

# ==============================================================================
printHeading1 "Build AsciiDoc Documentation"
# ==============================================================================

# ------------------------------------------------------------------------------
printHeading2 "Create UTF-8 Version of Alan Sources and Transcripts"
# ------------------------------------------------------------------------------

echo -e "Because Asciidoctor can't handle inclusion of external files in ISO-8859-1"
echo -e "econding, we need to create UTF-8 versions of them."

# rm -r $utfDir/*.{alan,a3log,a3ADocLog}
rm -rf $utfDir
mkdir  $utfDir
touch  $utfDir/.gitkeep

for sourcefile in $srcDir/*.{alan,i,a3log} ; do
  alan2utf8 $sourcefile
  if [ $? -ne 0 ] ; then
    printAborting ; exit 1
  fi
done

# ------------------------------------------------------------------------------
printHeading2 "Sanitize Game Transcripts"
# ------------------------------------------------------------------------------

echo -e "Reformat game transcripts from verbatim to AsciiDoc example blocks."

for transcript in $utfDir/*.a3log ; do
  a3logSanitize $transcript
  if [ $? -ne 0 ] ; then
    printAborting ; exit 1
  fi
done

# ------------------------------------------------------------------------------
printHeading2 "Convert Docs to HTML"
# ------------------------------------------------------------------------------
for sourcefile in $srcDir/*.asciidoc ; do
  adoc2html $sourcefile
  if [ $? -ne 0 ] ; then
    printAborting ; exit 1
  fi
done

# ------------------------------------------------------------------------------

printFinished
exit

# ------------------------------------------------------------------------------
# The MIT License
#
# Copyright (c) 2019 Tristano Ajmone: <tajmone@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# ------------------------------------------------------------------------------
# EOF #
