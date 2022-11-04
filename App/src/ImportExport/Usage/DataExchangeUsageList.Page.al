page 50105 "EMEA Data Exchange Usage List"
{
    Caption = 'Data Exchange Usage';
    PageType = List;
    SourceTable = "EMEA Data Exchange Usage";
    UsageCategory = Administration;
    RefreshOnActivate = true;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies code of the data exchange usage.';
                    ApplicationArea = All;
                }
                field("Current Version"; Rec."Current Version")
                {
                    ToolTip = 'Specifies last existing version for this usage.';
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

    actions
    {
        area(Navigation)
        {
            action(Versions)
            {
                Caption = 'Versions';
                ToolTip = 'Allows to specify different versions for the usage.';
                Image = Versions;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "EMEA Data Exch. Usage Versions";
                RunPageLink = "Usage Code" = field(Code);
                ApplicationArea = All;
            }
        }
    }
}
