##see below may need to provide a file with the sample names in evgen.EVNT format

export PROD="mc15_13TeV"
if [ "$PROD" == "" ] ; then
echo "Production campaign not provided"
exit
fi

export OUTFILE=amiCrossections_${PROD}.txt
rm -f $OUTFILE

#for d in `ami list datasets ${PROD}.%.merge.AOD.%`; do 
for d in `ami list datasets ${PROD}.%.evgen.EVNT.%`; do 
#for d in `cat $1 | grep -v '#'`; do 

echo $d

##id ("run")
export run=`echo $d | awk -F'.' '{print $2}'`
##export name=`echo $d | awk -F'.' '{print $3}'`

export tmpfile='/tmp/ami.txt'

`rm -f /tmp/ami.txt`
`ami show dataset info $d > $tmpfile`

##crossection (AMI gives nb) output in pb
#export Cross=`ami show dataset info $d | grep approx_crossSection | awk '{print $3*1000}'`
#export Cross=`ami show dataset info $d | grep crossSection_mean | awk '{print $3*1000}'`
export Cross=`cat $tmpfile | grep crossSection_mean | awk '{print $3*1000}'`
if [ "$Cross" == "" ]; then 
export Cross=0
fi

#filter efficiency
#export filter=`ami show dataset info $d | grep approx_GenFiltEff | awk '{print $3}'`
export filter=`cat $tmpfile | grep GenFiltEff_mean | awk '{print $3}'`
if [ "$filter" == "" ]; then 
export filter=0
fi

#write out the final crossection after correctiong by efficiency and convert pb 
#export XE=`echo "$Cross $filter" | awk '{print $1*$2}'` 

#k-factor set to 1 for now
export kF=1

echo "$run $Cross $kF $filter $d" >> $OUTFILE

done

