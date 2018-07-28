export XAODOUTPATH=/afs/cern.ch/work/b/benitezj/CxAODSamples/Test

#export XAODINPATH=/nfs/uiowapc02/data/DAODSamples/HIGG2D4_p2340
#export XAODSAMPLENAME=mc15_13TeV.361398.Sherpa_CT10_Zmumu_Pt0_70_BFilter.merge.DAOD_HIGG2D4.e3651_s2586_s2174_r6633_r6264_p2340

#export XAODINPATH=/nfs/uiowapc02/data/DAODSamples/HIGG2D4_p2361
#export XAODSAMPLENAME=mc15_13TeV.361107.PowhegPythia8EvtGen_AZNLOCTEQ6L1_Zmumu.merge.DAOD_HIGG2D4.e3601_s2576_s2132_r6630_r6264_p2361

#export XAODINPATH=/nfs/uiowapc02/data/DAODSamples/EXT2_p2361/
#export XAODSAMPLENAME=group.phys-exotics.mc15_13TeV.361398.Sherpa_CT10_Zmumu_Pt0_70_BFilter.r6633_r6264.p2361_EXT2

#export XAODINPATH=/nfs/uiowapc02/data/DAODSamples/data15_13TeV_p2361
#export XAODSAMPLENAME=data15_13TeV.00267073.physics_Main.merge.DAOD_HIGG2D4.f594_m1435_p2361
#export XAODSAMPLENAME=data15_13TeV.00267599.physics_Main.merge.DAOD_HIGG2D4.f597_m1441_p2361
#export XAODSAMPLENAME=data15_13TeV.00267638.physics_Main.merge.DAOD_HIGG2D4.r6848_p2358_p2361

#export XAODINPATH=/nfs/uiowapc02/data/DAODSamples/EXOT12_p2375
#export XAODSAMPLENAME=mc15_13TeV.302401.MadGraphPythia8EvtGen_A14NNPDF23LO_HVT_Agv1_VzZH_llqq_m1500.merge.DAOD_EXOT12.e4069_s2608_r6765_r6282_p2375
#export XAODSAMPLENAME=data15_13TeV.00267638.physics_Main.merge.DAOD_EXOT12.r6848_p2358_p2375

###Error in <ObjectHandler::setObjects()>: Failed to retrieve particle container 'AntiKt2PV0TrackJets'
#export XAODINPATH=/nfs/uiowapc02/data/DAODSamples/EXOT12_p2361/
#export XAODSAMPLENAME=mc15_13TeV.301395.MadGraphPythia8EvtGen_A14NNPDF23LO_HVT_Agv1_VzZH_llqq_m2000.merge.DAOD_EXOT12.e3814_s2608_s2183_r6630_r6264_p2361

#export XAODINPATH=/nfs/uiowapc02/data/DAODSamples/EXOT12_p2375
#export XAODSAMPLENAME=mc15_13TeV.301395.MadGraphPythia8EvtGen_A14NNPDF23LO_HVT_Agv1_VzZH_llqq_m2000.merge.DAOD_EXOT12.e3814_s2608_s2183_r6630_r6264_p2375

#export XAODINPATH=/nfs/uiowapc02/data/DAODSamples/EXOT12_p2411
#export XAODSAMPLENAME=data15_13TeV.00267638.physics_Main.merge.DAOD_EXOT12.r6943_p2410_p2411
#export XAODSAMPLENAME=data15_13TeV.00277089.physics_Main.merge.DAOD_EXOT12.f622_m1486_p2411

#export XAODINPATH=/nfs/uiowapc/data/DAODSamples/EXOT12_p2406
#export XAODSAMPLENAME=mc15_13TeV.302391.MadGraphPythia8EvtGen_A14NNPDF23LO_HVT_Agv1_VzZH_llqq_m0500.merge.DAOD_EXOT12.e4069_s2608_r6765_r6282_p2406

export XAODINPATH=/nfs/uiowapc/data/DAODSamples/EXOT12_p2419
export XAODSAMPLENAME=mc15_13TeV.302401.MadGraphPythia8EvtGen_A14NNPDF23LO_HVT_Agv1_VzZH_llqq_m1500.merge.DAOD_EXOT12.e4069_s2608_r6765_r6282_p2419
#export XAODSAMPLENAME=mc15_13TeV.341736.MadGraphPythia8EvtGen_A14NNPDF23LO_ggA1000_Zh125_llbb.merge.DAOD_HIGG2D4.e4137_s2608_s2183_r6869_r6282_p2419
#export XAODINPATH=/nfs/uiowapc/data/DAODSamples/EXOT12_p2425
#export XAODSAMPLENAME=data15_13TeV.00280319.physics_Main.merge.DAOD_EXOT12.f629_m1504_p2425

#export XAODINPATH=/nfs/uiowapc/data/DAODSamples/EXOT12_debug
#export XAODSAMPLENAME=data15_13TeV.periodD.debugrec_hlt.PhysCont.DAOD_EXOT12.grp15_v01

#export XAODINPATH=/nfs/uiowapc/data/DAODSamples/HIGG2D4_debug
#export XAODSAMPLENAME=data15_13TeV.00278748.debugrec_hlt.merge.DAOD_HIGG2D4.g49_f628_m1497_p2427


#export XAODINPATH=/nfs/uiowapc/data/DAODSamples/EXOT12_p2436
#export XAODSAMPLENAME=mc15_13TeV.410000.PowhegPythiaEvtGen_P2012_ttbar_hdamp172p5_nonallhad.merge.DAOD_EXOT12.e3698_s2608_s2183_r7267_r6282_p2436


rm -rf submitDir

#DBFramework --preSel --maxEvents 500 --sample_in $XAODINPATH/$XAODSAMPLENAME
DBFramework --preSel --sample_in $XAODINPATH/$XAODSAMPLENAME

rm -rf $XAODOUTPATH/$XAODSAMPLENAME
mkdir $XAODOUTPATH/$XAODSAMPLENAME

mv submitDir/data-CxAOD/CxAOD.root  $XAODOUTPATH/$XAODSAMPLENAME/CxAOD_0.root

ls -l $XAODOUTPATH/$XAODSAMPLENAME/CxAOD_0.root
