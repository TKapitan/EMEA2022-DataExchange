table 50101 "EMEA Data Exch. Usage Version"
{
    Caption = 'Data Exchange Usage Version';
    LookupPageId = "EMEA Data Exch. Usage Versions";
    DrillDownPageId = "EMEA Data Exch. Usage Versions";

    fields
    {
        field(1; "Usage Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            TableRelation = "EMEA Data Exchange Usage".Code;
            DataClassification = CustomerContent;
        }
        field(2; "No."; Integer)
        {
            Caption = 'No.';
            NotBlank = true;
            InitValue = 1;
            MinValue = 1;
            DataClassification = SystemMetadata;
        }
        field(5; "Data Exch. Def. Code"; Code[20])
        {
            Caption = 'Data Exchange Definition Code';
            TableRelation = "Data Exch. Def".Code;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Usage Code", "No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        DataExchUsageVersion: Record "EMEA Data Exch. Usage Version";
        NewVersionNo: Integer;
    begin
        if Rec."No." = 0 then begin
            NewVersionNo := 1;
            DataExchUsageVersion.SetRange("Usage Code", Rec."Usage Code");
            if DataExchUsageVersion.FindLast() then
                NewVersionNo += DataExchUsageVersion."No.";
            Rec.Validate("No.", NewVersionNo);
        end;
    end;

    trigger OnDelete()
    var
        GenericExportImport: Record "EMEA Generic Export/Import";
    begin
        GenericExportImport.SetRange("Data Exchange Usage Code", Rec."Usage Code");
        GenericExportImport.SetRange("Used Version No.", Rec."No.");
        GenericExportImport.DeleteAll(true);
    end;
}