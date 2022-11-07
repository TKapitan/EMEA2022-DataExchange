tableextension 50102 "EMEA Data Exch. Def." extends "Data Exch. Def"
{
    trigger OnAfterDelete()
    var
        DataExchUsageVersion: Record "EMEA Data Exch. Usage Version";
    begin
        DataExchUsageVersion.SetRange("Data Exch. Def. Code", Rec."Code");
        DataExchUsageVersion.DeleteAll();
    end;
}