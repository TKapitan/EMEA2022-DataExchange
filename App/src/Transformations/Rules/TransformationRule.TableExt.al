tableextension 50100 "EMEA Transformation Rule" extends "Transformation Rule"
{
    fields
    {
        modify("Transformation Type")
        {
            trigger OnAfterValidate()
            begin
                Rec."EMEA Cust. Transf. Rule Type" := Rec."Transformation Type";
                if Rec."Transformation Type".AsInteger() >= 50000 then
                    Rec."Transformation Type" := Rec."Transformation Type"::Custom;

                if Rec."EMEA Cust. Transf. Rule Type" <> Rec."EMEA Cust. Transf. Rule Type"::"EMEA Multiplication" then
                    Rec."EMEA Multiplicator" := 1;
            end;
        }

        field(50100; "EMEA Cust. Transf. Rule Type"; Enum "Transformation Rule Type")
        {
            Caption = 'Custom Transformation Rule Type';
            Editable = false;
            DataClassification = SystemMetadata;
        }

        field(50101; "EMEA Multiplicator"; Integer)
        {
            Caption = 'Multiplicator';
            MinValue = 1;
            InitValue = 1;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."EMEA Multiplicator" = 1 then
                    exit;
                Rec.TestField("EMEA Cust. Transf. Rule Type", Rec."EMEA Cust. Transf. Rule Type"::"EMEA Multiplication");
            end;
        }
    }
}