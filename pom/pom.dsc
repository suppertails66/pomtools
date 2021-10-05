
//============================================================
// Community Pom translation disc build script
//============================================================

IsoPrimaryVolumeDescriptor pDesc
pDesc.systemIdentifier            = "PLAYSTATION"
pDesc.volumeIdentifier            = "SLPS_00817"
pDesc.volumeSetIdentifier         = ""
pDesc.publisherIdentifier         = "FILL_IN_CAFE_CO.,LTD."
pDesc.dataPreparerIdentifier      = "FILL_IN_CAFE_CO.,LTD."
pDesc.applicationIdentifier       = "PLAYSTATION"
pDesc.copyrightFileIdentifier     = ""
pDesc.abstractFileIdentifier      = ""
pDesc.bibliographicFileIdentifier = ""
pDesc.volumeCreationTime          = "1997093006100000\0"
pDesc.volumeModificationTime      = "0000000000000000\0"
pDesc.volumeExpirationTime        = "0000000000000000\0"
pDesc.volumeEffectiveTime         = "0000000000000000\0"

IsoDescriptorSetTerminator descTerminator

IsoFilesystem isoFs
isoFs.setFormat("CDXA")
//isoFs.setSystemArea("base/sysarea.bin")
isoFs.setRawSectorSystemArea("disc/base/sysarea_raw.bin")
isoFs.importDirectoryListing("out/files")

// FIXME: the listed sizes for these pointers in the original game
// do not match the actual sizes, with no obvious pattern to the variation
isoFs.insertDiscPointer("CD/POM01.SND", ":track2start", ":track2end")
isoFs.getListedFile("CD/POM01.SND").xa_flags_isCdda = 1
isoFs.insertDiscPointer("CD/POM02.SND", ":track3start", ":track3end")
isoFs.getListedFile("CD/POM02.SND").xa_flags_isCdda = 1
isoFs.insertDiscPointer("CD/POM03.SND", ":track4start", ":track4end")
isoFs.getListedFile("CD/POM03.SND").xa_flags_isCdda = 1
isoFs.insertDiscPointer("CD/DUMMY.DA", ":track5start", ":track5end")
isoFs.getListedFile("CD/DUMMY.DA").xa_flags_isCdda = 1

isoFs.importRawSectorFile("disc/rawfiles/POM_BGM.",
                          "CD/POM_BGM.")
isoFs.getListedFile("CD/POM_BGM.").setXaSubmodeType("AUDIO")
isoFs.getListedFile("CD/POM_BGM.").xa_flags_isInterleaved = 1
isoFs.getListedFile("CD/POM_BGM.").xa_fileNumber = 1

isoFs.importRawSectorFile("disc/rawfiles/POM_SEXA.",
                          "CD/POM_SEXA.")
isoFs.getListedFile("CD/POM_SEXA.").setXaSubmodeType("AUDIO")
isoFs.getListedFile("CD/POM_SEXA.").xa_flags_isInterleaved = 1
isoFs.getListedFile("CD/POM_SEXA.").xa_fileNumber = 1

isoFs.importRawSectorFile("disc/rawfiles/POMVOICE.",
                          "CD/POMVOICE.")
isoFs.getListedFile("CD/POMVOICE.").setXaSubmodeType("AUDIO")
isoFs.getListedFile("CD/POMVOICE.").xa_flags_isInterleaved = 1
isoFs.getListedFile("CD/POMVOICE.").xa_fileNumber = 1

//isoFs.importRawSectorFile("discfiles_raw/OPENING.STR",
//                          "OPENING.STR")
//isoFs.getListedFile("OPENING.STR").setXaSubmodeType("DATA")
//isoFs.getListedFile("OPENING.STR").xa_flags_isInterleaved = 1
//isoFs.getListedFile("OPENING.STR").xa_fileNumber = 1

isoFs.getListedFile("").xa_flags_isMode2 = 1
isoFs.getListedFile("SLPS_008.17").xa_flags_isMode2 = 1
isoFs.getListedFile("MAIN.EXE").xa_flags_isMode2 = 1
isoFs.getListedFile("POM_END.EXE").xa_flags_isMode2 = 1
isoFs.getListedFile("SIMDIR.DAT").xa_flags_isMode2 = 1
isoFs.getListedFile("SYSTEM.CNF").xa_flags_isMode2 = 1
isoFs.getListedFile("GRAPHIC").xa_flags_isMode2 = 1
isoFs.getListedFile("GRAPHIC/MAP.PAK").xa_flags_isMode2 = 1
isoFs.getListedFile("GRAPHIC/STD0.PAK").xa_flags_isMode2 = 1
isoFs.getListedFile("GRAPHIC/STD1.PAK").xa_flags_isMode2 = 1
isoFs.getListedFile("GRAPHIC/STD2.PAK").xa_flags_isMode2 = 1
isoFs.getListedFile("GRAPHIC/OP0.PAK").xa_flags_isMode2 = 1
isoFs.getListedFile("GRAPHIC/OP1.PAK").xa_flags_isMode2 = 1
isoFs.getListedFile("GRAPHIC/OP2.PAK").xa_flags_isMode2 = 1
isoFs.getListedFile("GRAPHIC/NOWLOAD.TIM").xa_flags_isMode2 = 1
isoFs.getListedFile("PICT").xa_flags_isMode2 = 1
isoFs.getListedFile("PICT/POM_END.PCK").xa_flags_isMode2 = 1
isoFs.getListedFile("SOUND").xa_flags_isMode2 = 1
isoFs.getListedFile("SOUND/SE.VH").xa_flags_isMode2 = 1
isoFs.getListedFile("SOUND/SE.VB").xa_flags_isMode2 = 1
isoFs.getListedFile("CD").xa_flags_isMode2 = 1
//isoFs.getListedFile("CD/POMVOICE.").xa_flags_isMode2 = 1
//isoFs.getListedFile("CD/POM_SEXA.").xa_flags_isMode2 = 1
//isoFs.getListedFile("CD/POM_BGM.").xa_flags_isMode2 = 1

isoFs.addPrimaryVolumeDescriptor(pDesc)
isoFs.addDescriptorSetTerminator()
isoFs.addTypeLPathTable()
isoFs.addTypeLPathTableCopy()
isoFs.addTypeMPathTable()
isoFs.addTypeMPathTableCopy()
  isoFs.addDirectoryDescriptor("")
    isoFs.addListedFile("SLPS_008.17")
    isoFs.addListedFile("MAIN.EXE")
    isoFs.addListedFile("POM_END.EXE")
    isoFs.addListedFile("SIMDIR.DAT")
  isoFs.addDirectoryDescriptor("PICT")
  isoFs.addDirectoryDescriptor("SOUND")
  isoFs.addDirectoryDescriptor("CD")
  isoFs.addDirectoryDescriptor("GRAPHIC")
  
  // GRAPHIC
    isoFs.addListedFile("GRAPHIC/MAP.PAK")
    isoFs.addListedFile("GRAPHIC/STD0.PAK")
    isoFs.addListedFile("GRAPHIC/STD1.PAK")
    isoFs.addListedFile("GRAPHIC/STD2.PAK")
    isoFs.addListedFile("GRAPHIC/OP0.PAK")
    isoFs.addListedFile("GRAPHIC/OP1.PAK")
    isoFs.addListedFile("GRAPHIC/OP2.PAK")
    isoFs.addListedFile("GRAPHIC/NOWLOAD.TIM")
  
  // SOUND
    isoFs.addListedFile("SOUND/SE.VH")
    isoFs.addListedFile("SOUND/SE.VB")
  
  // PICT
    isoFs.addListedFile("PICT/POM_END.PCK")
  
  // CD
    isoFs.addListedFile("CD/POMVOICE.")
    isoFs.addListedFile("CD/POM_SEXA.")
    isoFs.addListedFile("CD/POM_BGM.")
//    isoFs.addListedFile("CD/POM01.SND")
//    isoFs.addListedFile("CD/POM02.SND")
//    isoFs.addListedFile("CD/POM03.SND")
//    isoFs.addListedFile("CD/DUMMY.DA")
  
  // and lastly, SYSTEM.CNF
    isoFs.addListedFile("SYSTEM.CNF")

CdImage cd
  cd.addTrackStart(1, "MODE2FORM2")
    cd.addModeChange("MODE2FORM1")
    cd.addTrackIndex(1)
    cd.addIsoFilesystem(isoFs)
    cd.addEmptySectors(150)
  cd.addTrackEnd()
  
  cd.addTrackStart(2, "AUDIO")
    cd.addPregapMsf(0, 2, 0)
    cd.addLabel(":track2start")
      cd.addRawData("disc/cdda/pom_02.bin")
//      cd.addRawDataWithSkippedInitialSectors("disc/cdda/pom_02.bin", 150)
    cd.addLabel(":track2end")
  cd.addTrackEnd()
  
  // 18BBC0
  cd.addTrackStart(3, "AUDIO")
    cd.addPregapMsf(0, 2, 0)
    cd.addLabel(":track3start")
      cd.addRawData("disc/cdda/pom_03.bin")
//      cd.addRawDataWithSkippedInitialSectors("disc/cdda/pom_03.bin", 150)
    cd.addLabel(":track3end")
  cd.addTrackEnd()
    
  cd.addTrackStart(4, "AUDIO")
    cd.addPregapMsf(0, 2, 0)
    cd.addLabel(":track4start")
      cd.addRawData("disc/cdda/pom_04.bin")
//      cd.addRawDataWithSkippedInitialSectors("disc/cdda/pom_04.bin", 150)
    cd.addLabel(":track4end")
  cd.addTrackEnd()
    
  cd.addTrackStart(5, "AUDIO")
    cd.addPregapMsf(0, 2, 0)
    cd.addLabel(":track5start")
      cd.addRawData("disc/cdda/pom_05.bin")
//      cd.addRawDataWithSkippedInitialSectors("disc/cdda/pom_05.bin", 150)
    cd.addLabel(":track5end")
  cd.addTrackEnd()

// for posterity, the 1997 version of the game doesn't contain EDCs,
// while the 1999 version does.
// the translation is based on the 1997 version, but we use EDCs anyway.
//cd.disableEdcCalculation = 1

// DEBUG
//cd.disableEccCalculation = 1

cd.exportBinCue("pom_build")
