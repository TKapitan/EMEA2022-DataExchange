table 50100 "EMEA Data Exchange Usage"
{
    Caption = 'Data Exchange Usage';
    LookupPageId = "EMEA Data Exchange Usage List";
    DrillDownPageId = "EMEA Data Exchange Usage List";

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
        field(50; "Current Version"; Integer)
        {
            Caption = 'Current Version';
            NotBlank = true;
            BlankZero = true;
            FieldClass = FlowField;
            CalcFormula = max("EMEA Data Exch. Usage Version"."No." where("Usage Code" = field("Code")));

            trigger OnLookup()
            begin
                LookupVersions();
            end;
        }
        field(51; "Data Exch. Def. Code"; Code[20])
        {
            Caption = 'Data Exchange Definition Code';
            NotBlank = true;
            FieldClass = FlowField;
            CalcFormula = lookup("EMEA Data Exch. Usage Version"."Data Exch. Def. Code" where("Usage Code" = field("Code"), "No." = field("Current Version")));

            trigger OnLookup()
            begin
                LookupVersions();
            end;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        GenericExportImport: Record "EMEA Generic Export/Import";
        DataExchUsageVersion: Record "EMEA Data Exch. Usage Version";
    begin
        DataExchUsageVersion.SetRange("Usage Code", Rec.Code);
        DataExchUsageVersion.DeleteAll(true);

        GenericExportImport.SetRange("Data Exchange Usage Code", Rec.Code);
        GenericExportImport.DeleteAll(true);
    end;

    procedure RunExport(SourceGenericExportImport: Record "EMEA Generic Export/Import"; var SourceVariant: Variant)
    var
        DataExchMapping: Record "Data Exch. Mapping";
        GenericExportLauncher: Codeunit "EMEA Generic Export Launcher";
    begin
        SourceGenericExportImport.TestField("Source Table No.");
        DataExchMapping.SetRange("Data Exch. Def Code", SourceGenericExportImport.GetUsedDataExchangeDefinitionCode());
        DataExchMapping.SetFilter("Table ID", '0|%1', SourceGenericExportImport."Source Table No.");
        DataExchMapping.FindFirst();

        GenericExportLauncher.SetSource(SourceGenericExportImport, SourceVariant);
        GenericExportLauncher.Run(DataExchMapping);
    end;

    local procedure LookupVersions()
    var
        DataExchUsageVersion: Record "EMEA Data Exch. Usage Version";
    begin
        DataExchUsageVersion.SetRange("Usage Code", Rec.Code);
        Page.Run(0, DataExchUsageVersion);
    end;
}