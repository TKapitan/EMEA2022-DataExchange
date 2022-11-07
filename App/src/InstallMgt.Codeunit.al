codeunit 50106 "EMEA Install Mgt."
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        InitDataExchangeForCustomerExport();
    end;

    procedure InitDataExchangeForCustomerExport()
    var
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchMapping: Record "Data Exch. Mapping";
    begin
        if not InsertDataExchDef(DataExchDef) then
            exit;
        InsertDataExchLineDef(DataExchDef, DataExchLineDef);
        InsertDataExchColumnDef(DataExchLineDef);
        InsertDataExchMapping(DataExchLineDef, DataExchMapping);
        InsertDataExchFieldMapping(DataExchMapping);
    end;

    local procedure InsertDataExchDef(var DataExchDef: Record "Data Exch. Def"): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
        CustExportDataExchDefCodeTok: Label 'CUST-EXP01';
        DataExchangeDefinitionExistsOverwriteQst: Label '%1 %2 already exists. Do you want to overwrite current definition?', Comment = '%1 - Data Exchange Definition table caption, %2 - Data Exchange Definition Code';
    begin
        if DataExchDef.Get(CustExportDataExchDefCodeTok) then begin
            if not ConfirmManagement.GetResponse(StrSubstNo(DataExchangeDefinitionExistsOverwriteQst, DataExchDef.TableCaption(), DataExchDef.Code), true) then
                exit(false);
            DataExchDef.Delete(true);
        end;

        DataExchDef.Init();
        DataExchDef.Validate(Code, CustExportDataExchDefCodeTok);
        DataExchDef.Validate(Name, CustExportDataExchDefCodeTok);
        DataExchDef.Validate(Type, "Data Exchange Definition Type"::"Generic Export");
        DataExchDef.Validate("File Type", DataExchDef."File Type"::"Variable Text");

        DataExchDef.Validate("Reading/Writing Codeunit", Codeunit::"Exp. Writing Gen. Jnl.");
        DataExchDef.Validate("Reading/Writing XMLport", Xmlport::"Export Generic Fixed Width");
        DataExchDef.Validate("Ext. Data Handling Codeunit", Codeunit::"EMEA Generic Ext. Handling");
        DataExchDef.Insert();
        exit(true);
    end;

    local procedure InsertDataExchLineDef(DataExchDef: Record "Data Exch. Def"; var DataExchLineDef: Record "Data Exch. Line Def")
    var
        CustExportDataExchLineDefCodeTok: Label 'CUSTOMER';
    begin
        DataExchLineDef.Init();
        DataExchLineDef.InsertRec(DataExchDef.Code, CustExportDataExchLineDefCodeTok, CustExportDataExchLineDefCodeTok, 5);
    end;

    local procedure InsertDataExchColumnDef(DataExchLineDef: Record "Data Exch. Line Def")
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
        OptionMembers: Option Text,Date,Decimal,DateTime;
    begin
        DataExchColumnDef.Init();
        DataExchColumnDef.InsertRecForExport(DataExchLineDef."Data Exch. Def Code", DataExchLineDef.Code, 1, 'number', OptionMembers::Text, '', 20, '');
        DataExchColumnDef.Validate("Text Padding Required", true);
        DataExchColumnDef.Validate("Pad Character", '0');
        DataExchColumnDef.Modify(true);
        DataExchColumnDef.InsertRecForExport(DataExchLineDef."Data Exch. Def Code", DataExchLineDef.Code, 2, 'name', OptionMembers::Text, '', 0, '');
        DataExchColumnDef.InsertRecForExport(DataExchLineDef."Data Exch. Def Code", DataExchLineDef.Code, 3, 'balance', OptionMembers::Decimal, '', 0, '');
        DataExchColumnDef.Validate("Data Formatting Culture", 'en-AU');
        DataExchColumnDef.Modify(true);
        DataExchColumnDef.InsertRecForExport(DataExchLineDef."Data Exch. Def Code", DataExchLineDef.Code, 4, 'exported', OptionMembers::Text, '', 0, '1');
        DataExchColumnDef.InsertRecForExport(DataExchLineDef."Data Exch. Def Code", DataExchLineDef.Code, 5, 'address', OptionMembers::Text, '', 0, '');

        Clear(DataExchColumnDef);
        DataExchColumnDef.SetRange("Data Exch. Def Code", DataExchLineDef."Data Exch. Def Code");
        if DataExchColumnDef.FindSet() then
            repeat
                DataExchColumnDef.ValidateRec();
            until DataExchColumnDef.Next() < 1;
    end;

    local procedure InsertDataExchMapping(DataExchLineDef: Record "Data Exch. Line Def"; var DataExchMapping: Record "Data Exch. Mapping")
    begin
        DataExchMapping.InsertRecForExport(DataExchLineDef."Data Exch. Def Code", DataExchLineDef.Code, Database::Customer, '', Codeunit::"Export Mapping");
    end;

    local procedure InsertDataExchFieldMapping(DataExchMapping: Record "Data Exch. Mapping")
    var
        Customer: Record Customer;
        TransformationRule: Record "Transformation Rule";
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
        MultiplicationTok: Label 'MULTIPLICATION', Locked = true;
    begin
        DataExchFieldMapping.InsertRec(DataExchMapping."Data Exch. Def Code", DataExchMapping."Data Exch. Line Def Code", DataExchMapping."Table ID", 1,
                                        Customer.FieldNo("No."), false, 1);
        DataExchFieldMapping.InsertRec(DataExchMapping."Data Exch. Def Code", DataExchMapping."Data Exch. Line Def Code", DataExchMapping."Table ID", 2,
                                        Customer.FieldNo(Name), false, 1);
        DataExchFieldMapping.InsertRec(DataExchMapping."Data Exch. Def Code", DataExchMapping."Data Exch. Line Def Code", DataExchMapping."Table ID", 3,
                                        Customer.FieldNo(Balance), true, 1);

        // Important or the next line fails because newly added tranformation rules are loaded on init of company + on open page of transformation rules
        TransformationRule.OnCreateTransformationRules();
        DataExchFieldMapping.Validate("Transformation Rule", MultiplicationTok);
        DataExchFieldMapping.Modify(true);
        DataExchFieldMapping.InsertRec(DataExchMapping."Data Exch. Def Code", DataExchMapping."Data Exch. Line Def Code", DataExchMapping."Table ID", 5,
                Customer.FieldNo(Address), false, 1);
    end;
}