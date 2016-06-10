#!/usr/bin/env bash

AGENT_NUM=$1

if [ -z "$AGENT_NUM" ]; then
    echo "Usage: clone-go-agent.sh \AGENT_NUM"
    exit 1
fi

cp /etc/init.d/go-agent /etc/init.d/go-agent-$AGENT_NUM

sed -i 's/# Provides: go-agent$/# Provides: go-agent-$AGENT_NUM/g' /etc/init.d/go-agent-$AGENT_NUM

ln -s /usr/share/go-agent /usr/share/go-agent-$AGENT_NUM

cp /etc/default/go-agent /etc/default/go-agent-$AGENT_NUM

mkdir /var/{lib,log}/go-agent-$AGENT_NUM

chown go:go /var/{lib,log}/go-agent-$AGENT_NUM