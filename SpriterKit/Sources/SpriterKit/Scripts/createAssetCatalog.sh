#!/bin/bash

# createAssetCatalog
#
# Written by Peter Easdown
#
# A tool for taking the exported PNG assets from a Spriter (https://brashmonkey.com) project and
# add them to an Xcode Asset Catalog for easy use by SpriteKit.
#
# The SpriterKit package will provide access to an asset catalog like this.
#

# Announce to the user the command syntax.
#
function usage {
  echo "createAssetCatalog <spriter_file_directory> <destination_directory>"
  echo ""
  echo "where:"
  echo "  spriter_file_directory - is the name of the directory containing both the SCML and"
  echo "                           other folders of image assets as exported by Spriter."
  echo "  destination_directory  - is the name of the directory that will become the new Xcode"
  echo "                           asset catalog."
  echo ""
  echo ${1}
}

# Ensure that both parameters were provided.
#
if [ ${#} != 2 ]; then
  usage "Missing parameters"
  exit
fi

# Ensure that the user has specified an existing directory.  We could also check for a SCON/SCML file
# within it, but thats probably overkill.
#
if [ ! -d "${1}" ]; then
  usage "Input directory (Spriter exported project) does not exist."
  exit
fi

TARGET="${2}.xcassets"

# If the destination exists, then remove it.
if [ -d "${TARGET}" ]; then
    rm -rf "${TARGET}"
fi

# Now create the destination anew.
mkdir "${TARGET}"

CATALOGNAME=`basename "${2}"`

SOURCE="${1}"

# Creates the Contents.json file for an asset.  Given that Spriter only seems to export a single size of
# each asset, the Asset Catalog is configured to use a single universal sized asset.
#
# $1 = asset name
function createUniversalJSON {
    echo "{"
    echo "  \"images\" : ["
    echo "    {"
    echo "      \"idiom\" : \"universal\","
    echo "      \"filename\" : \"${1}\","
    echo "    }"
    echo "  ],"
    echo "  \"info\" : {"
    echo "    \"version\" : 1,"
    echo "    \"author\" : \"xcode\""
    echo "  }"
    echo "}"
}

# Create the Contents.json for an atlas.  Each directory within the Spriter export is treated as a new
# atlas.
#
function createSpriteAtlas {
    echo "{"
    echo "  \"info\" : {"
    echo "      \"author\" : \"xcode\","
    echo "      \"version\" : 1"
    echo "  },"
    echo "  \"properties\" : {"
    echo "     \"provides-namespace\" : false"
    echo "  }"
    echo "}"
}

# Copy the specified file from the source (the Spriter export) to the new asset catalog, but only copy
# it if it has changed.
#
# $1 = source name
# $2 = destination name
function copyFile {
    if [ ! -f "${2}" ]; then
        delta="1"
    else
        delta=`compare -metric MAE ${1} ${2} /tmp/comparenull 2>&1 | sed -e 's/ .*//'`
        rm /tmp/comparenull
    fi

    if [ "${delta}" != "0" ]; then
        cp "${1}" "${2}"
        echo "1"
    else
        echo "0"
    fi
}

# Create a universal image set for the specified asset.
#
# $1 = source image name
# $2 = asset name
# #3 = where to place the Image Set
# #4 = the atlas name - will be prepended to the asset name so that it is unique for the asset.
function createUniversalImageSet {
    if [[ "${4:0:7}" != "unnamed" ]]; then
        mkdir -p "${3}/${4}_${2}.imageset"
        copied=0

        copied=`copyFile "${1}" "${3}/${4}_${2}.imageset/${2}" + ${copied} | bc`

        if [ "${copied}" != "0" ]; then
            createUniversalJSON ${2} > "${3}/${4}_${2}.imageset/Contents.json"
        else
            echo "Skipping matching: ${1}"
        fi
    else
        mkdir -p "${3}/${2}.imageset"
        copied=0

        copied=`copyFile "${1}" "${3}/${2}.imageset/${2}" + ${copied} | bc`

        if [ "${copied}" != "0" ]; then
            createUniversalJSON ${2} > "${3}/${2}.imageset/Contents.json"
        else
            echo "Skipping matching: ${1}"
        fi
    fi
}

# Move the named asset from the Spriter export area to the asset catalog.
#
# $1 = asset name
# $2 = source image name
# $3 = sprite atlas name
# $4 = the directory within which the atlas containing the asset exists.
function moveAsset {
    ATLAS_PATH="${4}/${3}.spriteatlas"
    
    # this asset belongs in a sprite atlas.  create the atlas if needed.
    #
    if [ ! -d "${ATLAS_PATH}" ]; then
        mkdir -p "${ATLAS_PATH}"
        createSpriteAtlas > "${ATLAS_PATH}/Contents.json"
    fi
    
    createUniversalImageSet "${2}" "${1}" "${ATLAS_PATH}" "${3}"
}

# Move all of the files within the named atlas (sic. directory within the Spriter export area)
# to the asset catalog, creating a new atlas when needed.
#
# $1 = the path of the directory containing the assets to be added to the atlas.
# $2 = the path of the directory that is the new asset catalog
# $3 = the name of the atlas to which the asset is being added
function moveAtlas {
    ASSETS=`find "${1}" -iname \*.png`
    
    for ASSET in ${ASSETS}; do
        ASSET_NAME=$(basename "$ASSET")
        
        echo "  ${ASSET_NAME}"
        
        moveAsset "${ASSET_NAME}" "${ASSET}" "${3}" "${2}"
    done;
}

# if there are any png files in the Spriter export area, they will be in an unnamed folder
# within the SCML file.  So create a folder called "unnamed_<catalog>" and copy the png's into there
# so that they get picked up and placed into an atlas called "unnamed_<catalog>" where
# <catalog> is the value of $2.
#
# Any files called guide.png are ignored as they are typically put there by Robert of GDS
# as a guide only and are not needed.
#
UNNAMED_COUNT=`find ${SOURCE} -maxdepth 1 -iname \*.png | wc -l`

if [ ${UNNAMED_COUNT} -gt 0 ]; then
  
  if [ ! -d "${SOURCE}/unnamed_${CATALOGNAME}" ]; then
    mkdir "${SOURCE}/unnamed_${CATALOGNAME}"
    cp ${SOURCE}/*.png "${SOURCE}/unnamed_${CATALOGNAME}"
    
    if [ -f "${SOURCE}/unnamed_${CATALOGNAME}/guide.png" ]; then
      rm "${SOURCE}/unnamed_${CATALOGNAME}/guide.png"
    fi
  fi
fi

# find all of the directories within the Spriter export area, and treat each as a sprite atlas
# or collection of sprite assets.  Within a SCON/SCML file the atlas is a "folder" and a sprite
# asset is a "file".
#
ATLAS_SOURCES=`find ${SOURCE} -mindepth 1 -type d`

IFSbkp="$IFS"
IFS=$'\n'
for ATLAS_SOURCE in ${ATLAS_SOURCES}; do
  ATLAS_NAME=$(basename "$ATLAS_SOURCE")
  echo "Processing ${ATLAS_NAME}"

  moveAtlas "${ATLAS_SOURCE}" "${TARGET}" "${ATLAS_NAME}"
done;
IFS="$IFSbkp"

# now, clean up by removing the "unnamed_<catalog>" folder if we created one.
#
if [ -d "${SOURCE}/unnamed_${CATALOGNAME}" ]; then
  rm -rf "${SOURCE}/unnamed_${CATALOGNAME}"
fi
