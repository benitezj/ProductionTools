export OUTFILE=amiEvents.txt
rm -f $OUTFILE

for d in `cat $1 | grep '.' | grep -v '#'`; do 
echo $d

export run=`echo $d | awk -F'.' '{print $2}'`

export tmpfile='/tmp/ami.txt'

`rm -f /tmp/ami.txt`
`ami show dataset info $d > $tmpfile`

export Events=`cat $tmpfile | grep totalEvents | awk '{print $3}'`
if [ "$Events" == "" ]; then 
export Events=0
fi

export Files=`cat $tmpfile | grep nFiles | awk '{print $3}'`
if [ "$Files" == "" ]; then 
export Files=0
fi

export Status=`cat $tmpfile | grep prodsysStatus | awk '{print $3}'`
if [ "$Status" == "" ]; then 
export Status=0
fi

echo "$run $Events $Files $Status $d" >> $OUTFILE

done
