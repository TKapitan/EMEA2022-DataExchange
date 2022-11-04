page 50104 "EMEA Data Exch. Usage Versions"
{
    Caption = 'Data Exchange Usage Versions';
    PageType = List;
    SourceTable = "EMEA Data Exch. Usage Version";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Usage Code"; Rec."Usage Code")
                {
                    ToolTip = 'Specifies code of the data exchange usage.';
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies version number. Newer version must always have higher number than all previous versions.';
                    ApplicationArea = All;
                }
                field("Data Exch. Def. Code"; Rec."Data Exch. Def. Code")
                {
                    ToolTip = 'Specifies code of used data exchange definition.';
                    ApplicationArea = All;
                }
            }
        }
    }
}
