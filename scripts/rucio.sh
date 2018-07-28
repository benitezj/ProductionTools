#usage: rucio.sh search mc15_13TeV:*Sherpa*Zmumu*DAOD_EXOT12*_p2419
echo $1, $2

echo ${VOMSPASSWD} | voms-proxy-init --pwstdin -voms atlas

###search and sort samples 
if [ "$1" == "search" ]; then 
#rucio list-dids mc15_13TeV:*DAOD_EXOT12*r6282_p2419 | grep ttbar | awk -F'|' '{print $2}' | awk -F':' '{print $2}' | sort
rucio list-dids $2 | awk -F'|' '{print $2}' | awk -F':' '{print $2}' | awk -F' ' '{print $1}' | sort
fi

