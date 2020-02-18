601,100
602,"LRP_AREA_Dataload_Reset_PTRS_Royalty_Percentage"
562,"VIEW"
586,"LRP_AREA_Lookup_Royalty_Risk"
585,"LRP_AREA_Lookup_Royalty_Risk"
564,
565,"cOWa7dKQ5c]VNBX7KMNVOP^29?:V2dEugkX\k<cm0ix`lyftJlj<B@k6mkh^WsjA9yP_A5aqA9RhUp3qXFva1AOeXpqY3K;9x=AcNceYob6HPmoA?t<ZBgGbcJEJLJAh7:J>H6^4kV`go2Zf<T@K[yKZ[xBV@rR7dC9OP6uVV_bDNy:Gn[[M=_PcQuEaRTA]Gw=n70B`"
559,1
928,0
593,
594,
595,
597,
598,
596,
800,
801,
566,0
567,","
588,"."
589,","
568,""""
570,LRP_AREA_Dataload_Reset_PTRS_Royalty_Percentage_20191216220020
571,
569,0
592,0
599,1000
560,4
pProcessID
pTgtMeasure
pTgtVersion
pTgtPercent
561,4
1
2
2
1
590,4
pProcessID,1
pTgtMeasure,"Risk"
pTgtVersion,""
pTgtPercent,1
637,4
pProcessID,"Process loop count within an iteration, default is 1"
pTgtMeasure,"Risk or Royalty"
pTgtVersion,"Target active version"
pTgtPercent,"Ratio between 0 and 1"
577,9
vYear
vProduct
vVersion
vProfitCenter
vMeasure
vValue
NVALUE
SVALUE
VALUE_IS_STRING
578,9
2
2
2
2
2
2
1
2
1
579,9
5
4
3
2
1
6
0
0
0
580,9
0
0
0
0
0
0
0
0
0
581,9
0
0
0
0
0
0
0
0
0
582,6
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
603,0
572,161

#****Begin: Generated Statements***
#****End: Generated Statements****

#********************************************************************************************************************************************************************
# GENERALCOMMENT  This process will reset the risk or royalty percentage to the specified value for the target version.
# GENERALCOMMENT  It performs the following activities:
# GENERALCOMMENT     (1)  It verifies all the arguments
# GENERALCOMMENT     (2)  It also checks that the version is active
# GENERALCOMMENT     (3)  It creates view on target cube to zero out data and to use for data population

# DATASOURCECOMMENT  View on the target cube

# PROLOGCOMMENT  Performs steps 1-3 from above.  Target view includes the following element detail:
# PROLOGCOMMENT     LRP_AREA_Lookup_Royalty_Risk_m: Selected measure
# PROLOGCOMMENT     Profit_Center:  All leaf elements
# PROLOGCOMMENT     Version:  Selected version
# PROLOGCOMMENT     Product:  All leaf elements
# PROLOGCOMMENT     Fiscal_Year:  All leaf elements

# METADATACOMMENT  Not applicable

# DATACOMMENT  Populates the target view with specified value.

# EPILOGCOMMENT  Logs any errors

# CHANGELOG  ASPIRE Release 1.0 VG : Process created
#********************************************************************************************************************************************************************

### Log runtime arguments
LogOutput('INFO', GetProcessName() | ' was executed with pProcessID <' | NumberToString(pProcessID) | '>.');
LogOutput('INFO', GetProcessName() | ' was executed with pTgtMeasure <' | pTgtMeasure | '>.');
LogOutput('INFO', GetProcessName() | ' was executed with pTgtVersion <' | pTgtVersion | '>.');
LogOutput('INFO', GetProcessName() | ' was executed with pProcessID <' | NumberToString(pTgtPercent) | '>.');

### Set process variables
vProcessID = pProcessID;
vTgtMeasure = Trim (pTgtMeasure);
vTgtVersion = Trim (pTgtVersion);
vTgtPercent = pTgtPercent;

vDimVersion = 'Version';
vDimMeasure = 'LRP_AREA_Lookup_Royalty_Risk_m';

vTgtCube = 'LRP_AREA_Lookup_Royalty_Risk';

vProcessCreateSubset = 'ADMN_Common_Create_Subset';
vProcessLogError = 'ADMN_Common_Log_Errors';

vLoadedRecordCount = 0;
vTempFlag = 1;
vReturn = 0;
vError = 0;
vErrMsg = '';
vErrFile = '';
vSuccess = 'Success';
vFailed = 'Failed';

vEndTime = '';
vNow  = Now();
vTimeStampLogging = TimSt(vNow, '\Y-\m-\d \H:\i:\s \p');
vTimeStamp = TimSt(vNow, '\Y\m\d\h\i\s');
vUser = TM1User();
vProcess = GetProcessName ();
vLogDir = GetProcessErrorFileDirectory ();
vStartTime = vTimeStampLogging;
vEndTime = '';
vProcessStatus = vSuccess;

vView = vProcess | '_' | vTimeStamp;
vSubset = vView;

vProcessArgs = 'pProcessID = ' | NumberToString (pProcessID);
vProcessArgs = vProcessArgs | '; pTgtMeasure = ' | pTgtMeasure;
vProcessArgs = vProcessArgs | '; pTgtVersion = ' | pTgtVersion;
vProcessArgs = vProcessArgs | '; pTgtPercent = ' | NumberToString (pTgtPercent);

### Verifying the arguments
If (CubeExists (vTgtCube) = 0);
   vError = 1;
   vErrMsg =  GetProcessName() | ':  Target cube <' | vTgtCube | '> does not exist.  Aborting.';
   vProcessStatus = vFailed;     
   ProcessBreak ();
EndIf;

If (pTgtMeasure @='' % DimIx (vDimMeasure, pTgtMeasure) = 0);
   vError = 1;
   vErrMsg =  GetProcessName() | ':  Invalid measure <' | pTgtMeasure | '>.  Aborting.';
   vProcessStatus = vFailed;     
   ProcessBreak ();
EndIf;

If (pTgtVersion @='' % DimIx (vDimVersion, pTgtVersion) = 0);
   vError = 1;
   vErrMsg =  GetProcessName() | ':  Invalid version <' | pTgtVersion | '>.  Aborting.';
   vProcessStatus = vFailed;     
   ProcessBreak ();
EndIf;

If (ATTRS (vDimVersion, pTgtVersion, 'Active') @<> 'Y');
   vError = 1;
   vErrMsg =  GetProcessName() | ':  Inactive version <' | pTgtVersion | '>.  Aborting.';
   vProcessStatus = vFailed;     
   ProcessBreak ();
EndIf;

### Creating a view on the target cube 
If (ViewExists (vTgtCube, vView) = 1);
  ViewDestroy(vTgtCube, vView);
EndIf;

## Recreating the view
ViewCreate (vTgtCube, vView, vTempFlag);

## Creating subsets and assigning to view
vIndex = 1;
While (TabDim(vTgtCube, vIndex) @<> '');
   vDim = TabDim(vTgtCube, vIndex);

   ## Building the subsets
   If (SubsetExists(vDim, vSubset) = 0);
      SubsetCreate(vDim, vSubset, vTempFlag);
   Else;
      SubsetDeleteAllElements(vDim, vSubset);
   EndIf;

   ## Assigning subsets to views
   ViewSubsetAssign(vTgtCube, vView, vDim, vSubset);
   ViewRowDimensionSet(vTgtCube, vView, vDim, 1);
   
   ## Measure
   If (vDim @= vDimMeasure);
      SubsetElementInsert(vDim, vSubset, vTgtMeasure, 1);
   ## Version
   ElseIf (vDim @= vDimVersion); 
      SubsetElementInsert(vDim, vSubset, vTgtVersion, 1);
   Else;
      ## Getting all leaf level elements
      ExecuteProcess (vProcessCreateSubset,  's_Dim', vDim,  's_Sub', vSubset,  'n_ToLevel', 0);
   EndIf;
   
   ## Increment the index
   vIndex = vIndex +1;

End;

## Source View settings
ViewExtractSkipCalcsSet(vTgtCube, vView, 1);
ViewExtractSkipRuleValuesSet(vTgtCube, vView, 1);
ViewExtractSkipZeroesSet(vTgtCube, vView, 0);

## ZeroOut the data
ViewZeroOut (vTgtCube, vView);

### Setting up the data source
DatasourceType='View';
DatasourceNameforServer=vTgtCube;
DatasourceCubeview=vView;

### Setting the minor error limit
MinorErrorLogMax = -1;
573,3

#****Begin: Generated Statements***
#****End: Generated Statements****
574,11

#****Begin: Generated Statements***
#****End: Generated Statements****

### Loading the specified value to target cube
If (CellIsUpdateable(vTgtCube, vMeasure, vProfitCenter, vVersion, vProduct, vYear) = 1);
   CellPutN(vTgtPercent, vTgtCube, vMeasure, vProfitCenter, vVersion, vProduct, vYear);
   vLoadedRecordCount = vLoadedRecordCount + 1;
EndIf;


575,37

#****Begin: Generated Statements***
#****End: Generated Statements****

### Logging process status
If (vError = 0);
   vErrFile = GetProcessErrorFilename ();

   If (vErrFile @<> '');
      vProcessStatus =  vProcess | ':  Process completed with errors.';
      vErrMsg = vProcess | ':  Process completed with errors.  Please check the logs.';
      LogOutput ('DEBUG', vErrMsg);
   Else;
      LogOutput ('INFO', vProcess | ':  Process completed successfully.');
   EndIf;
EndIf;

### Updating the error logging cube
vEndTime = TimSt(vNow, '\Y-\m-\d \H:\i:\s \p');

ExecuteProcess (vProcessLogError, 
                            'pProcessID', vProcessID, 
                            'pProcessName', vProcess, 
                            'pStartTime', vStartTime, 
                            'pEndTime', vEndTime, 
                            'pProcessStatus', vProcessStatus, 
                            'pErrMsg', vErrMsg, 
                            'pProcessArgs', vProcessArgs,
                            'pLoadedRecordCount', vLoadedRecordCount,
                            'pSkippedRecordCount', 0,
                            'pTotalRecordCount', 0);

### Throwing an error
If (vError = 1);
   LogOutput ('ERROR', vProcess | ':  ' | vErrMsg);
   ProcessQuit ();
EndIf;
576,CubeAction=1511DataAction=1503CubeLogChanges=0_ParameterConstraints=e30
930,0
638,1
804,0
1217,0
900,
901,
902,
938,0
937,
936,
935,
934,
932,0
933,0
903,
906,
929,
907,
908,
904,0
905,0
909,0
911,
912,
913,
914,
915,
916,
917,0
918,1
919,0
920,50000
921,""
922,""
923,0
924,""
925,""
926,""
927,""
