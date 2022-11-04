codeunit 50100 "EMEA Transf.R-Multiplication"
{
    SingleInstance = true;

    var
        MultipleDescriptionTxt: Label 'Multiple a number.';
        MultipleTok: Label 'MULTIPLE', Locked = true;

    [EventSubscriber(ObjectType::Table, Database::"Transformation Rule", 'OnCreateTransformationRules', '', false, false)]
    local procedure OnCreateTransformationRulesTransformationRule()
    var
        TransformationRule: Record "Transformation Rule";
    begin
        if TransformationRule.Get(MultipleTok) then
            exit;
        TransformationRule.CreateRule(MultipleTok, MultipleDescriptionTxt, TransformationRule."Transformation Type"::"EMEA Multiplication".AsInteger(), 0, 0, '', '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transformation Rule", 'OnTransformation', '', false, false)]
    local procedure OnTransformationTransformationRule(TransformationCode: Code[20]; InputText: Text; var OutputText: Text)
    var
        TransformationRule: Record "Transformation Rule";
    begin
        TransformationRule.Get(TransformationCode);
        if TransformationRule."EMEA Cust. Transf. Rule Type" <> TransformationRule."EMEA Cust. Transf. Rule Type"::"EMEA Multiplication" then
            exit;
        if not TryMultiple(InputText, OutputText) then
            OutputText := ''
    end;

    [TryFunction]
    local procedure TryMultiple(InputText: Text; var OutputText: Text)
    var
        TransformationRule: Record "Transformation Rule";
        TempInteger: Integer;
        TempDecimal: Decimal;
    begin
        TransformationRule.Get(MultipleTok);
        if Evaluate(TempInteger, InputText) then
            OutputText := Format(TempInteger * TransformationRule."EMEA Multiplicator");
        Evaluate(TempDecimal, InputText);
        OutputText := Format(TempDecimal * TransformationRule."EMEA Multiplicator");
    end;
}