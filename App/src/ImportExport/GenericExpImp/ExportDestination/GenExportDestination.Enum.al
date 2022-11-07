enum 50100 "EMEA Gen. Export Destination" implements "EMEA Gen. Export Destination"
{
    Extensible = true;

    value(0; "Download File")
    {
        Caption = 'Download';
        Implementation = "EMEA Gen. Export Destination" = "EMEA Gen.Exp.Dest.-Download";
    }
    value(5; "Save to Blob")
    {
        Caption = 'Save to Blob Field';
        Implementation = "EMEA Gen. Export Destination" = "EMEA Gen.Exp.Dest.-Save2Blob";
    }
}