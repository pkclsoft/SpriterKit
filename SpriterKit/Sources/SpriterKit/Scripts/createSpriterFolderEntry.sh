#!/bin/bash

# createSpriterFolderEntry
#
# Written by Peter Easdown
#
# A tool for manualy generating a Spriter "folder" XML element for manual inclusion within
# a Spriter project file.
#
# Use this when you are crafting manually, a Spriter project file, or replacing art assets
# within an existing project file.
#

# Announce to the user the command syntax.
#
function usage {
  echo "createSpriterFolderEntry <spriter_folder>"
  echo ""
  echo "where:"
  echo "  spriter_folder - is the name of the directory containing the art assets that"
  echo "                   are to be included in the folder within the project."
  echo ""
  echo ${1}
}

# Look for all of the files within the named folder (sic. directory within the Spriter export area)
# and output the folder as a Spriter <folder> element.
#
# $1 = the path of the directory containing the files to be added to the folder.
# $2 = the name of the spriter folder to which the files are being added
function processFolder {
  echo "    <folder id=\"0\" name=\"${2}\">"
  
  IMAGEFILES=`find "${1}" -iname \*.png`
  
  ID=0
  
  for IMAGEFILE in ${IMAGEFILES}; do
      IMAGEFILE_NAME=$(basename "$IMAGEFILE")
            
      DETAILS=`file ${IMAGEFILE}`
      WIDTH=`echo ${DETAILS} | sed -e 's/^.*, \([0-9]*\) .*/\1/'`
      HEIGHT=`echo ${DETAILS} | sed -e 's/.*, \([0-9]*\) x \([0-9]*\), .*/\2/'`
      
      echo "      <file id=\"${ID}\" name=\"${2}/${IMAGEFILE_NAME}\" width=\"${WIDTH}\" height=\"${HEIGHT}\" pivot_x=\"0\" pivot_y=\"1\"/>"
      
      ID=`echo ${ID} + 1 | bc`
  done;
  
  echo "    </folder>"
}

# Ensure that both parameters were provided.
#
if [ ${#} != 1 ]; then
  usage "Missing parameters"
  exit
fi

SOURCE="${1}"

# find all of the directories within the export area, and treat each as a spriter folder
# or collection of sprite assets.
#
FOLDER_SOURCES=`find ${SOURCE} -mindepth 1 -type d`

IFSbkp="$IFS"
IFS=$'\n'
for FOLDER_SOURCE in ${FOLDER_SOURCES}; do
  FOLDER_NAME=$(basename "$FOLDER_SOURCE")
  echo "Processing ${FOLDER_NAME}"

  processFolder "${FOLDER_SOURCE}" "${FOLDER_NAME}"
done;
IFS="$IFSbkp"
