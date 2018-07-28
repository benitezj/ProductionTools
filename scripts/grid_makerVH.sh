#!/bin/bash
export eos='/afs/cern.ch/project/eos/installation/0.3.15/bin/eos.select'

#This script takes 3 arguments always 
#1 = samples file 
#2 = action
#3 = tag applied to the sample name on the grid, should be set to "" if no tag desired


##
export SAMPLELIST=`cat $1 | grep -v "#" | grep -v / | grep -v :`

################
echo "List the input samples:"
for s in $SAMPLELIST; do
echo "${s}"
done

############
echo " "
echo "Configuration:"
#export XAODCONFIG=data/VHbbResonance/framework-run.cfg
#export XAODCONFIG=data/FrameworkExe_DB/framework-run_VVllJ.cfg
export XAODCONFIG=data/FrameworkExe_DB/framework-run_preSel.cfg
echo "XAODCONFIG $XAODCONFIG"

#For grid jobs it is needed to store submission directories.
export XAODOUTPATH=/tmp


###########################################
#######Options
#############################################

#Tag to be appended at the end of the sample name, useful for resubmitting broken jobs
export XAODOUTTAG=$3
echo "XAODOUTTAG $XAODOUTTAG"

#XAODSAMPLEPATH is needed for local jobs only.
export XAODSAMPLEPATH=""

#number of files to merge
export XAODNFILES=1
echo "XAODNFILES $XAODNFILES"

#this is for testing
export XAODNOSUBMIT=0
echo "XAODNOSUBMIT $XAODNOSUBMIT"

#Sites to black list
export XAODBLACKLIST=""
##CxAODMaker does not compile at SiGNET:
export XAODBLACKLIST="ANALY_SiGNET"
#export XAODBLACKLIST="ANALY_SiGNET,ANALY_SARA,ANALY_INFN-T1"
#export XAODBLACKLIST="ANALY_SiGNET,ANALY_LUNARC,ANALY_NSC"
#export XAODBLACKLIST="ANALY_SiGNET,ANALY_UIO,ANALY_LRZ"
echo "XAODBLACKLIST $XAODBLACKLIST"

######################################################
###Grid Production steps
######################################################
#clean directories
if [ "$2" == "clean" ]; then 
echo "Cleaning grid submission directories"
for s in $SAMPLELIST; do
echo "rm $XAODOUTPATH/${s}*"
rm -rf $XAODOUTPATH/${s}*
done
fi

#####submit jobs
if [ "$2" == "sub" ]; then 
echo "Running grid submission"
for s in $SAMPLELIST; do
export XAODSAMPLENAME=$s
cxaodmaker grid
done
fi

############################################################
#####download samples to local machine or AFS directory
############################################################
#Note: XAODOUTTAG is argument $3, enter "" if none
#OUTPATH is 4th argument 
if [ "$2" == "grid2local" ]; then 

export OUTPATH=$4
if [ "$OUTPATH" == "" ]; then
echo "OUTPATH is required."; exit
fi

for s in $SAMPLELIST; do
echo "Running Grid download for $sample"
echo ${VOMSPASSWD} | voms-proxy-init --pwstdin -voms atlas

export gridname=`echo $s | awk -F'.' '{print $1"."$2"."$3}'`
if [ "$XAODOUTTAG" != "" ]; then
export gridname=${gridname}_${XAODOUTTAG}
fi

#mkdir $OUTPATH/$s
#dq2-get -H $OUTPATH/$s user.${USER}.${gridname}_outputLabel.root/

rucio download --dir=$OUTPATH user.${USER}:user.${USER}.${gridname}_outputLabel.root
mv $OUTPATH/user.${USER}.${gridname}_outputLabel.root $OUTPATH/$s

done
fi



###############################################################
############Verify  downloads to AFS
##############################################################
#Note: XAODOUTTAG is argument $3, enter "" if none
#OUTPATH is 4th argument 
if [ "$2" == "verifylocal" ]; then 
export OUTPATH=$4
if [ "$OUTPATH" == "" ]; then
echo "OUTPATH is required."; exit
fi

for s in $SAMPLELIST; do
echo "Verifying: $s"

export gridname=`echo $s | awk -F'.' '{print $1"."$2"."$3}'`
if [ "$XAODOUTTAG" != "" ]; then
export gridname=${gridname}_${XAODOUTTAG}
fi

export gridsize=`rucio list-files user.${USER}:user.${USER}.${gridname}_outputLabel.root | grep "Total size :" | awk -F':' '{print $2/1000000}'`
export localsize=`du -s $OUTPATH/$s | awk -F' ' '{print $1/1000}'`
export diff=`echo $gridsize:$localsize | awk -F':' '{print (100*sqrt(($1-$2)*($1-$2))/$1) }'`
export pass=`echo $diff | awk '{print ($1 < 2.4)}'`
if [ "$pass" != "1" ]; then
echo "FAIL: $s"
echo "  ==> localsize = $localsize Mb  , grid = $gridsize Mb , diff = $diff % "
else
echo "PASS: $s"
fi

done 
fi


###############################################################
############Verify  downloads to EOS
##############################################################
#Note: XAODOUTTAG is argument $3, enter "" if none
#OUTPATH is 4th argument 
if [ "$2" == "verifyeos" ]; then 
echo "Verifying EOS downloads:"

export OUTPATH=$4
if [ "$OUTPATH" == "" ]; then
echo "OUTPATH in eos is required."; exit
fi


rm -f veos_complete.tmp
rm -f veos_incomplete.tmp

touch veos_complete.tmp
touch veos_incomplete.tmp

for s in $SAMPLELIST; do

export gridname=`echo $s | awk -F'.' '{print $1"."$2"."$3}'`
if [ "$XAODOUTTAG" != "" ]; then
export gridname=${gridname}_${XAODOUTTAG}
fi

echo "check $s"
#export ndq2=`dq2-ls -f user.${USER}.${gridname}_outputLabel.root/ | grep "\[" | grep .root | wc -l`
export ndq2=`rucio list-files user.${USER}:user.${USER}.${gridname}_outputLabel.root | grep outputLabel.root | wc -l`
export neos=`$eos ls $OUTPATH/$s/ | grep outputLabel.root | wc -l`
echo "From dq2: $ndq2"
echo "From eos: $neos"

if [ "$neos" == "$ndq2" ]; then
echo $s >> veos_complete.tmp
fi

if [ "$neos" != "$ndq2" ]; then
echo $s >> veos_incomplete.tmp
fi

done 

echo "Complete samples:"
cat veos_complete.tmp
echo "Incomplete samples:"
cat veos_incomplete.tmp

fi

