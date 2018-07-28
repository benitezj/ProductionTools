export INFILE=$1
export BKG=$2

##input format is from Plotter::printGenEvents()

cat $INFILE  | grep $BKG | awk -F" " '{printf "%-10s %s\n",$3,$5}' >> ${INFILE}_clean.txt
