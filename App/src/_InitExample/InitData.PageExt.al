pageextension 50101 "EMEA Init Data" extends "Company Information"
{
    actions
    {
        addlast(Creation)
        {
            action("EMEA Init EMEA")
            {
                Caption = 'Init data for EMEA';
                ToolTip = 'Init data for EMEA examples.';
                Image = Database;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    CreateCustomers();
                end;
            }
        }
    }

    local procedure CreateCustomers()
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        Location: Record Location;
        Counter: Integer;
    begin
        Location.FindSet();
        for Counter := Customer.Count() to 250 do begin
            Customer2.Init();
            Customer2.Validate("No.", RandomString(11, false));
            Customer2.Validate(Name, RandomString(15, true));
            customer2."Location Code" := Location.Code;
            Customer2.Insert();

            if Location.Next() < 1 then
#pragma warning disable AA0181
#pragma warning disable AA0175
                Location.FindSet();
#pragma warning restore AA0175
#pragma warning restore AA0181
        end;
    end;

    local procedure RandomString(Length: Integer; IncludeSpace: Boolean): Text
    var
        Counter: Integer;
        ResultText: Text;
        FromText: Text;
        FromTextLbl: Label 'abcdefghijklmnopqrstuvwxyz0123456789';
    begin
        FromText := FromTextLbl;
        if IncludeSpace then
            FromText += ' ';
        for Counter := 1 to Length do
            ResultText += CopyStr(FromText, Random(StrLen(FromText) - 1), 1);
        exit(ResultText);
    end;
}