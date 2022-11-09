table 50103 "EMEA Exported Record"
{
    Caption = 'Exported Record';
    LookupPageId = "EMEA Exported Records";
    DrillDownPageId = "EMEA Exported Records";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(5; "Exported Content"; Blob)
        {
            Caption = 'Exported Content';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    procedure GetExportedContent() ExportedContent: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        Rec.CalcFields("Exported Content");
        Rec."Exported Content".CreateInStream(InStream, TextEncoding::UTF8);
        if not TypeHelper.TryReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator(), ExportedContent) then
            ExportedContent := '';
    end;
}