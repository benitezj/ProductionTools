source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh
source $ATLAS_LOCAL_RCSETUP_PATH/rcSetup.sh
lsetup rucio
lsetup panda
lsetup pyami 
echo ${VOMSPASSWD} | voms-proxy-init --pwstdin -voms atlas

#source ${ATLAS_LOCAL_ROOT_BASE}/packageSetups/atlasLocalRucioClientsSetup.sh --rucioclientsVersion ${rucioclientsVersionVal}
#source ${ATLAS_LOCAL_ROOT_BASE}/packageSetups/atlasLocalPandaClientSetup.sh --pandaClientVersion ${pandaClientVersionVal}  currentJedi --noAthenaCheck
#source ${ATLAS_LOCAL_ROOT_BASE}/packageSetups/atlasLocalPyAmiSetup.sh --pyAMIVersion ${pyAMIVersionVal}
