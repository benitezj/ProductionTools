for d in `cat $1 | grep '.' | grep -v '#'`; do 
#echo $d


###EXT2 derivations : not working
#export parent=`echo $s | awk -F '.' '{print $3"."$4"."$5".merge.AOD.e3651_s2586_s2174_"$6}'`
#echo $parent

###EXOT12 p2375 derivations
ext=`echo $d | awk -F'.' '{print $6}'`
pext=`echo $ext | awk -F"_p2375" '{print $1}'`
parent=`echo $d | awk -F'.' '{print $1"."$2"."$3".merge.AOD"}'`

echo $parent.$pext
done
