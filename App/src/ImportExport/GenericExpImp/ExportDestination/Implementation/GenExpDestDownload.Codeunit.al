codeunit 50104 "EMEA Gen.Exp.Dest.-Download" implements "EMEA Gen. Export Destination"
{
    procedure CheckBeforeExport(GenericExportImport: Record "EMEA Generic Export/Import")
    begin
    end;

    procedure ProcessExport(GenericExportImport: Record "EMEA Generic Export/Import"; var DataExch: Record "Data Exch."): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        ExportFileName: Text;
    begin
        TempBlob.FromRecord(DataExch, DataExch.FieldNo("File Content"));
        ExportFileName := DataExch."Data Exch. Def Code" + Format(Today, 0, '<Month,2><Day,2><Year4>') + '.txt';
        exit(FileManagement.BLOBExport(TempBlob, ExportFileName, true) <> '');
    end;
}