import FWCore.ParameterSet.Config as cms

zNtupleDumper = cms.EDAnalyzer('ZNtupleDumper',
                               jsonFileName = cms.string(""),
                               #ZCandidateCollection = cms.InputTag('zCandidateProducer'),
                               electronCollection = cms.InputTag('patElectrons'),
                               #recHitCollectionEB = cms.InputTag("alCaIsolatedElectrons", "alCaRecHitsEB"),
                               #recHitCollectionEE = cms.InputTag("alCaIsolatedElectrons", "alCaRecHitsEE"),
                               recHitCollectionEB = cms.InputTag("alCaIsolatedElectrons", "alcaBarrelHits"),
                               recHitCollectionEE = cms.InputTag("alCaIsolatedElectrons", "alcaEndcapHits"),
                               rhoFastJet = cms.InputTag('kt6PFJetsForRhoCorrection',"rho"),
                               vertexCollection = cms.InputTag('offlinePrimaryVertices'),
                               BeamSpotCollection = cms.InputTag('offlineBeamSpot'),
                               conversionCollection = cms.InputTag('allConversions'),
                               metCollection = cms.InputTag('pfMet'),
                               triggerResultsCollection = cms.InputTag('TriggerResults::HLT'),
                               foutName = cms.string("ZShervinNtuple.root"),
                               doStandardTree = cms.bool(True),
                               doExtraCalibTree = cms.bool(False),
                               doEleIDTree = cms.bool(False),
                               doPdfSystTree = cms.bool(True),
#                               pdfWeightCollections = cms.VInputTag(cms.InputTag('pdfWeights:cteq66'), cms.InputTag("pdfWeights:MRST2006nnlo"), cms.InputTag('pdfWeights:NNPDF10')),
                               pdfWeightCollections = cms.VInputTag(),
                               isWenu = cms.bool(False),
#                               hltPaths = cms.vstring()
                               hltPaths = cms.vstring('HLT_Ele17_CaloIdT_CaloIsoVL_TrkIdVL_TrkIsoVL_Ele8_CaloIdT_CaloIsoVL_TrkIdVL_TrkIsoVL_v15',
                                                      'HLT_Ele17_CaloIdT_CaloIsoVL_TrkIdVL_TrkIsoVL_Ele8_CaloIdT_CaloIsoVL_TrkIdVL_TrkIsoVL_v16',
                                                      'HLT_Ele17_CaloIdT_CaloIsoVL_TrkIdVL_TrkIsoVL_Ele8_CaloIdT_CaloIsoVL_TrkIdVL_TrkIsoVL_v17',
                                                      'HLT_Ele17_CaloIdT_CaloIsoVL_TrkIdVL_TrkIsoVL_Ele8_CaloIdT_CaloIsoVL_TrkIdVL_TrkIsoVL_v18',
                                                      'HLT_Ele17_CaloIdT_CaloIsoVL_TrkIdVL_TrkIsoVL_Ele8_CaloIdT_CaloIsoVL_TrkIdVL_TrkIsoVL_v19'
                                                      )
                               #isMC = cms.bool(False),
                               
                               #                      jsonFile = cms.string(options.json),
                               #puWeightFile = cms.string('')
                               #                      R9WeightFile = cms.string(options.R9WeightFile),
                                    #                      regrPhoFile = cms.string(regrPhoFile),
                                    #                      regrEleFile = cms.string(regrEleFile),
                                    #                      r9weightsFile = cms.string('./config/R9Weight.root'),
                                    #                      correctionFileName = cms.string(options.correctionFileName),
                                    #                      correctionType = cms.string(options.correctionType),
                                    #                      oddEventFilter = cms.bool(oddEventFilter)
                               )
