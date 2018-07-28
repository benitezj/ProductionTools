#This script needs to run from an athena testarea, run like this:
#lumi.sh /afs/cern.ch/work/b/benitezj/CxTupleSamples/Zee/00-00-06/samples.txt 

#Input file contains a list of sample names in one column, eg.:
#data12_8TeV.00202660.physics_Muons.merge.AOD.r5724_p1751
#..

###To produce the Pile-Up distribution 
## 1) execute command for all runs and
## 2) add option: --plots 


#remove output file 
rm -f lumi.txt

#loop over the input samples and calculate lumi for each
for s in `cat $1 | grep data | grep -v "#" | grep -v "/" `; do

export RUN=`echo ${s} | awk -F'.' '{print $2}'`

###8TeV lumi estimation
#export RESULT=`iLumiCalc.exe --runnumber=$RUN --quiet --lumitag=OflLumi-8TeV-003 --livetrigger=L1_EM30 --trigger=None --xml=/afs/cern.ch/user/b/benitezj/scratch0/testCxAODFramework/00-00-06/VHbbResonance/data/data12_8TeV.periodAllYear_DetStatus-v61-pro14-02_DQDefects-00-01-00_PHYS_StandardGRL_All_Good.PeriodB.xml --lar --lartag=LARBadChannelsOflEventVeto-UPD4-04 | grep 'Total IntL recorded'`

###13TeV July15: currently in 20.1.5 seems not working due to not finding trigger L1_EM12 in COOL
export RESULT=`iLumiCalc.exe --runnumber=$RUN --lumitag=OflLumi-13TeV-001 --livetrigger=L1_EM12 --trigger=None --xml=./VHbbResonance/data/data15_13TeV.periodAllYear_DetStatus-v62-pro18-01_DQDefects-00-01-02_PHYS_StandardGRL_All_Good.xml --lar --lartag=LARBadChannelsOflEventVeto-RUN2-UPD4-04 | grep 'Total IntL recorded'`


export LUM=`echo $RESULT | awk -F' ' '{print $6}'`

if [ "$LUM" == "" ]; then
echo "0 $s" >> lumi.txt
fi 
if [ "$LUM" != "" ]; then
echo "${LUM} $s" >> lumi.txt
fi

done


###Add up to get total luminosity
export TOTLUM=`gawk '{ sum += $1 }; END { print sum }' lumi.txt`
echo "Total Luminosity: ${TOTLUM}/1000000" >> lumi.txt
cat lumi.txt

