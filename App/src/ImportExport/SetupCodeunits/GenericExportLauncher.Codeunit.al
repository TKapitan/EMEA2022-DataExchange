codeunit 50102 "EMEA Generic Export Launcher"
{
    Permissions = TableData "Data Exch." = rimd;
    TableNo = "Data Exch. Mapping";

    trigger OnRun()
    var
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        iGenExportDestination: Interface "EMEA Gen. Export Destination";
    begin
        if not SourceRecordIsInitialized then
            Error(UnknownSourceRecordErr);

        iGenExportDestination := SourceGenericExportImport."Export Destination";
        iGenExportDestination.CheckBeforeExport(SourceGenericExportImport);

        DataExchDef.Get(Rec."Data Exch. Def Code");

        CreateDataExchange(DataExch, Rec."Data Exch. Def Code", Rec."Data Exch. Line Def Code", SourceRecordRef.GetView());

        if DataExchDef."Data Handling Codeunit" > 0 then
            CODEUNIT.Run(DataExchDef."Data Handling Codeunit", Rec);

        if DataExchDef."Validation Codeunit" > 0 then
            CODEUNIT.Run(DataExchDef."Validation Codeunit", Rec);

        DataExch.ExportFromDataExch(Rec);
    end;

    var
        SourceGenericExportImport: Record "EMEA Generic Export/Import";
        SourceRecordRef: RecordRef;
        SourceRecordIsInitialized: Boolean;
        UnknownSourceRecordErr: Label 'The source record is unknown. Exporting functionality cannot proceed without defining a source record to work on.';
        UnsupportedSourceRecordTypeErr: Label 'Only Record, RecordID or RecordRef are supported for initializing the source record. Exporting functionality cannot proceed without defining a source record to work on.';

    local procedure CreateDataExchange(var DataExch: Record "Data Exch."; DataExchDefCode: Code[20]; DataExchLineDefCode: Code[20]; TableFilters: Text)
    var
        TableFiltersOutStream: OutStream;
    begin
        DataExch.Init();
        DataExch."Data Exch. Def Code" := DataExchDefCode;
        DataExch."Data Exch. Line Def Code" := DataExchLineDefCode;
        DataExch."Table Filters".CreateOutStream(TableFiltersOutStream);
        TableFiltersOutStream.WriteText(TableFilters);
        DataExch."EMEA Gen. Exp./Imp. Code" := SourceGenericExportImport.Code;
        DataExch.Insert();
    end;

    procedure SetSource(NewSourceGenericExportImport: Record "EMEA Generic Export/Import"; var NewSourceVariant: Variant)
    var
        SourceRecordID: RecordID;
    begin
        NewSourceGenericExportImport.TestField(Code);
        SourceGenericExportImport := NewSourceGenericExportImport;
        case true of
            NewSourceVariant.IsRecord():
                SourceRecordRef.GetTable(NewSourceVariant);
            NewSourceVariant.IsRecordId():
                begin
                    SourceRecordID := NewSourceVariant;
                    SourceRecordRef := SourceRecordID.GetRecord();
                end;
            NewSourceVariant.IsRecordRef():
                SourceRecordRef := NewSourceVariant;
            else
                Error(UnsupportedSourceRecordTypeErr);
        end;
        SourceRecordIsInitialized := true;
    end;
}

