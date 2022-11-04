page 50101 "EMEA Exported Records"
{
    Caption = 'Exported Records';
    ApplicationArea = All;
    PageType = List;
    Editable = false;
    SourceTable = "EMEA Exported Record";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies entry number of the record.';
                    ApplicationArea = All;
                }
                field(HasContent; HasContent)
                {
                    Caption = 'Has Content';
                    ToolTip = 'Specifies whether the record contains any content. If so, the content could be shown.';
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    var
                        TempBlob: Codeunit "Temp Blob";
                        FileManagement: Codeunit "File Management";
                        ExportFileName: Text;
                    begin
                        if not HasContent then
                            exit;

                        TempBlob.FromRecord(Rec, Rec.FieldNo("Exported Content"));
                        ExportFileName := Format(Today, 0, '<Month,2><Day,2><Year4>') + '.txt';
                        FileManagement.BLOBExport(TempBlob, ExportFileName, true);
                    end;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'Date & Time of export';
                    ToolTip = 'Specifies date & time of the export.';
                    ApplicationArea = All;
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    Caption = 'Exported By';
                    ToolTip = 'Specifies who did the export.';
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        HasContent := false;
        Rec.CalcFields("Exported Content");
        if Rec."Exported Content".HasValue() then
            HasContent := true;
    end;

    var
        HasContent: Boolean;
}
