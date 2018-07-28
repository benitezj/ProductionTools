#!/usr/bin/perl
# -w
use File::Basename;
$eos="/afs/cern.ch/project/eos/installation/0.3.15/bin/eos.select";

$samplesfile=shift;#must be a full path in AFS
$option=shift;

##Determine path where log files will be written
$samplesfile = `readlink -e $samplesfile`;
chomp($samplesfile);
$SUBMITDIR = dirname($samplesfile);

##determine the input and output paths
open(my $FILEHANDLE, '<:encoding(UTF-8)', $samplesfile)
or die "Could not open file '$samplesfile' $!";
$INPUTDIR = <$FILEHANDLE>;
$INPUTDIR =~ s/^\s+|\s+$//g;
$OUTPUTDIR = <$FILEHANDLE>;
$OUTPUTDIR =~ s/^\s+|\s+$//g;

##determine if reading from EOS
$instorage="";
if( `echo $INPUTDIR | grep eos` ne ""){
$instorage="eos";
}


##determine if writing to EOS
$outstorage="";
if( `echo $OUTPUTDIR | grep eos` ne ""){
    $outstorage="eos";
}


print "SUBMITDIR = $SUBMITDIR\n";
print "INPUTDIR = $INPUTDIR\n";
print "OUTPUTDIR = $OUTPUTDIR\n";
print "input storage = $instorage\n";
print "output storage = $outstorage\n";

##read the samples list
@samples=`cat $samplesfile | grep -v "#" | grep -v '/' `;
$counter = 0;
foreach $samp (@samples){
	chomp($samp);
	$samp =~ s/^\s+|\s+$//g; ##remove beg/end spaces
	print "$option $samp\n";
	$samples[$counter] = $samp;
	$counter++;
}

####Clean out the output directory
if($option eq "clean"){
    print "Removing all files inside output directory:\n";
    print "-------------------------\n";
    foreach $samp (@samples){
	if($outstorage == "eos"){
	    @files=`$eos ls $OUTPUTDIR/$samp`; 
	    foreach $file (@files){
		chomp($file);
		$command="$eos rm $OUTPUTDIR/$samp/$file";
		print "$command\n";
		system($command);
	    }
	}else {
	    $command="rm -rf $OUTPUTDIR/$samp";
	    print "$command \n";
	    system($command);
	}
    }


    ####clean out the submission directory
    print "Removing all files in submit directory:\n";
    print "-------------------------\n";
    foreach $samp (@samples){
	$command="rm -rf ${SUBMITDIR}/${samp}";
	print "$command \n";
	system($command);
    }

}



#######FUNCTIO N FOR MAKING SHELL EXECUTION SCRIPTS
sub makeBatchExecutable {
    $OUTPUTDIR = $_[0];
    $SUBMITDIR = $_[1];
    $sample = $_[2];
    $idx = $_[3];
    $cpin = $_[4];
    $cpout = $_[5];
    $filelist = $_[6];

    $outfile="${SUBMITDIR}/${sample}/tuple_${idx}.sh";
    `rm -f $outfile`;
    `touch $outfile`;

    `echo "source /cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase/user/atlasLocalSetup.sh " >> $outfile`;
    `echo "source \\\$LS_SUBCWD/rcSetup.sh " >> $outfile`;
    `echo "mkdir -p ./tmp/${sample} " >> $outfile`;
    `echo "${cpin} ${filelist} ./tmp/${sample}/" >> $outfile`;
    `echo "export XAODCONFIG=data/CxAODMaker_VHbbResonance/framework-run_DAOD.cfg" >> $outfile`;
    `echo "export XAODNFILES=1" >> $outfile`;
    `echo "export XAODMAXEVENTS=-1" >> $outfile`;
    `echo "export XAODSAMPLEPATH=./tmp/" >> $outfile`;
    `echo "export XAODSAMPLENAME=${sample}" >> $outfile`;
    `echo "export XAODOUTPATH=." >> $outfile`;
    `echo "printenv " >> $outfile`;
    `echo "cxaodmaker local " >> $outfile`;
    `echo "${cpout} ./${sample}/data-outputLabel/outputLabel.root ${OUTPUTDIR}/${sample}/outputLabel_${idx}.root " >> $outfile`; 
}

######Make the execution scripts
if($option eq "create"){
    #Number of files to merge
    $nmerge=shift;
    print "Number of files to merge per job: $nmerge \n";
     
    #Determine how to read the input
    if($instorage eq "eos"){
	$cpin="$eos cp";
    }else {
	$cpin="/bin/cp";
    }

    #determine how to write the output
    if($outstorage eq "eos"){
	$cpout="$eos cp";
    }else{
	$cpout="/bin/cp";
    }
    

    foreach $samp (@samples){
	#create the submission directory
	`mkdir $SUBMITDIR/$samp`;

	#create the output directory
	if($outstorage eq "eos"){
	    $command="$eos mkdir $OUTPUTDIR/$samp";
	    print "$command\n";
	    system($command);
	}else{
	    $command="mkdir $OUTPUTDIR/$samp";
	    print "$command\n";
	    system($command);
	}

	#get list of files in storage
	if($instorage eq "eos"){
	    @dirlist=`$eos ls $INPUTDIR/$samp | grep .root`;
	}else {
	    @dirlist=`/bin/ls $INPUTDIR/$samp | grep .root`;
	}

	##loop over the input files and merge
	$filelist="";
	$mergecounter=0;
	$idx=0;	
	for $f (@dirlist){
	    chomp($f);
	    $filelist = "${filelist} ${INPUTDIR}/${samp}/${f}";
	    $mergecounter++;

	    if( $mergecounter == $nmerge ){
 		makeBatchExecutable($OUTPUTDIR,$SUBMITDIR,$samp,$idx,$cpin,$cpout,$filelist);
		$filelist="";
		$mergecounter=0;
		$idx++;
	    }
	}
	if($mergecounter>0){
	    makeBatchExecutable($OUTPUTDIR,$SUBMITDIR,$sample,$idx,$cpin,$cpout,$filelist);	
	    $idx++;
	}

	print "\n $idx : ${samp}\n";
    }
}

####define batch submit function
sub submit {
    $path = $_[0];
    $idx = $_[1];
    $qu = $_[2];

    if($qu ne "1nh" && $qu ne "8nh" && $qu ne "1nd" && $qu ne "2nd"){ 
	$qu="8nh";
    }
    
    system("rm -f ${path}/tuple_${idx}.log");
    $command="bsub -C 0 -R \"pool>10000\" -q ${qu} -J ${idx} -o ${path}/tuple_${idx}.log < ${path}/tuple_${idx}.sh";	
    print "$command\n";
    system("$command");
}

    
#submit all jobs
if($option eq "sub" ){
    ##provide queue
    $qu=shift;

    foreach $samp (@samples){
	$idx=0;	
	for $f (`/bin/ls $SUBMITDIR/$samp | grep tuple_ | grep .sh`){
	    chomp($f);
	    submit("$SUBMITDIR/$samp",$idx,$qu);
	    $idx++;
	}
	print "\n Submitted $idx jobs for ${samp}\n";
    }
}


if($option eq "check"){
    $qu=shift;

    foreach $samp (@samples){
	$idx=0;	
	$failcounter=0;
	for $f (`/bin/ls $SUBMITDIR/$samp | grep tuple_ | grep .sh | grep -v "~" `){
	    chomp($f);
	    $job="${SUBMITDIR}/${samp}/tuple_${idx}";

	    $failed=0;

	    #check a log file was produced
	    if(!(-e "${job}.log")){ 
		print "No log file \n ${job}\n"; 
		$failed = 1; 
	    }

	    # there were input events: inputCounter = 100000
	    if( $failed == 0){ 
		$inputEvents=`cat  ${job}.log | grep processed`;
		chomp($inputEvents);
		@evtsproc=split(" ",$inputEvents);
		if( !($evtsproc[5] > 0)){
		    print "No input events \n ${job}\n"; 
		    $failed = 1;
		}
	    }
	
	    # check Successfully completed.
	    if( $failed == 0){
		$success = `cat ${job}.log | grep "Successfully completed."`;
		if($success eq "" ){
		    print "Not successfully completed \n ${job}\n";
		    $failed = 1;
		}
	    } 

	
	    #check the root file exists 
	    if($failed == 0){
		if($outstorage eq "eos"){
		    $exists=`$eos ls $OUTPUTDIR/$samp/outputLabel_${idx}.root | grep -v "No such file or directory"`;
		    if($exists eq ""){
			print "No root file \n ${job}\n";
			$failed = 1; 
		    }
		}else{
		    if(!(-e "${SUBMITDIR}/${samp}/outputLabel_${idx}.root")){
			print "No root file \n ${job}\n";
			$failed = 1; 
		    }
		}
	    }
	    
	    ###Resubmit
	    if($failed == 1){
		$failcounter++;		
		if($qu ne ""){
		    ##if queue is provided then resubmit
		    submit("${SUBMITDIR}/${samp}",$idx,$qu);
		    print "Job $idx resubmitted.\n";
		}
	    }
	    
	    $idx++;
	}
	print "Failed $failcounter / $idx : ${samp} \n";
    }
}


