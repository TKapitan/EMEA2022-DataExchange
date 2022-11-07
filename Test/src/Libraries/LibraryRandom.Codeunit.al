codeunit 99002 "TST Library - Random"
{
    SingleInstance = true;

    var
        LibraryRandom: Codeunit "Library - Random";

    procedure RandText(): Text
    begin
        exit(RandText(LibraryRandom.RandIntInRange(5, 10)));
    end;

    procedure RandText(Length: Integer): Text
    begin
        exit(RandTextWithSpecificChars('0123456789abcdefghijklmnopqrstuvwxyz', false, Length));
    end;

    procedure RandTextWithNumbersOnly(): Text
    begin
        exit(RandTextWithNumbersOnly(LibraryRandom.RandIntInRange(5, 10)));
    end;

    procedure RandTextWithNumbersOnly(Length: Integer): Text
    begin
        exit(RandTextWithSpecificChars('0123456789', false, Length));
    end;

    procedure RandTextWithoutNumbers(): Text
    begin
        exit(RandTextWithoutNumbers(LibraryRandom.RandIntInRange(5, 10)));
    end;

    procedure RandTextWithoutNumbers(Length: Integer): Text
    begin
        exit(RandTextWithSpecificChars('abcdefghijklmnopqrstuvwxyz', Length));
    end;

    procedure RandTextWithSpecificChars(AllowedChars: Text): Text
    begin
        exit(RandTextWithSpecificChars(AllowedChars, LibraryRandom.RandIntInRange(5, 10)));
    end;

    procedure RandTextWithSpecificChars(AllowedChars: Text; Length: Integer): Text
    begin
        exit(RandTextWithSpecificChars(AllowedChars, true, Length));
    end;

    procedure RandTextWithSpecificChars(AllowedChars: Text; CaseSensitive: Boolean; Length: Integer): Text
    var
        FinalTxt, NewChar : Text;
    begin
        FinalTxt := '';
        while StrLen(FinalTxt) < Length do begin
            NewChar := AllowedChars.Substring(LibraryRandom.RandInt(StrLen(AllowedChars)), 1);
            if not CaseSensitive then begin
                NewChar := NewChar.ToLower();
                if RandBoolean() then
                    NewChar := NewChar.ToUpper();
            end;
            FinalTxt += NewChar;
        end;
        exit(FinalTxt);
    end;

    procedure RandBoolean(): Boolean
    begin
        if LibraryRandom.RandIntInRange(0, 1) = 1 then
            exit(true);
        exit(false);
    end;

    procedure GetDefaultLibrary(): Codeunit "Library - Random"
    begin
    end;

    procedure Init(): Integer
    begin
        exit(LibraryRandom.Init());
    end;

    procedure SetSeed(Val: Integer): Integer
    begin
        exit(LibraryRandom.SetSeed(Val));
    end;
}