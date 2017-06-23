#!/bin/bash

~/sourcecode/shell/honami.sh
ssh eccs  -o ConnectTimeout=1 '~/sourcecode/shell/honami.sh'
ssh eccs2  -o ConnectTimeout=1 '~/sourcecode/shell/honami.sh'
ssh eccs3 -o ConnectTimeout=1 '~/sourcecode/shell/honami.sh'
ssh csc  -o ConnectTimeout=1 '~/sourcecode/shell/honami.sh'
