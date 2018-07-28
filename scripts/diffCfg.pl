#!/usr/bin/perl
# -w

$file1 = shift;#file1 is the test file
$file2 = shift;#file2 is the reference file 

print "[FILE1] \n";
print " FILE2\n";

######READ the first file
$counter1 = 0;
foreach $line (`cat $file1`){
    chomp($line);
    #print "$line\n";

    $line =~ s/^\s+|\s+$//g; ##remove beg/end spaces
    
    #skip lines commented out
    if( $line =~ /^#/ || $line eq ""){
	next;
    }
    
    #print "$line\n";


    ##get the type of variable and name
    @linewords=split(" ",$line);    
    $linewords[0] =~ s/^\s+|\s+$//g;
    $linewords[1] =~ s/^\s+|\s+$//g;
    $type1[$counter1] = $linewords[0];
    $name1[$counter1] = $linewords[1];
    
    ##get the variable value
    @linewords=split(/=/,$line);    
    @linewords=split(/#/,$linewords[1]); #clean comments after the value
    $linewords[0] =~ s/^\s+|\s+$//g;
    $value1[$counter1] = $linewords[0];

    
    #print "$type1[$counter1],$name1[$counter1],$value1[$counter1]\n";
    $counter1++;
}


####Read the second file
$counter2 = 0;
foreach $line (`cat $file2`){
    chomp($line);
    #print "$line\n";

    $line =~ s/^\s+|\s+$//g; ##remove beg/end spaces
    
    #skip lines commented out
    if( $line =~ /^#/ || $line eq ""){
	next;
    }
    
    #print "$line\n";


    ##get the type of variable and name
    @linewords=split(" ",$line);    
    $linewords[0] =~ s/^\s+|\s+$//g;
    $linewords[1] =~ s/^\s+|\s+$//g;
    $type2[$counter2] = $linewords[0];
    $name2[$counter2] = $linewords[1];
    
    ##get the variable value
    @linewords=split(/=/,$line);    
    @linewords=split(/#/,$linewords[1]); #clean comments after the value
    $linewords[0] =~ s/^\s+|\s+$//g;
    $value2[$counter2] = $linewords[0];

    
    #print "$type2[$counter2],$name2[$counter2],$value2[$counter2]\n";
    $counter2++;
}


####determine variables in file1 which do not match to file2
print "\n ===== MISMATCHED VARIABLES ==========\n";
foreach $i ( 0 ... $counter1 -1 ){
    #print "$type2[$i],$name2[$i],$value2[$i]\n";
    
    $found=0;
    $typematch=0;
    $valuematch=0;
    foreach $j ( 0 ... $counter2 -1 ){
	if ( $name2[$j] eq $name1[$i] ){
	    $found=$j;
	    
	    if ( $type1[$i] eq $type2[$j] ){
		$typematch=1;
	    }

	    if ( $value1[$i] eq $value2[$j] ){
		$valuematch=1;
	    }
	    
	    last;
	}

    }
    #print $name1[$i],$found,"\n";

    if($found>0){
	if(!$typematch){
	    print "[$type1[$i]],$name1[$i],$value1[$i]\n";
	    print "$type2[$found],$name2[$found],$value2[$found]\n\n";
	}
	if(!$valuematch ){
	    print "$type1[$i],$name1[$i],[$value1[$i]]\n";
	    print "$type2[$found],$name2[$found],$value2[$found]\n\n";
	}
    }
}


####variables not found in reference
print "\n\n =====  VARIABLES NOT FOUND ==========\n";
foreach $i ( 0 ... $counter1 -1 ){
    $found=0;
    foreach $j ( 0 ... $counter2 -1 ){
	if ( $name2[$j] eq $name1[$i] ){
	    $found=1;
	}
    }

    if(!$found ){
	print "$type1[$i] $name1[$i] = $value1[$i] \n";
    }
}




####look for missing variables
print "\n\n ===== VARIABLES MISSING ==========\n";
foreach $j ( 0 ... $counter2 -1 ){
    $found=0;
    foreach $i ( 0 ... $counter1 -1 ){
	if ( $name2[$j] eq $name1[$i] ){
	    $found=1;
	}
    }

    if(!$found ){
	print "$type2[$j] $name2[$j] = $value2[$j] \n";
    }
}


