# export XAODCONFIG=data/VHbbResonance/framework-run.cfg
 export XAODCONFIG=data/FrameworkExe_DB/framework-run_VVllJ.cfg
 export XAODNFILES=1
 export XAODMAXEVENTS=1000

 #####Input
 #export XAODSAMPLEPATH=/afs/cern.ch/atlas/project/PAT/xAODs/r6630
 #export XAODSAMPLENAME=mc15_13TeV.410000.PowhegPythiaEvtGen_P2012_ttbar_hdamp172p5_nonallhad.recon.AOD.e3698_s2608_s2183_r6630_tid05352803_00

 #export XAODSAMPLEPATH=/afs/cern.ch/work/b/benitezj/xAODSamples
 #export XAODSAMPLENAME=mc14_13TeV.203917.MadgraphPythia8_AU2MSTW2008LO_HVT_Zh_llbb_1000GeV_126.merge.AOD.e3318_s1982_s2008_r5787_r5853

 #export XAODSAMPLEPATH=/nfs/uiowapc03/data/benitezj/DAODSamples/p1845/
 #export XAODSAMPLENAME=mc14_13TeV.203917.MadgraphPythia8_AU2MSTW2008LO_HVT_Zh_llbb_1000GeV_126.merge.DAOD_HIGG5D2.e3318_s1982_s2008_r5787_r5853_p1845

 #export XAODSAMPLEPATH=/nfs/uiowapc02/data/DAODSamples/HIGG2D4_p2340
 #export XAODSAMPLENAME=mc15_13TeV.361398.Sherpa_CT10_Zmumu_Pt0_70_BFilter.merge.DAOD_HIGG2D4.e3651_s2586_s2174_r6633_r6264_p2340

 #export XAODSAMPLEPATH=/nfs/uiowapc02/data/xAODSamples/mc15
 #export XAODSAMPLENAME=mc15_13TeV.301395.MadGraphPythia8EvtGen_A14NNPDF23LO_HVT_Agv1_VzZH_llqq_m2000.merge.AOD.e3814_s2608_s2183_r6630_r6264

 export XAODSAMPLEPATH=/nfs/uiowapc02/data/DAODSamples/data15_13TeV_p2361
 export XAODSAMPLENAME=data15_13TeV.00266904.physics_Main.merge.DAOD_HIGG2D4.f594_m1435_p2361

 #export XAODSAMPLEPATH=/nfs/uiowapc02/data/xAODSamples/data15
 #export XAODSAMPLENAME=data15_13TeV.00267073.physics_Main.merge.AOD.f594_m1435


 #####OUTPUT
 export XAODOUTPATH=/afs/cern.ch/work/b/benitezj/CxAODSamples/Test

 rm -rf ${XAODOUTPATH}/${XAODSAMPLENAME}
 cxaodmaker local
 rm -f $XAODOUTPATH/$XAODSAMPLENAME/*.root
 mv $XAODOUTPATH/$XAODSAMPLENAME/data-outputLabel/outputLabel.root  $XAODOUTPATH/$XAODSAMPLENAME/outputLabel_0.root
 ls -l $XAODOUTPATH/$XAODSAMPLENAME/outputLabel_0.root
