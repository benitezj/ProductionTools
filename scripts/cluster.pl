#!/usr/bin/perl
# -w
use File::Basename;
$eos="/afs/cern.ch/project/eos/installation/0.3.15/bin/eos.select";

$samplesfile=shift;#must be a full path in AFS
$option=shift;

###check submitting from an /nfs path otherwise jobs wont run
$pwd = getenv("PWD");
if( `echo $pwd | grep /nfs` eq ""){
    print "current path is not in /nfs.\n";
    exit;
}


##Determine path where log files will be written
$samplesfile = `readlink -e $samplesfile`;
chomp($samplesfile);
$SUBMITDIR = dirname($samplesfile);
###check SUBMITDIR is in /nfs otherwis jobs will fail because cannot write logs
if( `echo ${SUBMITDIR} | grep /nfs/` eq ""){
    print "SUBMITDIR is not in /nfs.\n";
    exit;
}


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
$outstorage="";;
if( `echo $OUTPUTDIR | grep eos` ne ""){
$outstorage="eos";
}

print "SUBMITDIR = $SUBMITDIR\n";
print "INPUTDIR = $INPUTDIR\n";
print "OUTPUTDIR = $OUTPUTDIR\n";
#print "instorage = $instorage\n";
#print "outstorage = $outstorage\n";

##read the samples list
@samples=`cat $samplesfile | grep "." | grep -v "#" | grep -v '/' `;
$counter = 0;
foreach $samp (@samples){
	chomp($samp);
	$samp =~ s/^\s+|\s+$//g; ##remove beg/end spaces
	print "$option $samp\n";
	$samples[$counter] = $samp;
	$counter++;
}



####Sort by run number 
if($option eq "sort"){
    print "-------------------------\n";
    print "Sorting samples\n";
    print "-------------------------\n";
    $lastrun=0;
    $counter=0;
    foreach $samp (@samples){
	$counter++;
	$samplename="";
	$smallestRun=9999999;
	foreach $samp (@samples){
	    @word=split(/\./,$samp);
	    $run=1*$word[1];
	    if($run>$lastrun
	       && $run<$smallestRun 
		){
		$smallestRun=$run;
		$samplename=$samp;
	    }
	}
	print "$samplename\n";
	$lastrun=$smallestRun;
    }
}



####Clean out the output directory
if($option eq "clean"){
    print "-------------------------\n";
    print "Removing all files inside output directory:\n";
    print "-------------------------\n";
    foreach $samp (@samples){
	if($outstorage eq  "eos"){
	    @files=`$eos ls $OUTPUTDIR/$samp`; 
	    foreach $file (@files){
		chomp($file);
		$command="$eos rm $OUTPUTDIR/$samp/$file";
		print "$command\n";
		system($command);
	    }
	    $command="$eos rmdir $OUTPUTDIR/$samp";
	    print "$command\n";
	    system($command);
	}else {
	    $command="rm -rf $OUTPUTDIR/$samp";
	    print "$command \n";
	    system($command);
	}
    }


    ####clean out the submission directory
    print "-------------------------\n";
    print "Removing all files in submit directory:\n";
    print "-------------------------\n";
    foreach $samp (@samples){
	$command="rm -rf ${SUBMITDIR}/${samp}";
	print "$command \n";
	system($command);
    }
}


#########Condor submission script
sub makeCondorSub {
    $SUBMITDIR=$_[0];
    $sample=$_[1];
    $idx=$_[2];
    
    $outfile="${SUBMITDIR}/${sample}/tuple_${idx}.sub";
    `rm -f $outfile`;
    `touch $outfile`;

    `echo "Universe   = vanilla" >> $outfile`; 
    `echo "Executable = /bin/bash" >> $outfile`; 
    `echo "Arguments  = ${SUBMITDIR}/${sample}/tuple_${idx}.sh" >> $outfile`; 
    `echo "Log        = ${SUBMITDIR}/${sample}/tuple_${idx}.condor.log" >> $outfile`; 
    `echo "Output     = ${SUBMITDIR}/${sample}/tuple_${idx}.log" >> $outfile`; 
    `echo "Error      = ${SUBMITDIR}/${sample}/tuple_${idx}.condor.log" >> $outfile`; 
    `echo "Queue  " >> $outfile`; 
}

#########Write config parameters for job
sub writeJobConfig {
    $outfile = $_[0];
    $sample = $_[1];
    $idx = $_[2];
    $cpout = $_[3];
    $OUTPUTDIR = $_[4];
    $algo = $_[5];

    if( $algo eq "CxAOD" ){
	`echo "export XAODCONFIG=data/VHbbResonance/framework-run.cfg" >> $outfile`;
	`echo "export XAODNFILES=1" >> $outfile`;
	`echo "export XAODMAXEVENTS=-1" >> $outfile`;
	`echo "export XAODSAMPLEPATH=./in" >> $outfile`;
	`echo "export XAODSAMPLENAME=${sample}" >> $outfile`;
	`echo "export XAODOUTPATH=." >> $outfile`;
	`echo "cxaodmaker local " >> $outfile`;
	`echo "${cpout}  ./${sample}/data-outputLabel/outputLabel.root ${OUTPUTDIR}/${sample}/outputLabel_${idx}.root " >> $outfile`;
	`echo "echo '+++++++++++++Output File+++++++++++:'; /bin/ls -l ${OUTPUTDIR}/${sample}/outputLabel_${idx}.root " >> $outfile`;
    }elsif( $algo eq "CxAODDB" ){
        `echo "DBFramework --preSel --sample_in ./in/${sample}" >> $outfile`;
	`echo "${cpout} submitDir/data-CxAOD/CxAOD.root ${OUTPUTDIR}/${sample}/CxAOD_${idx}.root " >> $outfile`;	
	`echo "echo '+++++++++++++Output File+++++++++++:'; /bin/ls -l ${OUTPUTDIR}/${sample}/CxAOD_${idx}.root" >> $outfile`;	
    }else{
	`echo "export TUPLENFILES=-1 " >> $outfile`;
	`echo "export TUPLECONFIG=data/TupleMaker_VHbbResonance/TupleMaker-job.cfg " >> $outfile`;
	`echo "export TUPLECHANNEL=${algo} " >> $outfile`;
	`echo "export TUPLEINPATH=./in " >> $outfile`;
	`echo "export TUPLESAMPLENAME=${sample} " >> $outfile`;
	`echo "export TUPLEOUTPATH=. " >> $outfile`;
	`echo "tuplemaker local " >> $outfile`;
	`echo "${cpout} ./${sample}/data-output/tuple.root ${OUTPUTDIR}/${sample}/tuple_${idx}.root  " >> $outfile`;
	`echo "echo '+++++++++++++Output File+++++++++++:'; /bin/ls -l ${OUTPUTDIR}/${sample}/tuple_${idx}.root " >> $outfile`;
    }
}


#######FUNCTION FOR MAKING JOB EXECUTION SCRIPTS
sub makeClusterJob {
    $OUTPUTDIR = $_[0];
    #print "OUTPUTDIR $OUTPUTDIR\n";
    $SUBMITDIR = $_[1];
    #print "SUBMITDIR $SUBMITDIR\n";
    $sample = $_[2];
    #print "sample $sample\n";
    $idx = $_[3];
    #print "idx $idx\n";
    $cpin = $_[4];
    #print "cpin $cpin\n";
    $cpout = $_[5];
    #print "cpout $cpout\n";
    $filelist = $_[6];
    #print "filelist $filelist\n";
    $algo = $_[7];
    #print "algo $algo\n";


    $outfile="${SUBMITDIR}/${sample}/tuple_${idx}.sh";
    `rm -f $outfile`;
    `touch $outfile`;

    `echo "echo '+++++++++++++User+++++++++++:'; whoami; " >> $outfile`;

    #machine where the job executes
    `echo "echo '+++++++++++++Machine+++++++++++:'; echo \\\$HOSTNAME  " >> $outfile`;
    `echo "echo '+++++++++++++Tokens+++++++++++:'; tokens  " >> $outfile`;
    `echo "echo '+++++++++++++Initial Dir+++++++++++:'; pwd; /bin/ls -l  " >> $outfile`;

    #setup environment
    `echo "export HOME=/nfs/home/condor " >> $outfile`;
    `echo "source \\\$HOME/.bash_profile  " >> $outfile`;    
    `echo "echo '+++++++++++++ATLAS Setup+++++++++++:' " >> $outfile`;
    `echo "export ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase  " >> $outfile`;
    `echo "source \\\$ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh  " >> $outfile`;
    `echo "source \$PWD/rcSetup.sh  " >> $outfile`;
    `echo "echo '+++++++++++++PATH+++++++++++++:'; echo \\\$PATH  " >> $outfile`;

    #go the execute directory
    `echo "echo '+++++++++++++Executing+++++++++++:'" >> $outfile`;
    `echo "cd \\\$TMPDIR"  >> $outfile`;

    #copy the files locally
    `echo "echo '+++++++++++++Downloading files+++++++++++:'; " >> $outfile`;
    `echo "mkdir -p ./in/${sample} " >> $outfile`;
    `echo "${cpin} ${filelist} ./in/${sample}/" >> $outfile`;
    `echo "echo '+++++++++++++Download Dir+++++++++++:'; /bin/ls -l ./in/${sample}  " >> $outfile`;

    #run program
    `echo "echo '+++++++++++++Enviroment+++++++:'; printenv" >> $outfile`;    
    writeJobConfig($outfile,$sample,$idx,$cpout,$OUTPUTDIR,$algo);
    `echo "echo '+++++++++++++Execute Dir+++++++++++:'; pwd; /bin/ls -l " >> $outfile`;

    #clean (should not be needed)
    #`echo "rm -rf ./${sample}_ " >> $outfile`;
    #`echo "rm -rf ./${sample} " >> $outfile`;

    makeCondorSub($SUBMITDIR,$sample,$idx);
}

######Make the execution scripts
if($option eq "create"){
    #Number of files to merge
    $nmerge=shift;
    print "Number of files to merge per job: $nmerge \n";
    #Algorithm to run
    $algo=shift;
    print "Algorithm to run: $algo \n";
    if( $algo eq "" ){
	print "Wrong algorithm.\n";
	exit(0);
    }

    #Determine how to read the input
    if($instorage eq  "eos"){
	$cpin="$eos cp";
    }else {
	$cpin="/bin/cp";
    }

    #determine how to write the output
    if($outstorage eq  "eos"){
	$cpout="$eos cp";
    }else{
	$cpout="/bin/cp";
    }
    

    foreach $samp (@samples){
	#create the submission directory
	`mkdir $SUBMITDIR/$samp`;

	#create the output directory
	if($outstorage eq  "eos"){
	    $command="$eos mkdir $OUTPUTDIR/$samp";
	    print "$command\n";
	    system($command);
	}else{
	    if($SUBMITDIR ne $OUTPUTDIR){
		$command="mkdir $OUTPUTDIR/$samp";
		print "$command\n";
		system($command);
	    }
	}

	#get list of files in storage
	if($instorage eq  "eos"){
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
	    #print "$mergecounter $filelist\n";
	    
	    if( $mergecounter == $nmerge ){
 		makeClusterJob($OUTPUTDIR,$SUBMITDIR,$samp,$idx,$cpin,$cpout,$filelist,$algo);
		$filelist="";
		$mergecounter=0;
		$idx++;
	    }
	}
	if($mergecounter>0){
	    makeClusterJob($OUTPUTDIR,$SUBMITDIR,$samp,$idx,$cpin,$cpout,$filelist,$algo);
	    $idx++;
	}

	print "\n $idx : ${samp}\n";
    }
}

####define batch submit function
sub submit {
    $path = $_[0];
    $idx= $_[1];
    system("rm -f ${path}/tuple_${idx}.root");
    system("rm -f ${path}/tuple_${idx}.log");
    $command="condor_submit ${path}/tuple_${idx}.sub";  
    print "$command\n";
    system("$command");
}

#submit all jobs
if($option eq "sub" ){
    foreach $samp (@samples){
	$idx=0;	
	for $f (`/bin/ls $SUBMITDIR/$samp | grep tuple_ | grep .sh`){
	    chomp($f);
	    submit("$SUBMITDIR/$samp",$idx);
	    $idx++;
	    #sleep(1);
	}
	print "\n Submitted $idx jobs for ${samp}\n";
    }
}

####Check the job output
if($option eq "check"){
    $resub=shift;

    $sampidx=0;
    foreach $samp (@samples){
	chomp($samp);
	$samp =~ s/^\s+|\s+$//g; ##remove beg/end spaces

	$idx=0;	
	$failcounter=0;
	for $f (`/bin/ls $SUBMITDIR/$samp | grep tuple_ | grep .sh | grep -v "~" `){
	    chomp($f);
	    $job="${SUBMITDIR}/${samp}/tuple_${idx}";

	    $failed=0;

 	    #check the root file was produced
 	    if($failed == 0){
		$rootfile=`/bin/ls ${OUTPUTDIR}/${samp} |  grep _${idx}.root`;
		chomp($rootfile);
		if($rootfile eq ""){
		    print "No root file \n ${job}\n";
		    $failed = 1; 
		}
 	    }

	    #check a log file was produced
	    if($failed == 0 && !(-e "${job}.condor.log")){ 
		print "No log file \n ${job}\n"; 
		$failed = 1; 
	    }

 	    # there were input events: inputCounter = 100000
 	    if( $failed == 0){ 
		
		$failedTuple=0;
		$inputEvents=`tail -n 150  ${job}.condor.log | grep inputCounter`;
		if($inputEvents eq "") {
		    $inputEvents=`tail -n 150  ${job}.log | grep inputCounter`;
		}
 		chomp($inputEvents);
 		@evtsproc=split(" ",$inputEvents);
 		if( !($evtsproc[2] > 0)){
 		    $failedTuple = 1;
 		}
 
		##in case of CxAOD job:
		$failedCxAOD = 0;
		#do not use cat as some log files have binary format at the beggining 
		#$inputEvents=`tail -n 100  ${job}.log | grep 'Info in' | grep processed`;
		#$inputEvents=`tail -n 150  ${job}.condor.log | grep finalize | grep processed`;
                ##AnalysisBase_DB::final... INFO      processed                 = 30781	
		#$inputEvents=`tail -n 150  ${job}.log | grep "INFO      processed                 ="`;	
		$inputEvents=`cat ${job}.log | grep "INFO      processed                 ="`;	
		chomp($inputEvents);
		@evtsproc=split("=",$inputEvents);
		if( !($evtsproc[1] > 0) ){
		    $failedCxAOD = 1;
		}

		#####if neither passed
		$failed = $failedTuple && $failedCxAOD;
		if($failed){
		    print "No input events \n ${job}\n"; 
 		}

 	    }
	
	    
	    ###Resubmit
	    if($failed == 1){
		$failcounter++;	
		if($resub eq "clean"){
		    `/bin/rm ${OUTPUTDIR}/${samp}/*_${idx}.root`;
		}
	
		if($resub eq "sub"){
		    submit("${SUBMITDIR}/${samp}",$idx);
		    print "Job $idx resubmitted.\n";
		}
	    }
	    
	    $idx++;
	}
	##print "Failed $failcounter / $idx : ${samp} \n";
	$Summary[$sampidx++]="Failed $failcounter / $idx : ${samp}";
    }

    $sampidx=0;
    foreach $samp (@samples){
	print "$Summary[$sampidx]\n";
	$sampidx++;
    }
}

############################################
####Count the number of events selected
###########################################
if($option eq "selected"){
    
    $outputfile="$samplesfile_selected.txt";

    `rm -f $outputfile`;
    `touch $outputfile`;

 
    $sampidx=0;
    foreach $samp (@samples){
	chomp($samp);
	$samp =~ s/^\s+|\s+$//g; ##remove beg/end spaces

	$inputEvents=0;
	$outputEvents=0;
	for $f (`/bin/ls $SUBMITDIR/$samp | grep tuple_ | grep .sh | grep -v "~" `){
	    chomp($f);
	    @tuplewords = split(".sh",$f);
	    #print "${tuplewords[0]} ${tuplewords[1]} ${tuplewords[2]}\n";
	    $job="${SUBMITDIR}/${samp}/${tuplewords[0]}";

	    #check a log file was produced
	    if($failed == 0 && !(-e "${job}.condor.log")){ 
		print "No log file: \n ${job}\n"; 
		next;
	    }
	    

	    ##this is for DB framework 
	    #do not use cat as some log files have binary format at the beggining 
	    #Info in <AnalysisBase_DB::finalize()>:   processed                 = 39241
	    #$line=`tail -n 150  ${job}.condor.log | grep AnalysisBase_ | grep "finalize()>:   processed"`;
	    $line=`tail -n 150  ${job}.log | grep "INFO      processed                 ="`;
	    if($line eq ""){
		#this is for the TupleMaker
		$line=`tail -n 150  ${job}.log | grep inputCounter`;
	    }
	    
	    chomp($line);
	    if($line ne ""){
		@evtsproc=split("=",$line);
		$inputEvents += $evtsproc[1];
	    }	    
	    


	    ###Info in <AnalysisBase_DB::finalize()>:   written to output         = 0
	    #$line=`tail -n 150  ${job}.condor.log | grep AnalysisBase_ | grep "written to output"`;
	    ##AnalysisBase_DB::final... INFO      written to output         = 29743
	    $line=`tail -n 150  ${job}.log | grep "INFO      written to output         =" `;
	    if($line eq ""){
		#this is for the TupleMaker
		$line=`tail -n 150  ${job}.log | grep outputCounter`;
	    }
	    
	    chomp($line);
	    if($line ne ""){
		@evtsproc=split("=",$line);
		$outputEvents += $evtsproc[1];
	    }
	    

	}

	
	@samplewords=split(/\./,$samp);
	$run=1;
	if($samplewords[0] eq "user" or $samplewords[0] eq "group"){
	    $run *= $samplewords[3];
	}else{
	    $run *= $samplewords[1];
	}

	$ratio=0.;
	if($inputEvents > 0){
	    $ratio=$outputEvents/$inputEvents;
	}
	$Summary[$sampidx++]=sprintf("%8s %6s %.4f %s",$inputEvents,$outputEvents,$ratio,$samp);

    }

    $sampidx=0;
    foreach $samp (@samples){
	`echo "$Summary[$sampidx]" >> $outputfile`;
	print "$Summary[$sampidx]\n";
	$sampidx++;
    }

}

###############################################
####create file with counters for cutflow
##############################################
if($option eq "cutflow"){
    ##This only works for TupleMaker jobs
    $sampidx=0;
    foreach $samp (@samples){
	chomp($samp);
	$samp =~ s/^\s+|\s+$//g; ##remove beg/end spaces


	#$outputfile="$SUBMITDIR/$samp/cutflow.txt";
	#`rm -f $outputfile`;
	#`touch $outputfile`;
	###NOTE SAMPLE MUST BE PROCESSED IN 1 JOB tuple_0.log
	#$job="$SUBMITDIR/$samp/tuple_0.log";
	#`tail -n 200  ${job} | grep eventCounter_ >>  $outputfile `;


	for $f (`/bin/ls $SUBMITDIR/$samp | grep tuple_ | grep .sh | grep -v "~" `){
	    chomp($f);
	    @tuplewords = split(".sh",$f);
	    $job="${SUBMITDIR}/${samp}/${tuplewords[0]}.log";
	    $outputfile="$SUBMITDIR/$samp/cutflow_${tuplewords[0]}.txt";
	    `rm -f $outputfile`;
	    `tail -n 200  ${job} | grep eventCounter_ >>  $outputfile `;
	}
	
	##sum the files 
	$outputfile="$SUBMITDIR/$samp/cutflow.txt";
	`rm -f $outputfile`;
	`awk '{a[FNR]+=\$3;b[FNR]=\$1;}END{for(i=1;i<=FNR;i++)print b[i]" = "a[i];}' $SUBMITDIR/$samp/cutflow_tuple_*.txt >> $outputfile`;

    }
}




######################################################################
##### Check the jobs running in the cluster
######################################################################
if($option eq "monitor" ){
    use POSIX;
    use POSIX qw(strftime);
    
    $frequency=shift;
    if($frequency==0){
	$frequency=20;
    }
    
    #get the initial number
    #$command="condor_q -global benitezj | grep 'jobs;' | awk -F' ' '{print \$1}'";
    #$commandrun="condor_q -global benitezj | grep 'jobs;' | awk -F' ' '{print \$9}'";
    #$command="condor_q -totals | grep 'jobs;' | awk -F' ' '{print \$1}'";
    #$commandrun="condor_q -totals | grep 'jobs;' | awk -F' ' '{print \$9}'";
    $command="condor_q -totals benitezj | grep 'jobs;' | awk -F' ' '{print \$1}'";
    $commandrun="condor_q -totals benitezj | grep 'jobs;' | awk -F' ' '{print \$9}'";

    
    $njobsinit=`${command}`;
    chomp($njobsinit);

    $njobs=$njobsinit;
    while($njobs>0){
	
	##total number of jobs in queue
	$njobs=`${command}`;
	chomp($njobs);
	$njobs=floor($njobs);
	if($njobs<=0){
	    print "All jobs done\n";
	    last;
	}
	if($njobs>$njobsinit){
	    $njobsinit=$njobs;
	}

	###total number of jobs running
	$njobsrun=`${commandrun}`;
	chomp($njobsrun);
	$njobsrun=floor($njobsrun);


	###display : running jobs with *'s , total jobs with -'s
	$nstar=100*($njobsrun/$njobsinit);
	$nminus=100*($njobs-$njobsrun)/$njobsinit;


	#$now_string = strftime "%a %b %e %H:%M:%S %Y", localtime;
	$now_string = strftime "%H:%M:%S", localtime;
	print "[$now_string] ";

	print " $njobsrun / $njobs :";
	$counterstar=1;
	while($counterstar<=$nstar){
	    print "*";
	    $counterstar++;
	}
	$counterminus=1;
	while($counterminus<$nminus){
	    print "-";
	    $counterminus++;
	}
	print "|\n";
	
	sleep $frequency;
    }
    
    

    $now_string = strftime "%a %b %e %H:%M:%S %Y", localtime;
    print "$now_string\n";
}
