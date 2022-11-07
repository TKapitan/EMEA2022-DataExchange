pageextension 50100 "EMEA Transf. Rule Card" extends "Transformation Rule Card"
{
    layout
    {
        addafter("Transformation Type")
        {
            field("EMEA Cust. Transf. Rule Type"; Rec."EMEA Cust. Transf. Rule Type")
            {
                ToolTip = 'Specifies custom transformation rule type.';
                ApplicationArea = All;
            }
        }
        addafter(General)
        {
            group("EMEA Custom")
            {
                Caption = 'Custom';
                Visible = Rec."Transformation Type" = Rec."Transformation Type"::"Custom";

                field("EMEA Multiplicator"; Rec."EMEA Multiplicator")
                {
                    ToolTip = 'Specifies multiplicator for imported or exported values.';
                    ApplicationArea = All;
                }
            }
        }
    }
}