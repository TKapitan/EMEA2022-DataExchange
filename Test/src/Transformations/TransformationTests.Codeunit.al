codeunit 99000 "TST Transformation Tests"
{
    Subtype = Test;

    [Test]
    procedure TestDefaultMultiplicationIsCreated()
    var
        TransformationRule: Record "Transformation Rule";
    begin
        // [GIVEN] No transformation rules exist
        TransformationRule.DeleteAll();

        // [WHEN] Transformation Rules are initialized
        TransformationRule.CreateDefaultTransformations();

        // [THEN] Multiplication rule exists
        Clear(TransformationRule);
        TransformationRule.SetRange("EMEA Cust. Transf. Rule Type", TransformationRule."EMEA Cust. Transf. Rule Type"::"EMEA Multiplication");
        LibraryAssert.RecordIsNotEmpty(TransformationRule);
    end;

    [Test]
    procedure TestMultiplicationInteger()
    var
        TransformationRule: Record "Transformation Rule";
        InputNumber, ResultNumber : Decimal;
        ResultText: Text;
    begin
        // [GIVEN] Transformation Rules are initialized
        Iniatialize();
        TransformationRule.SetRange("EMEA Cust. Transf. Rule Type", TransformationRule."EMEA Cust. Transf. Rule Type"::"EMEA Multiplication");
        TransformationRule.FindFirst();
        TransformationRule.Validate("EMEA Multiplicator", 100);
        TransformationRule.Modify(true);

        // [WHEN] Integer should be mupliplied by existing multiplicator 
        InputNumber := 50;
        ResultText := TransformationRule.TransformText(Format(InputNumber));
        Evaluate(ResultNumber, ResultText);

        // [THEN] The value is calculated correctly
        LibraryAssert.AreEqual(5000, ResultNumber, 'Multiplication of integer result is not correct');
    end;

    [Test]
    procedure TestMultiplicationDecimal()
    var
        TransformationRule: Record "Transformation Rule";
        InputNumber, ResultNumber : Decimal;
        ResultText: Text;
    begin
        // [GIVEN] Transformation Rules are initialized
        Iniatialize();
        TransformationRule.SetRange("EMEA Cust. Transf. Rule Type", TransformationRule."EMEA Cust. Transf. Rule Type"::"EMEA Multiplication");
        TransformationRule.FindFirst();
        TransformationRule.Validate("EMEA Multiplicator", 100);
        TransformationRule.Modify(true);

        // [WHEN] Decimal should be mupliplied by existing multiplicator 
        InputNumber := 50.5;
        ResultText := TransformationRule.TransformText(Format(InputNumber));
        Evaluate(ResultNumber, ResultText);

        // [THEN] The value is calculated correctly
        LibraryAssert.AreEqual(5050, ResultNumber, 'Multiplication of decimal is not correct');
    end;

    [Test]
    procedure TestMultiplicationNonNumber()
    var
        TransformationRule: Record "Transformation Rule";
        LibraryRandom: Codeunit "Library - Random";
        ResultText: Text;
    begin
        // [GIVEN] Transformation Rules are initialized
        Iniatialize();
        TransformationRule.SetRange("EMEA Cust. Transf. Rule Type", TransformationRule."EMEA Cust. Transf. Rule Type"::"EMEA Multiplication");
        TransformationRule.FindFirst();
        TransformationRule.Validate("EMEA Multiplicator", 100);
        TransformationRule.Modify(true);

        // [WHEN] Nonnumeric value should be mupliplied by existing multiplicator 
        ResultText := TransformationRule.TransformText(LibraryRandom.RandText(10));

        // [THEN] Empty value is returned
        LibraryAssert.AreEqual('', ResultText, 'Multiplication of non numeric value is not correct');
    end;

    var
        LibraryAssert: Codeunit "Library Assert";


    local procedure Iniatialize()
    var
        TransformationRule: Record "Transformation Rule";
    begin
        TransformationRule.DeleteAll();
        TransformationRule.CreateDefaultTransformations();
    end;
}