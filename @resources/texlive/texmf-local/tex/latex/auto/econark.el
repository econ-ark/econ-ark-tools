(TeX-add-style-hook
 "econark"
 (lambda ()
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "url")
   (TeX-run-style-hooks
    "subfiles"
    "amsmath"
    "amsfonts"
    "amsthm"
    "amssymb")
   (TeX-add-symbols
    '("cnstr" 1)
    '("cncl" 1)
    '("iflabelexists" 3)
    '("localorexternallabel" 1)
    "labelprefix"
    "aLvl"
    "bLvl"
    "cLvl"
    "dLvl"
    "eLvl"
    "fLvl"
    "gLvl"
    "hLvl"
    "iLvl"
    "jLvl"
    "kLvl"
    "mLvl"
    "nLvl"
    "pLvl"
    "qLvl"
    "rLvl"
    "sLvl"
    "tLvl"
    "uLvl"
    "vLvl"
    "wLvl"
    "xLvl"
    "yLvl"
    "zLvl"
    "ALvl"
    "BLvl"
    "CLvl"
    "DLvl"
    "ELvl"
    "FLvl"
    "GLvl"
    "HLvl"
    "ILvl"
    "JLvl"
    "KLvl"
    "LLvl"
    "MLvl"
    "NLvl"
    "OLvl"
    "PLvl"
    "QLvl"
    "RLvl"
    "SLvl"
    "TLvl"
    "ULvl"
    "VLvl"
    "WLvl"
    "XLvl"
    "YLvl"
    "ZLvl"
    "aNrm"
    "bNrm"
    "cNrm"
    "dNrm"
    "eNrm"
    "fNrm"
    "hNrm"
    "iNrm"
    "jNrm"
    "kNrm"
    "mNrm"
    "pNrm"
    "sNrm"
    "vNrm"
    "yNrm"
    "zNrm"
    "ANrm"
    "BNrm"
    "CNrm"
    "DNrm"
    "ENrm"
    "FNrm"
    "HNrm"
    "INrm"
    "JNrm"
    "KNrm"
    "MNrm"
    "PNrm"
    "SNrm"
    "VNrm"
    "YNrm"
    "ZNrm"
    "permShkInd"
    "permShk"
    "PermShk"
    "tranShkInd"
    "permShkIndMin"
    "permShkIndMax"
    "prstShkInd"
    "prstShkAgg"
    "prstShk"
    "prstShkIndMin"
    "prstShkIndMax"
    "tranShkMin"
    "tranShkMax"
    "tranShkEmp"
    "TranShkEmp"
    "tranShkEmpMin"
    "tranShkEmpMax"
    "IncUnemp"
    "TranShkAgg"
    "PermShkAgg"
    "std"
    "tranShkIndStd"
    "tranShkIndVar"
    "TranShkAggStd"
    "TranShkAggVar"
    "PermShkAll"
    "PermShkAllStd"
    "PermShkAllVar"
    "PermLvlAgg"
    "permLvlInd"
    "permLvl"
    "PermLvl"
    "PermLvlAll"
    "tranShkAll"
    "TranShkAll"
    "tranShkAllStd"
    "tranShkAllVar"
    "MPCmin"
    "MPCmax"
    "MPCmaxmax"
    "MPCmaxmin"
    "MPCminmin"
    "PermGroFacAgg"
    "permGroFacInd"
    "PermGroFac"
    "PermGroFacRnd"
    "PermGroFacAdj"
    "PermGroFacuAdj"
    "PermGroRte"
    "Alive"
    "diePrb"
    "DiePrb"
    "DeprFac"
    "deprRte"
    "DiscFac"
    "DiscFacAlt"
    "DiscAlt"
    "DiscAltuAdj"
    "DiscFacRaw"
    "DiscFacLiv"
    "DiscRte"
    "discRte"
    "APFac"
    "APFacDefn"
    "APRte"
    "GPFac"
    "GPFacRaw"
    "GPFacMod"
    "RPFac"
    "RPRte"
    "GPRte"
    "EPermShkInv"
    "InvEPermShkInv"
    "uInvEuPermShk"
    "RfreeEff"
    "PopnGroFac"
    "PopnGroRte"
    "PopnLvl"
    "LivPrb"
    "livPrb"
    "pNotZero"
    "CARA"
    "CRRA"
    "MPC"
    "MPCFunc"
    "pZero"
    "rfree"
    "Rfree"
    "RSave"
    "rsave"
    "RBoro"
    "rboro"
    "Risky"
    "risky"
    "riskyELog"
    "riskyELev"
    "riskyshare"
    "riskyvar"
    "Rport"
    "rport"
    "uPPP"
    "uPP"
    "uP"
    "util"
    "Kap"
    "kap"
    "leiShare"
    "MPSmin"
    "MPSmax"
    "PDV"
    "Wage"
    "wage"
    "TaxLev"
    "Tax"
    "TaxFree"
    "Alt"
    "urate"
    "erate"
    "unins"
    "Labor"
    "labor"
    "EEndMap"
    "TMap"
    "CEndFunc"
    "cEndFunc"
    "uFuncInv"
    "muFuncInv"
    "HARKdocs"
    "HARKrepo"
    "Rnorm"
    "rnorm"
    "EpremLog"
    "EPrem"
    "eprem"
    "weight"
    "FDist"
    "fDist"
    "aMin"
    "Nrml"
    "TargetNrm"
    "mTrgNrm"
    "cFuncAbove"
    "cFuncBelow"
    "chiFunc"
    "Chi"
    "PopGroFac"
    "popGroRte"
    "PtyGroFac"
    "PtyGroRte"
    "ptyGroFac"
    "ptyGroRte"
    "Reals"
    "Ex"
    "Mean"
    "cncl"
    "avg"
    "Max"
    "Min"
    "Rnd"
    "Opt"
    "Lvl"
    "nxt"
    "lst"
    "RNrmByG"
    "RNrmByGRnd"
    "aFunc"
    "bFunc"
    "cFunc"
    "dFunc"
    "eFunc"
    "fFunc"
    "gFunc"
    "hFunc"
    "iFunc"
    "jFunc"
    "kFunc"
    "mFunc"
    "nFunc"
    "pFunc"
    "sFunc"
    "rFunc"
    "uFunc"
    "vFunc"
    "wFunc"
    "xFunc"
    "yFunc"
    "zFunc"
    "vFuncLvl"
    "cFuncLvl"
    "AFunc"
    "BFunc"
    "CFunc"
    "DFunc"
    "EFunc"
    "FFunc"
    "GFunc"
    "HFunc"
    "IFunc"
    "JFunc"
    "KFunc"
    "LFunc"
    "MFunc"
    "NFunc"
    "OFunc"
    "PFunc"
    "QFunc"
    "RFunc"
    "SFunc"
    "TFunc"
    "UFunc"
    "VFunc"
    "WFunc"
    "XFunc"
    "YFunc"
    "ZFunc"
    "cov"
    "CDF"
    "ARKurl"
    "REMARK")
   (LaTeX-add-environments
    "assumption"
    "claim"
    "proposition"
    "corollary"
    "fact"
    "remark"))
 :latex)
