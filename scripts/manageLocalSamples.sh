#!/bin/bash
export eos='/afs/cern.ch/project/eos/installation/0.3.15/bin/eos.select'

export SAMPLELIST=`cat $1 | grep -v "#" | grep -v / | grep -v :`

###print the samples
for s in $SAMPLELIST; do
echo $s
done

if [ "$2" == "" ]; then 
exit
fi

echo ${VOMSPASSWD} | voms-proxy-init --pwstdin -voms atlas

#########################
##### Check sites containing the samples
#########################
if [ "$2" == "replicas" ]; then 
echo "Check replicas"
for s in $SAMPLELIST; do
export SCOPE=`echo $s | awk -F'.' '{print $1}'`
if [[ "$SCOPE" == "group" || "$SCOPE" == "user" ]] ; then
export SCOPE=`echo $s | awk -F'.' '{print $1"."$2}'`
fi
rucio list-dataset-replicas ${SCOPE}:$s
done
fi


###########################
##### estimate disk size
##########################
#output path must be provided as 4th argument on command line
if [ "$2" == "size" ]; then 
echo "estimating disk size"
for s in $SAMPLELIST; do
#export size=`dq2-ls -f $s/ | grep "total size:" | awk -F'size:' '{print $2/1000000000}'`
export SCOPE=`echo $s | awk -F'.' '{print $1}'`
if [[ "$SCOPE" == "group" || "$SCOPE" == "user" ]] ; then
export SCOPE=`echo $s | awk -F'.' '{print $1"."$2}'`
fi

export size=`rucio list-files $SCOPE:$s | grep "Total size :" | awk -F':' '{print $2/1000000000}'`
export Total=`echo $Total.$size | awk -F'.' '{print $1+$2}'`
echo "$size Gb : $s"
done
echo "Total = $Total Gb"
fi

##########################
#### verify downloads
##########################
#output path must be provided as 4th argument on command line
if [ "$2" == "verifylocal" ]; then 
echo "Verify local samples"
export OUTPATH=$3

for s in $SAMPLELIST; do

export SCOPE=`echo $s | awk -F'.' '{print $1}'`

if [[ "$SCOPE" == "group" || "$SCOPE" == "user" ]] ; then
export SCOPE=`echo $s | awk -F'.' '{print $1"."$2}'`
fi

export gridsize=`rucio list-files $SCOPE:$s | grep "Total size :" | awk -F':' '{print $2/1000000}'`

export gridcheck=`echo $gridsize | awk '{print ($1 > 0.)}'`
if [ "$gridcheck" == "1" ]; then
export localsize=`du -s $OUTPATH/$s | awk -F' ' '{print $1/1000}'`
export diff=`echo $gridsize:$localsize | awk -F':' '{print (100*sqrt(($1-$2)*($1-$2))/$1) }'`
export pass=`echo $diff | awk '{print ( ($1 < 2.4) && ($1 > 2.3) )}'`
fi

if [ "$pass" != "1" ]; then
echo "FAIL: $s"
echo "    grid = $gridsize Mb , local = $localsize Mb  ,  diff/grid = $diff % "
else
echo "PASS: $s"
fi

done

fi


##########################
#### check samples against a list in an input file
##########################
if [ "$2" == "diff" ]; then 
echo "Diffing sample list"
#This can be a directory or a file
export OUTPATH=$3

export foundcounter=0
export notfoundcounter=0
for s in $SAMPLELIST; do

if [ -d "$OUTPATH" ]; then
export check=`/bin/ls $OUTPATH | grep $s`
else
export check=`cat $OUTPATH | grep $s`
fi

if [ "$check" == "" ]; then
echo $s >> diff_notfound.tmp
export notfoundcounter=`echo $notfoundcounter | awk '{print $1+1}'`
else
echo $s >> diff_found.tmp
export foundcounter=`echo $foundcounter | awk '{print $1+1}'`
fi
done

echo "FOUND : $foundcounter "
cat diff_found.tmp
echo 
echo "NOT FOUND : $notfoundcounter "
cat diff_notfound.tmp

rm -f diff_found.tmp
rm -f diff_notfound.tmp
fi


###########################
##### download Grid samples to local
##########################
#output path must be provided as 4th argument on command line
if [ "$2" == "grid2local" ]; then 
echo "Downloading xAOD samples to cluster."
export OUTPATH=$3
if [ "$OUTPATH" == "" ]; then exit; fi
for s in $SAMPLELIST; do
echo "Running Grid download for $s"
date
echo ${VOMSPASSWD} | voms-proxy-init --pwstdin -voms atlas

export SCOPE=`echo $s | awk -F'.' '{print $1}'`
if [[ "$SCOPE" == "group" || "$SCOPE" == "user" ]] ; then
export SCOPE=`echo $s | awk -F'.' '{print $1"."$2}'`
fi
rucio download --dir=$OUTPATH $SCOPE:$s

done
fi

###########################
##### Check the sites containing the samples
##########################
if [ "$2" == "sites" ]; then 
echo "Check sites"
for s in $SAMPLELIST; do
echo "========================================"

export SCOPE=`echo $s | awk -F'.' '{print $1}'`
if [[ "$SCOPE" == "group" || "$SCOPE" == "user" ]] ; then
export SCOPE=`echo $s | awk -F'.' '{print $1"."$2}'`
fi

rucio list-dataset-replicas $SCOPE:$s
done
fi

###########################
##### download samples in the CERN disk 
##########################
#output path must be provided as 4th argument on command line
if [ "$2" == "CERN2local" ]; then 
echo "Downloading CERN DATADISK samples to cluster"
export OUTPATH=$3
echo ${VOMSPASSWD} | voms-proxy-init --pwstdin -voms atlas
if [ "$OUTPATH" == "" ]; then exit; fi

for s in $SAMPLELIST; do
echo "download for $s"
date

export SCOPE=`echo $s | awk -F'.' '{print $1}'`
if [[ "$SCOPE" == "group" || "$SCOPE" == "user" ]] ; then
export SCOPE=`echo $s | awk -F'.' '{print $1"."$2}'`
fi

for f in `rucio list-file-replicas $SCOPE:$s | grep cern.ch | grep .root | awk -F'/eos/' '{print $2}'`; do
$eos cp /eos/$f $OUTPATH/$s/
done
done
fi


#################################
##### Copy from EOS to local/AFS
#################################
export INPATH=$3
export OUTPATH=$4
if [ "$2" == "eos2local" ]; then 
echo "Copying from eos to local:"
for s in $SAMPLELIST; do
echo "INPATH: $INPATH/$s"
echo "OUTPATH: $OUTPATH/$s"
rm -rf $OUTPATH/$s
$eos cp -r $INPATH/$s/ $OUTPATH/$s/
done
fi


#################################
##### Copy from EOS to local/AFS
#################################
export INPATH=$3
export OUTPATH=$4
if [ "$2" == "local2eos" ]; then 
echo "Copying from local to EOS:"
for s in $SAMPLELIST; do
echo "INPATH: $INPATH/$s"
echo "OUTPATH: $OUTPATH/$s"

##Delete what is there if any
for f in `$eos ls $OUTPATH/$s | grep .root`; do
$eos rm $OUTPATH/$s/$f;
done

$eos mkdir $OUTPATH/$s 
for f in `/bin/ls $INPATH/$s | grep .root`; do
$eos cp $INPATH/$s/$f $OUTPATH/$s/
done

#$eos cp -r $INPATH/$s/ $OUTPATH/$s/
done
fi


#################################
##### cix permissions in EOS
#################################
export INPATH=$3
export OUTPATH=$4
if [ "$2" == "eoschmod" ]; then 
echo "Copying from local to EOS:"

for s in $SAMPLELIST; do
echo "INPATH: $INPATH/$s"
echo "OUTPATH: $OUTPATH/$s"
$eos chmod -r 750 $OUTPATH/$s
done

$eos chmod -r 750 $OUTPATH

fi


###################################
############ list samples in local/AFS space
##################################
#output path must be provided as 4th argument on command line
export OUTPATH=$3
if [ "$2" == "lafs" ]; then 
echo "Samples in $OUTPATH/:"
for s in $SAMPLELIST; do
echo "====$s==="
/bin/ls $OUTPATH/$s
done
fi

##################################
############list samples in eos
##################################
#output path must be provided as 4th argument on command line
export OUTPATH=$3
if [ "$2" == "leos" ]; then 
echo "Samples in $OUTPATH:"
for s in $SAMPLELIST; do
echo "======$s========"
$eos ls $OUTPATH/$s
done 
fi

###################################
############remove afs sample
##################################
#output path must be provided as 4th argument on command line
export OUTPATH=$3
if [ "$2" == "rmafs" ]; then 
echo "Removing samples on /afs"
for s in $SAMPLELIST; do
echo "Removing $s:"
rm -rf $OUTPATH/$s
done 
fi

##################################
############remove eos sample
##################################
#$3 is the full path to the eos folder containing the sample
export OUTPATH=$3
#$4 is the string to match files 
export MATCH=$4
if [ "$2" == "rmeos" ]; then 
echo "Removing samples on eos: $OUTPATH"
for s in $SAMPLELIST; do
echo "Removing $s:"
for f in `$eos ls $OUTPATH/$s | grep $MATCH`; do
$eos rm $OUTPATH/$s/$f;
#echo "rm $OUTPATH/$s/$f\n";
done
$eos rmdir $OUTPATH/$s/
done 
fi


#################################
##### merge hist and CxAOD.root (DB framework)
#################################
export OUTPATH=$3
if [ "$2" == "merge" ]; then 
echo "Merging"
for s in $SAMPLELIST; do
echo "$s"

#get the short sample name
export SAMPLE=`echo $s | awk -F '.' '{print $1"."$2"."$3"."$4"."$5}'`

rm -rf $OUTPATH/$s.merged 
mkdir $OUTPATH/$s.merged 

export HISTSAMP=`cat $1.hist | grep $SAMPLE`

for f in `/bin/ls $OUTPATH/$s | grep CxAOD.root`; do
#echo "$OUTPATH/$s/$f"
export HISTFILE=`echo $f | sed 's/CxAOD.root/hist-output.root/'`

if [ -e "$OUTPATH/$HISTSAMP/$HISTFILE" ]; then
#echo "$OUTPATH/$HISTSAMP/$HISTFILE"
hadd $OUTPATH/$s.merged/$f $OUTPATH/$s/$f $OUTPATH/$HISTSAMP/$HISTFILE
fi

done

done
fi
