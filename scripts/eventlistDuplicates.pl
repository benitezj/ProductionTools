#!/usr/bin/perl
# -w

$file1 = shift;#
$file2 = shift;#


####read the files only once and store run and event ids in arrays
$N1=0;
foreach $line1 (`cat $file1`){
    chomp($line1);
    $line1 =~ s/^\s+|\s+$//g; ##remove beg/end spaces
    @linewords1=split(" ",$line1);    
    $run1[$N1]   = $linewords1[0];
    $event1[$N1] = $linewords1[1];
    $N1++;
}

$N2=0;
foreach $line2 (`cat $file2`){
    chomp($line2);
    $line2 =~ s/^\s+|\s+$//g; ##remove beg/end spaces
    @linewords2=split(" ",$line2);    
    $run2[$N2]   = $linewords2[0];
    $event2[$N2] = $linewords2[1];
    $N2++;
}



###
print "\n =====Looking for duplicate events  ==========\n";
$duplicatecounter=0;
foreach $i (0 ... $N1-1){
    foreach $j (0 ... $N2-1){
	if($event2[$j]>$event1[$i]){
	    last;#break after passing the event (assuming events are ordered)
	}
	
	if(#$run2[$j]==$run1[$i] && 
	   $event2[$j]==$event1[$i]){
	    print "Duplicate: run = $run1[$i] , event = $event1[$i]\n";
	    $duplicatecounter++;
	}
    }
}


print "FILE1 : (Nevt=${N1}) $file1 \n";
print "FILE2 : (Nevt=${N2}) $file2 \n";
print "Number of duplicates: ${duplicatecounter}\n";

