codeunit 50106 "EMEA Install Mgt."
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        InitGenericExportForCustomer();
    end;

    var
        GenericExportForCustomerTok: Label 'CUST-EXP01';

    procedure InitGenericExportForCustomer()
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

        CreateDataExchangeUsageAndVersion(DataExchDef);
    end;

    local procedure InsertDataExchDef(var DataExchDef: Record "Data Exch. Def"): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
        DataExchDefCode: Code[20];
        Counter: Integer;
        DataExchangeDefinitionExistsOverwriteQst: Label '%1 %2 already exists. Do you want to add new version of data exchange definition?', Comment = '%1 - Data Exchange Definition table caption, %2 - Data Exchange Definition Code';
        NewVersionCanNotBeCreatedErr: Label 'New version for %1 %2 can not be created.', Comment = '%1 - Data Exchange Definition table caption, %2 - Data Exchange Definition Code';
    begin
        DataExchDefCode := GenericExportForCustomerTok;
        if DataExchDef.Get(DataExchDefCode) then begin
            if not ConfirmManagement.GetResponse(StrSubstNo(DataExchangeDefinitionExistsOverwriteQst, DataExchDef.TableCaption(), DataExchDef.Code), true) then
                exit(false);

            for Counter := 1 to 100 do begin
                DataExchDefCode := IncStr(DataExchDefCode);
                if not DataExchDef.Get(DataExchDefCode) then
                    break;
            end;
            if DataExchDef.Code = '' then
                Error(NewVersionCanNotBeCreatedErr);
        end;

        DataExchDef.Init();
        DataExchDef.Validate(Code, DataExchDefCode);
        DataExchDef.Validate(Name, DataExchDefCode);
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
    begin
        DataExchFieldMapping.InsertRec(DataExchMapping."Data Exch. Def Code", DataExchMapping."Data Exch. Line Def Code", DataExchMapping."Table ID", 1,
                                        Customer.FieldNo("No."), false, 1);
        DataExchFieldMapping.InsertRec(DataExchMapping."Data Exch. Def Code", DataExchMapping."Data Exch. Line Def Code", DataExchMapping."Table ID", 2,
                                        Customer.FieldNo(Name), false, 1);
        DataExchFieldMapping.InsertRec(DataExchMapping."Data Exch. Def Code", DataExchMapping."Data Exch. Line Def Code", DataExchMapping."Table ID", 3,
                                        Customer.FieldNo(Balance), true, 1);

        CreateMultiplication10TransfRule(TransformationRule);
        DataExchFieldMapping.Validate("Transformation Rule", TransformationRule.Code);
        DataExchFieldMapping.Modify(true);

        DataExchFieldMapping.InsertRec(DataExchMapping."Data Exch. Def Code", DataExchMapping."Data Exch. Line Def Code", DataExchMapping."Table ID", 5,
                Customer.FieldNo(Address), false, 1);
    end;

    local procedure CreateMultiplication10TransfRule(TransformationRule: Record "Transformation Rule")
    var
        MultiplyDescriptionTxt: Label 'Multiply a number by 10.';
        Multiplication10Tok: Label 'MULTIPLICATION-10', Locked = true;
    begin
        if TransformationRule.Get(Multiplication10Tok) then
            exit;
        TransformationRule.CreateRule(Multiplication10Tok, MultiplyDescriptionTxt, TransformationRule."Transformation Type"::"EMEA Multiplication".AsInteger(), 0, 0, '', '');
        TransformationRule.Validate("EMEA Multiplicator", 10);
        TransformationRule.Modify(true);
    end;

    local procedure CreateDataExchangeUsageAndVersion(var DataExchDef: Record "Data Exch. Def")
    var
        DataExchangeUsage: Record "EMEA Data Exchange Usage";
        DataExchUsageVersion: Record "EMEA Data Exch. Usage Version";
    begin
        CreateDataExchangeUsageIfNotExists(DataExchangeUsage);
        DataExchUsageVersion.Init();
        DataExchUsageVersion.Validate("Usage Code", DataExchangeUsage.Code);
        DataExchUsageVersion.Validate("No.", 0);
        DataExchUsageVersion.Validate("Data Exch. Def. Code", DataExchDef.Code);
        DataExchUsageVersion.Insert();
    end;

    local procedure CreateDataExchangeUsageIfNotExists(var DataExchangeUsage: Record "EMEA Data Exchange Usage")
    begin
        if DataExchangeUsage.Get(GenericExportForCustomerTok) then
            exit;
        DataExchangeUsage.Init();
        DataExchangeUsage.Validate(Code, GenericExportForCustomerTok);
        DataExchangeUsage.Insert(true);
    end;
}