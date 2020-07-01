#!/bin/bash

# This is wrapper script that execs the real consul-template based on the value of the 
#  USE_LEGACY environment variable.  The default if USE_LEGACY is not set or does not 
#  exist - is true.  (ie use the legacy consul-template executable)

USE_LEGACY=${USE_LEGACY:-true}

if [ "${USE_LEGACY}" = true ]
then
   command="/usr/local/bin/consul-template-legacy"
else
   command="/usr/local/bin/consul-template-latest"
fi

exec ${command} "$@"
