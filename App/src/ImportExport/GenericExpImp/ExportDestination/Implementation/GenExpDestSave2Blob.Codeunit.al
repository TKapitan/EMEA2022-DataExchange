codeunit 50105 "EMEA Gen.Exp.Dest.-Save2Blob" implements "EMEA Gen. Export Destination"
{
    procedure CheckBeforeExport(GenericExportImport: Record "EMEA Generic Export/Import")
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        FieldMustBeBlobErr: Label '%1 must be Blob field.', Comment = '%1 - Caption of the field';
    begin
        GenericExportImport.TestField("Export to Blob Table No.");
        GenericExportImport.TestField("Export to Blob Field No.");

        RecordRef.Open(GenericExportImport."Export to Blob Table No.");
        FieldRef := RecordRef.Field(GenericExportImport."Export to Blob Field No.");
        if FieldRef.Type() <> FieldRef.Type::Blob then
            Error(FieldMustBeBlobErr);
    end;

    procedure ProcessExport(GenericExportImport: Record "EMEA Generic Export/Import"; var DataExch: Record "Data Exch."): Boolean
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecordRef.Open(GenericExportImport."Export to Blob Table No.");
        RecordRef.Init();
        FieldRef := RecordRef.Field(GenericExportImport."Export to Blob Field No.");
        FieldRef.Value(DataExch."File Content");
        exit(RecordRef.Insert());
    end;
}