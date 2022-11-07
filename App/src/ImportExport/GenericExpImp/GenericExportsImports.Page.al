page 50100 "EMEA Generic Exports/Imports"
{
    Caption = 'Generic Exports/Imports';
    PageType = List;
    SourceTable = "EMEA Generic Export/Import";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies code of the generic export/import setup.';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies descirption of the generic export/import setup.';
                    ApplicationArea = All;
                }
                field("Data Exchange Usage Code"; Rec."Data Exchange Usage Code")
                {
                    ToolTip = 'Specifies data exchange usage that should be used for export/import.';
                    ApplicationArea = All;
                }
                field("Used Version No."; Rec."Used Version No.")
                {
                    ToolTip = 'Specifies specific version which should be used. If the field is blank, the last version is automatically used.';
                    ApplicationArea = All;
                }
                field("Source Table No."; Rec."Source Table No.")
                {
                    ToolTip = 'Specifies source table number that should be used as the main data source for export or import.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        ConfirmManagement: Codeunit "Confirm Management";
                        DeleteExistingSetupQst: Label 'Do you really want to change %1 and delete all existing configuration for this setup?', Comment = '%1 - Source table no field caption';
                    begin
                        if xRec."Source Table No." <> 0 then begin
                            if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(DeleteExistingSetupQst, Rec.FieldCaption("Source Table No.")), true) then
                                Error('');
                            Rec.SetSourceTableFilters('');
                        end;
                        CurrPage.Update(true);
                    end;
                }
                field("Source Table Caption"; Rec."Source Table Caption")
                {
                    ToolTip = 'Specifies caption for the source table.';
                    ApplicationArea = All;
                }
                field("Source Table Filters"; FormatSourceTableFilters())
                {
                    ApplicationArea = All;
                    Caption = 'Table Filters';
                    ToolTip = 'Specifies the value of the Table Filters field.';
                    Editable = false;

                    trigger OnAssistEdit()
                    var
                        FilterPageBuilder: FilterPageBuilder;
                        SourceTableFilters: Text;
                    begin
                        if Rec."Source Table No." = 0 then
                            exit;

                        SourceTableFilters := Rec.GetSourceTableFilters();
                        FilterPageBuilder.AddTable(Rec."Source Table Caption", Rec."Source Table No.");
                        if SourceTableFilters <> '' then
                            FilterPageBuilder.SetView(Rec."Source Table Caption", SourceTableFilters);
                        if FilterPageBuilder.RunModal() then
                            Rec.SetSourceTableFilters(FilterPageBuilder.GetView(Rec."Source Table Caption", false));
                        CurrPage.Update(true);
                    end;
                }
                field("Export Destination"; Rec."Export Destination")
                {
                    ToolTip = 'Allows to specify how the export will be handled.';
                    ApplicationArea = All;
                }
                field("Export to Blob Table No."; Rec."Export to Blob Table No.")
                {
                    ToolTip = 'Specifies table that should be used to store exported file.';
                    ApplicationArea = All;
                }
                field("Export to Blob Field No."; Rec."Export to Blob Field No.")
                {
                    ToolTip = 'Specifies field of the export table that should be used for storing export.';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Export)
            {
                Caption = 'Export';
                ToolTip = 'Allows to export data based on selected data exchange definition and other setup.';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Rec.RunExport();
                end;
            }
            action(Import)
            {
                Caption = 'Import';
                ToolTip = 'Allows to import data based on selected data exchange definition and other setup.';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Rec.RunImport();
                end;
            }
        }
        area(Creation)
        {
            action("Init Default")
            {
                Caption = 'Initialize Default Export/Imports';
                ToolTip = 'Allows to initialize default export and imports as are configured within all installed extensions.';
                Image = NewLotProperties;
                ApplicationArea = All;

                trigger OnAction()
                var
                    EMEAInstallMgt: Codeunit "EMEA Install Mgt.";
                begin
                    EMEAInstallMgt.InitGenericExportForCustomer();
                end;
            }
        }
    }

    local procedure FormatSourceTableFilters(): Text;
    var
        RecordRef: RecordRef;
    begin
        if (Rec."Source Table No." = 0) or not Rec."Source Table Filters".HasValue() then
            exit('');

        RecordRef.Open(Rec."Source Table No.");
        RecordRef.SetView(Rec.GetSourceTableFilters());
        exit(RecordRef.GetFilters());
    end;
}
