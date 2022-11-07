codeunit 99003 "TST Data Exch. Usage Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure TestSecondDataExchDefForSameUsageHasHigherVersion()
    var
        DataExchDef: Record "Data Exch. Def";
        DataExchDef2: Record "Data Exch. Def";
        EMEADataExchUsageVersion: Record "EMEA Data Exch. Usage Version";
        DataExchangeUsageCode: Code[20];
    begin
        // [GIVEN] Two data exchange definitions exist 
        LibraryExpDataExch.CreateDataExchFullSetup(DataExchDef);
        LibraryExpDataExch.CreateDataExchFullSetup(DataExchDef2);

        // [WHEN] Both have the same usage
        DataExchangeUsageCode := LibraryRandom.RandText();
        LibraryExpDataExch.CreateDataExchUsage(DataExchangeUsageCode, DataExchDef.Code);
        LibraryExpDataExch.CreateDataExchUsage(DataExchangeUsageCode, DataExchDef2.Code);

        // [THEN] Then Expected Output
        EMEADataExchUsageVersion.Get(DataExchangeUsageCode, 1);
        LibraryAssert.AreEqual(DataExchDef.Code, EMEADataExchUsageVersion."Data Exch. Def. Code", EMEADataExchUsageVersion.FieldCaption("Data Exch. Def. Code"));
        EMEADataExchUsageVersion.Get(DataExchangeUsageCode, 2);
        LibraryAssert.AreEqual(DataExchDef2.Code, EMEADataExchUsageVersion."Data Exch. Def. Code", EMEADataExchUsageVersion.FieldCaption("Data Exch. Def. Code"));
    end;

    var
        LibraryRandom: Codeunit "TST Library - Random";
        LibraryAssert: Codeunit "Library Assert";
        LibraryExpDataExch: Codeunit "TST Library - Exp. Data Exch.";
}