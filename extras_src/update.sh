#!/bin/bash
version="v0.1.0" ; revdate="2019/04/18"       # by Tristano Ajmone, MIT License.
################################################################################
#                                   SETTINGS                                   #
################################################################################
AlanOpts="-import ../StdLib/"  # Alan compiler options (relative to here)

htmlDir="../extras"     # destination folder of Asciidoctor HTML docs
alanDir="./alan"        # path of Alan files
utf8Dir="./alan/utf8"   # path of UTF-8 converted Alan files

shopt -s nullglob # Set nullglob to avoid patterns matching null files
################################################################################
#                            FUNCTIONS DEFINITIONS                             #
################################################################################

# Ornamental print functions
# --------------------------

function Heading1 {
  # ----------------------------------------------------------------------------
  # Print a yellow frame around text of $1, and center it.
  # ----------------------------------------------------------------------------
  echo -e "\e[93m******************************************************************************"
  printf  "\e[94m%*s\n" $(((${#1}+78)/2)) "$1"
  echo -e "\e[93m******************************************************************************\e[97m"
}

function Heading2 {
  # ----------------------------------------------------------------------------
  # Print a blue frame around text of $1.
  # ----------------------------------------------------------------------------
  echo -e "\e[94m=============================================================================="
  echo -e "\e[95m$1"
  echo -e "\e[94m==============================================================================\e[97m" 
}

function separator {
  # Print a dark grey horizontal ruler.
  echo -e "\e[90m------------------------------------------------------------------------------\e[97m"
}

# Task functions
# --------------

function normalizeEOL {
  # ------------------------------------------------------------
  # if OS is Windows normalize EOL to CRLF (because sed uses LF)
  # ------------------------------------------------------------
  if [[ $(uname -s) == MINGW* ]];then
    echo -e "\e[90mUNIX2DOS: \e[94m$1"
    unix2dos -q $1
  fi
}

function compile {
  # ----------------------------------------------------------------------------
  # Compile an Alan adventure
  # ----------------------------------------------------------------------------
  separator
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
  scriptsPattern="${1%.*}*.a3sol"
  separator
  echo -e "\e[90mADVENTURE: \e[93m$1"
  for script in $scriptsPattern ; do
    transcript="${script%.*}.a3log"
    echo -e "\e[90mPLAY WITH: \e[94m$script"
    arun.exe -r $1 < $script > $transcript
  done
}
  
function alan2utf8 {
  # ----------------------------------------------------------------------------
  # Create UTF-8 versions of Alan source files to allow inclusion in AsciiDoc
  # documents, because Asciidoctor won't handle ISO-8859-1 files. See:
  #   https://github.com/asciidoctor/asciidoctor/issues/3248
  # ----------------------------------------------------------------------------
  outfile="$utf8Dir/$(basename $1)"
  separator
  echo -e "\e[90mSOURCE FILE: \e[93m$1"
  echo -e "\e[90mDESTINATION: \e[34m$outfile"
  iconv -f ISO-8859-1 -t UTF-8 $1 > $outfile
}

function a3logSanitize {
  # ----------------------------------------------------------------------------
  # Takes a game transcript input file $1 "<filename>.a3log" and converts it to
  # "<filename>.a3ADocLog", a well formatted AsciiDoc example block.
  # ----------------------------------------------------------------------------
  outfile="${1%.*}.a3ADocLog"
  separator
  echo -e "\e[90mSOURCE FILE: \e[93m$1"
  echo -e "\e[90mDESTINATION: \e[34m$outfile"
  sed -E --file=sanitize_a3log.sed $1 > $outfile
  normalizeEOL $outfile
}

function adoc2html {
  # ----------------------------------------------------------------------------
  # Convert file $1 from AsciiDoc to HTML via Asciidoctor
  # ----------------------------------------------------------------------------
  separator
  echo -e "\e[90mCONVERTING: \e[93m$1"
  asciidoctor \
    --verbose \
    --safe-mode unsafe \
    --destination-dir $htmlDir \
    --template-dir ./haml \
    --require ./highlight-treeprocessor_mod.rb \
     -a docinfo=shared-head \
      $1
}

function deployAlan {
  # ----------------------------------------------------------------------------
  # Copy of an Alan source to $htmlDir, stripped of all region-tag comment lines.
  # ----------------------------------------------------------------------------
  outfile="$htmlDir/$(basename $1)"
  separator
  echo -e "\e[90mSOURCE FILE: \e[93m$1"
  echo -e "\e[90mDESTINATION: \e[94m$outfile"
  sed -r '/^ *-- *(tag|end)::\w+\[/ d' $1 > $outfile
  normalizeEOL $outfile
}
  
function aborting {
  echo -e "\n\e[91m/// Aborting ... ///\e[0m"
}

################################################################################
#                                  MAIN CODE                                   #
################################################################################

echo -e "\e[94m******************************************************************************"
echo -e "*                                                                            *"
echo -e "*\e[93m                         Build StdLib Extras Folder\e[94m                         *"
echo -e "*                                                                            *"
echo -e "******************************************************************************"
echo -e "\e[97mby Tristano Ajmone, MIT License.                           $version | $revdate"

# ==============================================================================
Heading1 "Process Alan Adventures"
# ==============================================================================

# ------------------------------------------------------------------------------
Heading2 "Compile Adventures"
# ------------------------------------------------------------------------------
for sourcefile in $alanDir/*.alan ; do
  compile $sourcefile
  if [ $? -ne 0 ] ; then
    aborting ; exit 1
  fi
done

# ------------------------------------------------------------------------------
Heading2 "Run Commands Scripts"
# ------------------------------------------------------------------------------

for adventure in $alanDir/*.a3c ; do
  runCommandsScripts $adventure
done

# ------------------------------------------------------------------------------
Heading2 "Deploy Alan Source Files"
# ------------------------------------------------------------------------------
echo -e "Copy to '$htmlDir/' every Alan source from '$alanDir/', but stripped of all the"
echo -e "lines containing AsciiDoc region-tag comments."

for file in $alanDir/*.alan ; do
  deployAlan $file
done

# ==============================================================================
Heading1 "Build AsciiDoc Documentation"
# ==============================================================================

# ------------------------------------------------------------------------------
Heading2 "Create UTF-8 Version of Alan Sources and Transcripts"
# ------------------------------------------------------------------------------

echo -e "Because Asciidoctor can't handle inclusion of external files in ISO-8859-1"
echo -e "econding, we need to create UTF-8 versions of them."

rm -rf $utf8Dir
mkdir  $utf8Dir
for sourcefile in $alanDir/*.{alan,i,a3log} ; do
  alan2utf8 $sourcefile
  if [ $? -ne 0 ] ; then
    aborting ; exit 1
  fi
done

# ------------------------------------------------------------------------------
Heading2 "Sanitize Game Transcripts"
# ------------------------------------------------------------------------------

echo -e "Reformat game transcripts from verbatim to AsciiDoc example blocks."

for transcript in $utf8Dir/*.a3log ; do
  a3logSanitize $transcript
  if [ $? -ne 0 ] ; then
    aborting ; exit 1
  fi
done

# ------------------------------------------------------------------------------
Heading2 "Convert Docs to HTML"
# ------------------------------------------------------------------------------
for sourcefile in *.asciidoc ; do
  adoc2html $sourcefile
  if [ $? -ne 0 ] ; then
    aborting ; exit 1
  fi
done


# ------------------------------------------------------------------------------

echo -e "\e[90m------------------------------------------------------------------------------"
echo -e "\e[92m/// Finished ///\e[0m"
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
