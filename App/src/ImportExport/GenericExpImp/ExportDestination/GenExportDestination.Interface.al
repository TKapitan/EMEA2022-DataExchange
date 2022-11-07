interface "EMEA Gen. Export Destination"
{
    procedure CheckBeforeExport(GenericExportImport: Record "EMEA Generic Export/Import");
    procedure ProcessExport(GenericExportImport: Record "EMEA Generic Export/Import"; var DataExch: Record "Data Exch."): Boolean;
}