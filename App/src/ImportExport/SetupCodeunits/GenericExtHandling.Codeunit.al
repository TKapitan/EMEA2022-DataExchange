codeunit 50103 "EMEA Generic Ext. Handling"
{
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        GenericExportImport: Record "EMEA Generic Export/Import";
        iGenExportDestination: Interface "EMEA Gen. Export Destination";
        ExportSuccessfulMsg: Label 'Export successful.';
        ExportFailedErr: Label 'Export of %1 failed.', Comment = '%1 - Generic Export/Import code';
        ExternalContentErr: Label '%1 is empty.', Comment = '%1 - File Content field caption';
    begin
        Rec.CalcFields("File Content");
        if not Rec."File Content".HasValue() then
            Error(ExternalContentErr, Rec.FieldCaption("File Content"));

        Rec.TestField("EMEA Gen. Exp./Imp. Code");
        GenericExportImport.Get(Rec."EMEA Gen. Exp./Imp. Code");
        iGenExportDestination := GenericExportImport."Export Destination";
        if not iGenExportDestination.ProcessExport(GenericExportImport, Rec) then
            Error(ExportFailedErr, GenericExportImport.Code);
        Message(ExportSuccessfulMsg);
    end;
}