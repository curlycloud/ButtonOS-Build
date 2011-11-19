#! /bin/bash
#
# Version 0.1
#   http://www.linuxquestions.org/questions/linux-software-2/how-to-install-firefox-extensions-for-all-users-808367/
#   05-22-2010, 04:22 PM
#   Narnie
# Version 0.2
#   24-07-2010
#   Maelvon
# Version 0.3
#   16-11-2011
#   gunnjo@curlycloud.com
#	Remove the sudo. sudo the entire script if you must run as a user.
# FF-3.6.*

function Usage()
{
  echo ""
  echo "Usage: "
  echo "    add_global_firefox_extension.sh [-hof]"
  echo ""
  echo "OPTIONS:"
  echo "    -o  linux|osx"
  echo "        Operating system (mandatory)"
  echo "    -f  /path/xpi_filename"
  echo "        path to the original xpi file to install in the operating system's global directory (mandatory)"
  echo "    -h  this usage information"
  echo ""
  echo "EXAMPLE:"
  echo "    add_global_firefox_extension.sh -o osx -f ./thesupergood.xpi"
  echo ""
  ## Usage always exits
  exit $E_OPTERROR
}

function CheckForFile()
{
  if [ ! -f ${FILENAME} ]
  then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "  Error: the file:"
    echo "      ${FILENAME}"
    echo "  Does not exist"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    Usage
  fi
  FILE=$(basename ${FILENAME}) 
  EXTENSION=${FILE##*.} 
  XPI=${FILE%.*}
  #echo "EXTENSION = ${EXTENSION}"
  if [ "${EXTENSION}" = xpi ]
  then
    continue
  else
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "  Error: ${FILENAME} is not a *.xpi file"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    Usage
  fi
}

function CheckForOs()
{
  ## most importantly, the file must exist
  if [ "${OSNAME}" = osx ]
  then
    EXTDIR="/Library/Application Support/Mozilla/Extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
  elif [ "${OSNAME}" = linux ]
  then
    EXTDIR=${DEFEXT}
  else
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "  Error: the operating system:"
    echo "      ${OSNAME}"
    echo "  Is not implemented, the defaults are \"osx\" or \"linux\"."
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    Usage
  fi
  [ ! -e "$EXTDIR" ] && echo "$EXTDIR doesn't exist" && echo 0
}

function CheckUser()
{
	[ "x$UID" != "x0" ] && echo sudo $* && exit 1
}
function CheckArgs()
{
  ## Process the arguments passed in
  while getopts ":o:f:d:h" Option
  do
    case $Option in
    o    ) OSNAME=$OPTARG ## mandatory
           #echo "OSNAME = $OSNAME"
           CheckForOs
           ;;
    f    ) FILENAME=$OPTARG ## mandatory
           ## make sure the file exists
           #echo "FILENAME = $FILENAME"
           CheckForFile
           ;;
           ## show Usage, do not use ?
           ## an unsupported/invalid option will set ? so the switch statement would
           ## never reach the default case. in order to use a default case to explain
           ## that an unsupported/invalid option was used set the "help" switch as -h
           ## or something other than -?
    h    ) Usage
           ;;
           ## default if an invalid option was entered
    d    ) DEFEXT=$OPTARG
           ## Optionaly set the install directory
           ;;
    *    ) echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
           echo "  Error: invalid option selected"
           echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
           Usage
    esac
  done
  ## Must at least have a file name using the -f switch
  ## check here in case only optional arguments were used
  if [ ! ${OSNAME} ]
  then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "  Error: the \"-o linux|osx\" option is mandatory"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    Usage
  elif [ ! ${FILENAME} ]
  then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "  Error: the \"-f /path/filename\" option is mandatory"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    Usage
  fi
}

setUp () {
    if [ ! -f ${FILENAME} ] ; then
        echo "File doesn't exist"
        exit 1
    fi
    umask 0022
    if [ -d $TMPDIR ] ; then
        (cd $TMPDIR ; rm -rf *)
    else
        mkdir -p "$TMPDIR"
        #cd $TMPDIR
    fi
    echo -e "\n\nworking . . .\n\n"
    unzip "${FILENAME}" -d "$TMPDIR" &> /dev/null
}

getID () {

eval `xmlstarlet sel -N rd="http://www.w3.org/1999/02/22-rdf-syntax-ns#" \
	-N em="http://www.mozilla.org/2004/em-rdf#" \
	-t \
		-m '/rd:RDF/rd:Description/em:id'  -o "ID=&quot;" -v . -o "&quot;" -n \
		-m '/rd:RDF/rd:Description/em:name'  -o "NAME=&quot;" -v . -o "&quot;" -n \
		-m '/rd:RDF/rd:Description/em:version'  -o "VERSION=&quot;" -v . -o "&quot;" -n \
		 $TMPDIR/install.rdf`
[ "X$ID" = "" ] && echo no starting && exit 1

}

installExtension () {
    if [ -d "$EXTDIR/$ID" ] ; then
        rm -rvf "$EXTDIR/$ID"
    fi
    mv -vv "$TMPDIR" "$EXTDIR/$ID"
    if [ $? = 0 ] ; then
        echo -e "\n\nThe extension \"$XPI.$EXTENSION\" ($NAME - $VERSION) was globally installed\n\n"
    else
        echo -e "\n\nError installing \"$XPI.$EXTENSION\" extension\n\n"
    fi
}

getPath () {
    (
    cd ${1%%/*}
    pwd
    )
}

cleanUp () {
    if [ -d $TMPDIR ] ; then
        rm -rf $TMPDIR
    fi
    exit $1
}

TMPDIR="/tmp/ff_global_xpi"
DEFEXT="/usr/lib/firefox-addons/extensions"

trap "cleanUp 1" 1 2 3 15

CheckUser 

CheckArgs "${@}"

setUp

getID

installExtension

cleanUp
