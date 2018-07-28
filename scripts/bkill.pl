#!/usr/bin/perl
# -w
#
#This script creates files with a list of event collections 
#

$first=shift;
$last=shift;

$bjobid=$first;
while($bjobid<=$last){ 
    system("bkill -u benitezj $bjobid");
    #print "bkill $bjobid\n";
    $bjobid++;  
}
   
$nkilled=$last-$first+1;
print "killed $nkilled\n";
exit;
