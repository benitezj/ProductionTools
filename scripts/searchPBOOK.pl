#!/usr/bin/perl
# -w

$pbookfile=shift;
$samplename=shift;


$found=0;
$finalstatus="notgood";    

##open the book file:
open FILE, "< ${pbookfile}" or die "no  pbookfile\n";
$line=<FILE>; #first line has an ESC character
while($line=<FILE>){
    chomp($line);
    #print "$line\n";

    @words=split(" ",$line);
    #print "$words[0] $words[1]\n";
    if($words[0] eq "jediTaskID"){
	#print "$line\n";
	##READ this task info:

	##get the task id
	$taskidline=$line;
	@words=split(" ",$taskidline);
	$taskid=$words[2];

	##get the task status
	$taksstatusline=<FILE>;
	@words=split(" ",$taksstatusline);
	$status=$words[2];


	##skip some lines
	<FILE>;
	<FILE>;
	<FILE>;
	<FILE>;

	##get the sample name
	$sampleline=<FILE>;
	@words=split(" ",$sampleline);
	$sample=$words[2];
	#print ".$workds[0]. .$words[1]. .$words[2]. .$words[3]. .$sample.\n";

	##Check if this is the sample we are looking for
	if( $samplename eq $sample){	    
	    $finalstatus=$status;
	    $found=1;

####The following lines make the script hang
#	##skip some lines, after these follows the task processed files info which varies
#	<FILE>;
#	<FILE>;
#	<FILE>;
#	<FILE>;
#	<FILE>;	
#	    ##for tasks in finished state print the files info
#	    if($status ne "done" ){
#		$line=<FILE>;
#		chomp($line);
#		while($line ne "======================================"){
#		    print "$line\n";
#		    $line=<FILE>;
#		    chomp($line);
#		}
#		
#	    }


	}

    }

}


if($found == 0 ){
    print "Not found: =$samplename=\n";
}else{
    print "$taskid : $finalstatus\n";
}
    
