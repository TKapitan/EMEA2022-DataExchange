codeunit 99001 "TST Library - Exp. Data Exch."
{
    var
        LibraryRandom: Codeunit "TST Library - Random";

    procedure CreateDataExchFullSetup(var DataExchDef: Record "Data Exch. Def")
    var
        DataExchMapping: Record "Data Exch. Mapping";
        DataExchLineDef: Record "Data Exch. Line Def";
    begin
        CreateDataExchDef(DataExchDef);
        CreateDataExchLineDef(DataExchLineDef, DataExchDef);
        CreateDataExchMapping(DataExchMapping, DataExchLineDef);
        CreateAllDataExchColumnDefs(DataExchLineDef);
        CreateAllDataExchLineMapping(DataExchMapping);
    end;

    procedure CreateDataExchDef()
    var
        DataExchDef: Record "Data Exch. Def";
    begin
        CreateDataExchDef(DataExchDef);
    end;

    procedure CreateDataExchDef(var DataExchDef: Record "Data Exch. Def")
    begin
        DataExchDef.Init();
        DataExchDef.Validate(Code, LibraryRandom.RandText());
        DataExchDef.Validate(Name, LibraryRandom.RandText());
        DataExchDef.Validate(Type, "Data Exchange Definition Type"::"Generic Export");
        DataExchDef.Validate("File Type", DataExchDef."File Type"::"Variable Text");
        DataExchDef.Insert();
    end;

    procedure CreateDataExchLineDef(DataExchDef: Record "Data Exch. Def")
    var
        DataExchLineDef: Record "Data Exch. Line Def";
    begin
        CreateDataExchLineDef(DataExchLineDef, DataExchDef);
    end;

    procedure CreateDataExchLineDef(var DataExchLineDef: Record "Data Exch. Line Def"; DataExchDef: Record "Data Exch. Def")
    var
        NewCode: Code[20];
    begin
        NewCode := LibraryRandom.RandText();
        if DataExchLineDef.Get(DataExchDef.Code, NewCode) then
            exit;
        DataExchLineDef.InsertRec(DataExchDef.Code, NewCode, LibraryRandom.RandText(), LibraryRandom.GetDefaultLibrary().RandIntInRange(2, 6));
    end;

    procedure CreateDataExchColumnDef(DataExchLineDef: Record "Data Exch. Line Def"; ColumnNo: Integer)
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
    begin
        CreateDataExchColumnDef(DataExchColumnDef, DataExchLineDef, ColumnNo);
    end;

    procedure CreateDataExchColumnDef(var DataExchColumnDef: Record "Data Exch. Column Def"; DataExchLineDef: Record "Data Exch. Line Def"; ColumnNo: Integer)
    var
        OptionMembers: Option Text,Date,Decimal,DateTime;
    begin
        DataExchColumnDef.InsertRecForExport(DataExchLineDef."Data Exch. Def Code", DataExchLineDef.Code, ColumnNo, LibraryRandom.RandText(), OptionMembers::Text, '', 0, '');
    end;

    procedure CreateAllDataExchColumnDefs(DataExchLineDef: Record "Data Exch. Line Def")
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
        Counter: Integer;
        OptionMembers: Option Text,Date,Decimal,DateTime;
    begin
        if DataExchLineDef."Column Count" < 1 then
            exit;
        for Counter := 1 to DataExchLineDef."Column Count" do
            DataExchColumnDef.InsertRecForExport(DataExchLineDef."Data Exch. Def Code", DataExchLineDef.Code, Counter, LibraryRandom.RandText(), OptionMembers::Text, '', 0, '');
    end;

    procedure CreateDataExchMapping(DataExchLineDef: Record "Data Exch. Line Def")
    var
        DataExchMapping: Record "Data Exch. Mapping";
    begin
        CreateDataExchMapping(DataExchMapping, DataExchLineDef);
    end;

    procedure CreateDataExchMapping(var DataExchMapping: Record "Data Exch. Mapping"; DataExchLineDef: Record "Data Exch. Line Def")
    begin
        CreateDataExchMapping(DataExchMapping, DataExchLineDef, Database::Customer);
    end;

    procedure CreateDataExchMapping(var DataExchMapping: Record "Data Exch. Mapping"; DataExchLineDef: Record "Data Exch. Line Def"; TableNo: Integer)
    begin
        DataExchMapping.InsertRecForExport(DataExchLineDef."Data Exch. Def Code", DataExchLineDef.Code, TableNo, LibraryRandom.RandText(), Codeunit::"Export Mapping");
    end;

    procedure CreateDataExchLineMapping(DataExchMapping: Record "Data Exch. Mapping"; ColumnNo: Integer; FieldNo: Integer)
    var
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
    begin
        CreateDataExchLineMapping(DataExchFieldMapping, DataExchMapping, ColumnNo, FieldNo);
    end;

    procedure CreateDataExchLineMapping(var DataExchFieldMapping: Record "Data Exch. Field Mapping"; DataExchMapping: Record "Data Exch. Mapping"; ColumnNo: Integer; FieldNo: Integer)
    begin
        DataExchFieldMapping.InsertRec(DataExchMapping."Data Exch. Def Code", DataExchMapping."Data Exch. Line Def Code", DataExchMapping."Table ID", ColumnNo, FieldNo, false, 1);
    end;

    procedure CreateAllDataExchLineMapping(DataExchMapping: Record "Data Exch. Mapping")
    var
        Customer: Record Customer;
        DataExchColumnDef: Record "Data Exch. Column Def";
    begin
        DataExchMapping.TestField("Table ID", Database::Customer);
        DataExchColumnDef.SetRange("Data Exch. Def Code", DataExchMapping."Data Exch. Def Code");
        DataExchColumnDef.SetRange("Data Exch. Line Def Code", DataExchMapping."Data Exch. Line Def Code");
        DataExchColumnDef.FindSet();
        repeat
            case DataExchColumnDef."Data Type" of
                DataExchColumnDef."Data Type"::Text:
                    CreateDataExchLineMapping(DataExchMapping, DataExchColumnDef."Column No.", Customer.FieldNo("No."));
                DataExchColumnDef."Data Type"::DateTime:
                    CreateDataExchLineMapping(DataExchMapping, DataExchColumnDef."Column No.", Customer.FieldNo(SystemCreatedAt));
                DataExchColumnDef."Data Type"::Decimal:
                    CreateDataExchLineMapping(DataExchMapping, DataExchColumnDef."Column No.", Customer.FieldNo("Credit Amount (LCY)"));
                DataExchColumnDef."Data Type"::Date:
                    CreateDataExchLineMapping(DataExchMapping, DataExchColumnDef."Column No.", Customer.FieldNo("Last Date Modified"));
            end;
        until DataExchColumnDef.Next() < 1;
    end;

    procedure CreateDataExchUsage(var EMEADataExchangeUsage: Record "EMEA Data Exchange Usage"; DataExchDefCode: Code[20])
    begin
        CreateDataExchUsage(EMEADataExchangeUsage, LibraryRandom.RandText(), DataExchDefCode);
    end;

    procedure CreateDataExchUsage(UsageCode: Code[20]; DataExchDefCode: Code[20])
    var
        EMEADataExchangeUsage: Record "EMEA Data Exchange Usage";
    begin
        CreateDataExchUsage(EMEADataExchangeUsage, UsageCode, DataExchDefCode);
    end;

    procedure CreateDataExchUsage(var EMEADataExchangeUsage: Record "EMEA Data Exchange Usage"; UsageCode: Code[20]; DataExchDefCode: Code[20])
    var
        EMEADataExchUsageVersion: Record "EMEA Data Exch. Usage Version";
    begin
        if UsageCode = '' then
            UsageCode := LibraryRandom.RandText();

        if not EMEADataExchangeUsage.Get(UsageCode) then begin
            EMEADataExchangeUsage.Init();
            EMEADataExchangeUsage.Validate(Code, UsageCode);
            EMEADataExchangeUsage.Validate(Description, LibraryRandom.RandText());
            EMEADataExchangeUsage.Insert(true);
        end;

        EMEADataExchUsageVersion.Init();
        EMEADataExchUsageVersion.Validate("Usage Code", EMEADataExchangeUsage.Code);
        EMEADataExchUsageVersion.Validate("No.", 0);
        EMEADataExchUsageVersion.Validate("Data Exch. Def. Code", DataExchDefCode);
        EMEADataExchUsageVersion.Insert(true);
    end;

    procedure CreateGenericExportSetup(var EMEAGenericExportImport: Record "EMEA Generic Export/Import"; DataExchangeUsageCode: Code[20])
    begin
        EMEAGenericExportImport.Init();
        EMEAGenericExportImport.Validate(Code, LibraryRandom.RandText());
        EMEAGenericExportImport.Validate(Description, LibraryRandom.RandText());
        EMEAGenericExportImport.Validate("Data Exchange Usage Code", DataExchangeUsageCode);
        EMEAGenericExportImport.Insert(true);
    end;

    procedure SetOurTxtExportObjects(var DataExchDef: Record "Data Exch. Def")
    begin
        DataExchDef.Validate("Reading/Writing Codeunit", Codeunit::"Exp. Writing Gen. Jnl.");
        DataExchDef.Validate("Reading/Writing XMLport", Xmlport::"Export Generic Fixed Width");
        DataExchDef.Validate("Ext. Data Handling Codeunit", Codeunit::"EMEA Generic Ext. Handling");
        DataExchDef.Modify(true);
    end;
}