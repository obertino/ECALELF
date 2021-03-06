import FWCore.ParameterSet.Config as cms
from CondCore.DBCommon.CondDBSetup_cfi import *

#### Please fill with comments
# Basic tag for derivation of IC for 2013 Moriond conditions (RUN D)
# Same as Cal_Dic2012, but new LC
# Laser tag has been updated after the discovery of a bug (large
# fraction of the channels has wrong LC due to jumps in the laser
# correction occurred during at magnet switch 
# Alpha tag fixed, no improvement found so far
#
# Start with this for IC validation 
# tag = cms.string('EcalIntercalibConstants_V20120620_piZPhiSEtaScale2012_IOV2_AlphaStudies'),
# this tag is the one present in Prompt2012C   
# this is the reference of any IC derivation and test for
# 2012C and 2012D 

RerecoGlobalTag = cms.ESSource("PoolDBESSource",
                               CondDBSetup,
                               connect = cms.string('frontier://FrontierProd/CMS_COND_31X_GLOBALTAG'),
                               globaltag = cms.string('GR_R_53_V18::All'),
                               toGet = cms.VPSet(
    cms.PSet(record = cms.string("EcalADCToGeVConstantRcd"),
             tag = cms.string('EcalADCToGeVConstant_Bon_RUN2012ABCD_offline'),
             connect = cms.untracked.string("frontier://FrontierProd/CMS_COND_31X_ECAL")
             ),
    cms.PSet(record = cms.string("EcalLaserAPDPNRatiosRcd"),
             tag = cms.string('EcalLaserAPDPNRatios_2012ABCD_offline_20130205'),
             connect = cms.untracked.string("frontier://FrontierProd/CMS_COND_42X_ECAL_LAS")
             ),
    cms.PSet(record = cms.string("EcalIntercalibConstantsRcd"),
             tag = cms.string('EcalIntercalibConstants_2012ABCD_offline'),
             connect = cms.untracked.string("frontier://FrontierProd/CMS_COND_31X_ECAL")
             ),
    cms.PSet(record = cms.string('ESIntercalibConstantsRcd'),
             tag = cms.string('ESIntercalibConstants_V02_offline'),
             connect = cms.untracked.string('frontier://FrontierProd/CMS_COND_31X_PRESHOWER')
             )
    ),
                               BlobStreamerName = cms.untracked.string('TBufferBlobStreamingService')
                               )


