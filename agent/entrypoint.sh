#!/bin/bash
echo "### copy ossec.conf file to dir ###"
envsubst < "/agent/ossec.conf" > "/var/ossec/etc/ossec.conf"
# cp -R /var/ossec/etc/ossec1.conf /var/ossec/etc/ossec.conf

echo "### start registration process ###"
/var/ossec/bin/agent-auth -m $wazuh_manager -G $wazuh_groups -P $wazuh_password

#run falco into docker image.
falco-probe-loader
falco -d 2>&1 &

# Start the agent
/var/ossec/bin/ossec-control start
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start agent: $status"
  exit $status
fi
echo "background jobs running, listening for changes"

while sleep 300; do
  /var/ossec/bin/ossec-control status > /dev/null 2>&1
  status=$?
  if [ $status -ne 0 ]; then
    echo "looks like the agent died."
  fi
done