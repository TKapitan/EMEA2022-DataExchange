tableextension 50101 "EMEA Data Exchange" extends "Data Exch."
{
    fields
    {
        field(50102; "EMEA Gen. Exp./Imp. Code"; Code[20])
        {
            Caption = 'Generic Export/Import Code';
            TableRelation = "EMEA Generic Export/Import".Code;
            DataClassification = CustomerContent;
        }
    }
}