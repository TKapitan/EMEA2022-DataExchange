codeunit 99004 "TST Generic Export Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure TestGetAvailableSourceTableNosForDataExchangeDefinitionWithoutIntermediate()
    var
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchMapping: Record "Data Exch. Mapping";
        EMEADataExchangeUsage: Record "EMEA Data Exchange Usage";
        EMEAGenericExportImport: Record "EMEA Generic Export/Import";
        AvailableTableNos: List of [Integer];
    begin
        // [GIVEN] Data Exchange Definition fully set up exists with more line defintions + mappings
        LibraryExpDataExch.CreateDataExchFullSetup(DataExchDef);
        LibraryExpDataExch.CreateDataExchLineDef(DataExchLineDef, DataExchDef);
        LibraryExpDataExch.CreateDataExchMapping(DataExchMapping, DataExchLineDef, Database::Item);
        LibraryExpDataExch.CreateDataExchLineDef(DataExchLineDef, DataExchDef);
        LibraryExpDataExch.CreateDataExchMapping(DataExchMapping, DataExchLineDef, Database::Vendor);
        LibraryExpDataExch.CreateDataExchUsage(EMEADataExchangeUsage, DataExchDef.Code);
        LibraryExpDataExch.CreateGenericExportSetup(EMEAGenericExportImport, EMEADataExchangeUsage.Code);

        // [WHEN] Both have the same usage
        AvailableTableNos := EMEAGenericExportImport.GetAvailableSourceTableNos();

        LibraryAssert.AreEqual(3, AvailableTableNos.Count(), 'AvailableTableNos.Count()');
        LibraryAssert.IsTrue(AvailableTableNos.Contains(Database::Customer), 'AvailableTableNos.Contains(Database::Customer)');
        LibraryAssert.IsTrue(AvailableTableNos.Contains(Database::Item), 'AvailableTableNos.Contains(Database::Item)');
        LibraryAssert.IsTrue(AvailableTableNos.Contains(Database::Vendor), 'AvailableTableNos.Contains(Database::Vendor)');
    end;

    [Test]
    procedure TestGetUsedDataExchangeDefinitionCodeWithUnspecifiedVersion()
    var
        DataExchDef: Record "Data Exch. Def";
        DataExchDef2: Record "Data Exch. Def";
        EMEAGenericExportImport: Record "EMEA Generic Export/Import";
        DataExchangeUsageCode: Code[20];
    begin
        // [GIVEN] Two data exchange definitions exist 
        LibraryExpDataExch.CreateDataExchFullSetup(DataExchDef);
        LibraryExpDataExch.CreateDataExchFullSetup(DataExchDef2);

        // [WHEN] Both have the same usage
        DataExchangeUsageCode := LibraryRandom.RandText();
        LibraryExpDataExch.CreateDataExchUsage(DataExchangeUsageCode, DataExchDef.Code);
        LibraryExpDataExch.CreateDataExchUsage(DataExchangeUsageCode, DataExchDef2.Code);
        LibraryExpDataExch.CreateGenericExportSetup(EMEAGenericExportImport, DataExchangeUsageCode);

        // [THEN] Then Expected Output
        LibraryAssert.AreEqual(DataExchDef2.Code, EMEAGenericExportImport.GetUsedDataExchangeDefinitionCode(), 'EMEAGenericExportImport.GetUsedDataExchangeDefinitionCode()');
    end;

    [Test]
    procedure TestGetUsedDataExchangeDefinitionCodeWithSpecificVersion()
    var
        DataExchDef: Record "Data Exch. Def";
        DataExchDef2: Record "Data Exch. Def";
        EMEAGenericExportImport: Record "EMEA Generic Export/Import";
        DataExchangeUsageCode: Code[20];
    begin
        // [GIVEN] Two data exchange definitions exist 
        LibraryExpDataExch.CreateDataExchFullSetup(DataExchDef);
        LibraryExpDataExch.CreateDataExchFullSetup(DataExchDef2);

        // [WHEN] Both have the same usage
        DataExchangeUsageCode := LibraryRandom.RandText();
        LibraryExpDataExch.CreateDataExchUsage(DataExchangeUsageCode, DataExchDef.Code);
        LibraryExpDataExch.CreateDataExchUsage(DataExchangeUsageCode, DataExchDef2.Code);
        LibraryExpDataExch.CreateGenericExportSetup(EMEAGenericExportImport, DataExchangeUsageCode);
        EMEAGenericExportImport.Validate("Used Version No.", 1);
        EMEAGenericExportImport.Modify();

        // [THEN] Then Expected Output
        LibraryAssert.AreEqual(DataExchDef.Code, EMEAGenericExportImport.GetUsedDataExchangeDefinitionCode(), 'EMEAGenericExportImport.GetUsedDataExchangeDefinitionCode()');
    end;

    [Test]
    [HandlerFunctions('ExportSuccessfulMessageHandler')]
    procedure TestGenericExportSuccessful()
    var
        DataExchDef: Record "Data Exch. Def";
        EMEADataExchangeUsage: Record "EMEA Data Exchange Usage";
        EMEAGenericExportImport: Record "EMEA Generic Export/Import";
    begin
        // [GIVEN] Fully set data exchange definition, usage & generic export exist 
        LibraryExpDataExch.CreateDataExchFullSetup(DataExchDef);
        LibraryExpDataExch.CreateDataExchUsage(EMEADataExchangeUsage, DataExchDef.Code);
        LibraryExpDataExch.CreateGenericExportSetup(EMEAGenericExportImport, EMEADataExchangeUsage.Code);
        LibraryExpDataExch.SetOurTxtExportObjects(DataExchDef);

        // [WHEN] Export is run
        EMEAGenericExportImport.RunExport();

        // [THEN] Message shown
    end;

    [MessageHandler]
    procedure ExportSuccessfulMessageHandler(MessageText: Text[1024])
    begin
        LibraryAssert.ExpectedMessage('Export successful.', MessageText);
    end;

    var
        LibraryExpDataExch: Codeunit "TST Library - Exp. Data Exch.";
        LibraryRandom: Codeunit "TST Library - Random";
        LibraryAssert: Codeunit "Library Assert";

}