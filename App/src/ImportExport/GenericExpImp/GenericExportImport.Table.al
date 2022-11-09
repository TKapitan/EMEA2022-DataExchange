table 50102 "EMEA Generic Export/Import"
{
    Caption = 'Generic Export/Import';
    LookupPageId = "EMEA Generic Exports/Imports";
    DrillDownPageId = "EMEA Generic Exports/Imports";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; "Data Exchange Usage Code"; Code[20])
        {
            Caption = 'Data Exchange Usage Code';
            TableRelation = "EMEA Data Exchange Usage".Code;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                AvailableTableNos: List of [Integer];
            begin
                AvailableTableNos := GetAvailableSourceTableNos();
                if AvailableTableNos.Count() = 1 then
                    Rec.Validate("Source Table No.", AvailableTableNos.Get(1));
            end;
        }
        field(50; "Used Version No."; Integer)
        {
            Caption = 'Used Version No.';
            BlankZero = true;
            MinValue = 0;
            TableRelation = "EMEA Data Exch. Usage Version"."No." where("Usage Code" = field("Data Exchange Usage Code"));
            DataClassification = CustomerContent;
        }
        field(100; "Source Table No."; Integer)
        {
            Caption = 'Source Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            BlankZero = true;
            DataClassification = SystemMetadata;

            trigger OnLookup()
            begin
                Rec.Validate("Source Table No.", LookupSourceTableNo());
            end;

            trigger OnValidate()
            var
                AllObjWithCaption: Record AllObjWithCaption;
                SourceTableNotAvailableErr: Label 'Source table %1 is not available for this setup.', Comment = '%1 - caption of the source table';
            begin
                if not GetAvailableSourceTableNos().Contains(Rec."Source Table No.") then begin
                    AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, Rec."Source Table No.");
                    Error(SourceTableNotAvailableErr, AllObjWithCaption."Object Caption");
                end;
            end;
        }
        field(101; "Source Table Caption"; Text[249])
        {
            Caption = 'Source Table Caption';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Source Table No.")));
        }
        field(102; "Source Table Filters"; Blob)
        {
            Caption = 'Table Filter';
            DataClassification = SystemMetadata;
        }
        field(200; "Export Destination"; Enum "EMEA Gen. Export Destination")
        {
            Caption = 'Export Destination';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if (Rec."Export Destination" = Rec."Export Destination"::"Save to Blob") and (xRec."Export Destination" <> Rec."Export Destination") then begin
                    Rec."Export to Blob Table No." := 0;
                    Rec."Export to Blob Field No." := 0;
                end;
            end;
        }
        field(201; "Export to Blob Table No."; Integer)
        {
            Caption = 'Export to Blob - Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Rec.TestField("Export Destination", Rec."Export Destination"::"Save to Blob");
                if Rec."Export to Blob Table No." <> xRec."Export to Blob Table No." then
                    Rec."Export to Blob Field No." := 0;
            end;
        }
        field(202; "Export to Blob Field No."; Integer)
        {
            Caption = 'Export to Blob - Field No.';
            TableRelation = Field."No." where(TableNo = field("Export to Blob Table No."), Type = const(BLOB));
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Rec.TestField("Export Destination", Rec."Export Destination"::"Save to Blob");
                Rec.TestField("Export to Blob Table No.");
            end;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    procedure RunExport()
    var
        DataExchangeUsage: Record "EMEA Data Exchange Usage";
        SourceVariant: Variant;
    begin
        Rec.TestField("Data Exchange Usage Code");
        DataExchangeUsage.Get(Rec."Data Exchange Usage Code");

        SourceVariant := GetSourceRecords();
        DataExchangeUsage.RunExport(Rec, SourceVariant);
    end;

    procedure RunImport()
    var
        NotImplementedErr: Label 'Procedure RunImport() is not implemented yet.';
    begin
        Error(NotImplementedErr);
    end;

    procedure GetUsedDataExchangeDefinitionCode(): Code[20]
    var
        DataExchangeUsage: Record "EMEA Data Exchange Usage";
        DataExchUsageVersion: Record "EMEA Data Exch. Usage Version";
    begin
        Rec.TestField("Data Exchange Usage Code");
        if Rec."Used Version No." = 0 then begin
            DataExchangeUsage.SetAutoCalcFields("Data Exch. Def. Code");
            DataExchangeUsage.Get(Rec."Data Exchange Usage Code");
            DataExchangeUsage.TestField("Data Exch. Def. Code");
            exit(DataExchangeUsage."Data Exch. Def. Code");
        end;
        DataExchUsageVersion.SetRange("Usage Code", Rec."Data Exchange Usage Code");
        DataExchUsageVersion.SetRange("No.", Rec."Used Version No.");
        DataExchUsageVersion.FindFirst();
        DataExchUsageVersion.TestField("Data Exch. Def. Code");
        exit(DataExchUsageVersion."Data Exch. Def. Code");
    end;

    procedure GetAvailableSourceTableNos() AvailableTableNos: List of [Integer];
    var
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchMapping: Record "Data Exch. Mapping";
    begin
        DataExchLineDef.SetRange("Data Exch. Def Code", GetUsedDataExchangeDefinitionCode());
        DataExchLineDef.SetRange("Line Type", DataExchLineDef."Line Type"::Detail);
        DataExchLineDef.SetRange("Parent Code", '');
        if DataExchLineDef.FindSet() then
            repeat
                DataExchMapping.SetRange("Data Exch. Def Code", DataExchLineDef."Data Exch. Def Code");
                DataExchMapping.SetRange("Data Exch. Line Def Code", DataExchLineDef.Code);
                if DataExchMapping.FindSet() then
                    repeat
                        if DataExchMapping."Use as Intermediate Table" then
                            MergeListDisctinct(AvailableTableNos, GetAvailableSourceTableNosForIntermediateTable(DataExchMapping))
                        else
                            if not AvailableTableNos.Contains(DataExchMapping."Table ID") then
                                AvailableTableNos.Add(DataExchMapping."Table ID");
                    until DataExchMapping.Next() < 1;
            until DataExchLineDef.Next() < 1;

        if AvailableTableNos.Contains(Database::"Intermediate Data Import") then
            AvailableTableNos.Remove(Database::"Intermediate Data Import");
    end;

    procedure GetAvailableSourceTableNosForIntermediateTable(DataExchMapping: Record "Data Exch. Mapping") AvailableTableNos: List of [Integer];
    var
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
    begin
        DataExchFieldMapping.SetRange("Data Exch. Def Code", DataExchMapping."Data Exch. Def Code");
        DataExchFieldMapping.SetRange("Data Exch. Line Def Code", DataExchMapping."Data Exch. Line Def Code");
        DataExchFieldMapping.SetRange("Table ID", DataExchMapping."Table ID");
        DataExchFieldMapping.SetFilter("Target Table ID", '<>0');
        if DataExchFieldMapping.FindSet() then
            repeat
                if not AvailableTableNos.Contains(DataExchFieldMapping."Target Table ID") then
                    AvailableTableNos.Add(DataExchFieldMapping."Target Table ID");
            until DataExchFieldMapping.Next() < 1;
    end;

    procedure SetSourceTableFilters(NewSourceTableFilters: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Rec."Source Table Filters");
        Rec."Source Table Filters".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewSourceTableFilters);
        Rec.Modify(true);
    end;

    procedure GetSourceTableFilters() SourceTableFilters: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        Rec.CalcFields("Source Table Filters");
        Rec."Source Table Filters".CreateInStream(InStream, TextEncoding::UTF8);
        if not TypeHelper.TryReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator(), SourceTableFilters) then
            SourceTableFilters := '';
    end;

    local procedure LookupSourceTableNo(): Integer
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.FilterGroup(2);
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.SetFilter("Object ID", GetAvailableSourceTableNosFilterString());
        AllObjWithCaption.FilterGroup(0);

        if Page.RunModal(Page::"All Objects with Caption", AllObjWithCaption) <> Action::LookupOK then
            Error('');

        exit(AllObjWithCaption."Object ID");
    end;

    local procedure GetAvailableSourceTableNosFilterString(): Text
    var
        TempTextBuilder: TextBuilder;
        AvailableSourceTableNo: Integer;
        FilterOrSeparatorTok: Label '|', Locked = true;
        NoSourceTablesAvailableErr: Label 'There are no available source tables.';
    begin
        foreach AvailableSourceTableNo in GetAvailableSourceTableNos() do begin
            if TempTextBuilder.Length() <> 0 then
                TempTextBuilder.Append(FilterOrSeparatorTok);
            TempTextBuilder.Append(Format(AvailableSourceTableNo));
        end;
        if TempTextBuilder.Length = 0 then
            Error(NoSourceTablesAvailableErr);
        exit(TempTextBuilder.ToText());
    end;

    local procedure GetSourceRecords() SourceVariant: Variant;
    var
        SourceRecordRef: RecordRef;
    begin
        Rec.TestField("Source Table No.");
        SourceRecordRef.Open(Rec."Source Table No.");
        SourceRecordRef.SetView(Rec.GetSourceTableFilters());
        SourceVariant := SourceRecordRef;
    end;

    local procedure MergeListDisctinct(var TargetList: List of [Integer]; SecondList: List of [Integer])
    var
        Value: Integer;
    begin
        foreach Value in SecondList do
            if not TargetList.Contains(Value) then
                TargetList.Add(Value);
    end;
}