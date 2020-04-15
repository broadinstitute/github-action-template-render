#!/bin/bash
#


#  any environment variables necessary for proper rendering (used in ctmpl files)
#  is assumed to be be set.

# good practise is to populate a file in root directory with all the environment
# vars that need set.
# set it up so it can be dotted at start of this script
# then maybe running with a -v option will output the expected env vars and their
# def values

# VAULT_ADDR: URL to vault server (def: https://clotho.broadinstitute.org:8200)
# VAULT_TOKEN: actual token value (highest precedence)
# VAULT_TOKEN_PATH: path to token file (def: /root/.vault-token)
# DEST_PATH: path where configs are copied and rendered (def: /working)

# configs reside under /configs directory
# all files/dirs under /configs are copied to DEST_PATH preserving the same 
#  dir structure that exists under /configs

# initialize vars
# loglevel
CONSUL_LOG_LEVEL=${CONSUL_LOG_LEVEL-"err"}
# consul template settings
CONSUL_TEMPLATE_PATH=${CONSUL_TEMPLATE-"/usr/local/bin"}
CONSUL_CONFIG=${CONSUL_CONFIG-"/etc/consul-template/config/config.json"}
# base64 command
BASE64=${BASE64:-"base64 -d"}
# file/script that sets any default values for ENV vars
DEFAULT_ENVS=${DEFAULT_ENVS:-"/defaults.sh"}
# progname
progname=$(basename $0)
# tempfile name
TMPFILE=$(mktemp ${progname}-XXXXXX)

# initialize config vars
DEST_PATH=${DEST_PATH:-"/working"}
VAULT_TOKEN=${VAULT_TOKEN:-""}
export VAULT_ADDR=${VAULT_ADDR:-"https://clotho.broadinstitute.org:8200"}
VAULT_TOKEN_FILE=${VAULT_TOKEN_FILE:-"/root/.vault-token"}

# usage function
usage()
{
   echo "Usage"
}

# error function
errorout()
{
  echo "$*"
  exit 1
}

# render function
render() 
{
  # file to render
  local cfile=$1
  # rendered file name
  local outfile="${cfile%.*}"
  # rendered file ext
  local ext1="${cfile##*.}"
  # second file extension 
  local ext2="${outfile##*.}"
  # final file IF second ext
  local finalfile="${outfile%.*}"
  # ret code var
  local retcode=0

  echo "Rendering ${file} to ${outfile} .."

  ${CONSUL_TEMPLATE_PATH}/consul-template \
        -once \
        -config=${CONSUL_CONFIG} \
        -log-level=${CONSUL_LOG_LEVEL} \
        -template=$file:$outfile
  retcode=$?
  
  if [ $retcode -eq 0 ]
  then
     # check if we need to base64 decode
     case "${ext2}" in
        b64|jks|p12)  echo "Base64 decoding ${outfile} to ${finalfile}"
          # base64
          # since ctmpl will likely create blanklines and base64 does not like
          # them  - remove them
          tr -d '\n' < ${outfile} | ${BASE64} > ${finalfile}
          retcode=$?
          # clean up intermediate file
          rm -f ${outfile}
        ;;
     esac
     # clean up ctmpl 
     rm -f ${cfile}
  fi

  return ${retcode}

}

# check vault setup function
check_vault()
{
  local retcode=0

# use vault token_lookup to both verify token and ensure communication to vault
#  exit with error message about vaut problems
  if [ -z "${VAULT_TOKEN}" ]
  then
      # token not set as env try reading from VAULT_TOKEN_FILE
      if [ -f "${VAULT_TOKEN_FILE}" ]
      then
         export VAULT_TOKEN=$(cat "${VAULT_TOKEN_FILE}")
         retcode=$?
         if [ ${retcode} -ne 0 ]
         then
             echo "ERROR: Could not read VAULT_TOKEN_FILE (${VAULT_TOKEN_FILE})!"
         fi
      else
         echo "ERROR: No VAULT_TOKEN nor VAULT_TOKEN_FILE specified"
         retcode=1
      fi
  fi
  if [ ${retcode} -eq 0 ] 
  then
     if ! vault token lookup >/dev/null 2>&1
     then
        echo "ERROR: Invalid vault token provided"
        retcode=1
     fi
  fi
  return ${retcode}
}

# getopts (maybe)

# verify DEST_PATH exists and is dir
if [ ! -d "${DEST_PATH}" ]
then
  errorout "ERROR: DEST_PATH (${DEST_PATH}) does not exist"
fi

# maybe verify you can write there
touch ${DEST_PATH}/${TMPFILE}
retcode=$?
rm -f ${DEST_PATH}/${TMPFILE}
if [ ${retcode} -ne 0 ] 
then
   errorout "ERROR: Unable to write to DEST_PATH (${DEST_PATH})"
fi

# set default env if 
if [ -f ${DEFAULT_ENVS} ]
then
   # since this file is supposed to set envs need to dot it
   . ${DEFAULT_ENVS}
fi

# run find to find all files ending in ctmpl
filelist=$(find ${DEST_PATH} -type f -name "*.ctmpl" -print)

# loop through ctmpl list to see if any have the word vault
for file in ${filelist}
do
   if grep -E vault ${file} > /dev/null 2>&1
   then
      if ! check_vault
      then
          errorout "ERROR: Vault configuration was not valid"
      fi
      break
   fi
done

# loop through ctmpl list and use consul to render

fail=0
for file in ${filelist}
do
   if ! render ${file}
   then
       echo "WARNING: render of ${file} failed"
       # TODO: create a list of failed files so can echo them all at end
       fail=1
   fi
done

if [ ${fail} -ne 0 ]
then
   errorout "ERROR: One or more files failed to render properly"
fi

exit 0
