table 50101 "EMEA Data Exch. Usage Version"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Usage Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            TableRelation = "EMEA Data Exchange Usage".Code;
            DataClassification = CustomerContent;
        }
        field(2; "No."; Integer)
        {
            Caption = 'No.';
            NotBlank = true;
            InitValue = 1;
            MinValue = 1;
            DataClassification = SystemMetadata;
        }
        field(5; "Data Exch. Def. Code"; Code[20])
        {
            Caption = 'Data Exchange Definition Code';
            TableRelation = "Data Exch. Def".Code;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Usage Code", "No.")
        {
            Clustered = true;
        }
    }

}