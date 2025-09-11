table 50210 "RGP Request Header"
{
    Caption = 'RGP Request Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Request No."; Code[20])
        {
            Caption = 'Request No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Request No." <> xRec."Request No." then begin
                    PurchasesPayablesSetup.Get();
                    NoSeriesMgt.TestManual(PurchasesPayablesSetup."RFQ2");
                    "Request No." := '';
                end;
            end;
        }
        field(2; "Request Date"; Date)
        {
            Caption = 'Request Date';
            DataClassification = CustomerContent;
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            OptionMembers = Purchase,Transfer;
            OptionCaption = 'Purchase,Transfer';
            DataClassification = CustomerContent;
        }
        field(4; Status; Enum "RGPStatusenum")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Requested By"; Code[50])
        {
            Caption = 'Requested By';
            DataClassification = CustomerContent;
            Editable=false;
            
            
        }
        field(6; "Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 1 Code';
           CaptionClass = '1,2,1';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1), Blocked = const(false));

        }
        field(7; "Shortcut Dimension 2 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 2 Code';
            CaptionClass = '1,2,2';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2), Blocked = const(false));

        }
        field(8; Comments; Text[250])
        {
            Caption = 'Comments';
            DataClassification = CustomerContent;
        }
        field(9; "Expected Date"; Date)
        {
            Caption = 'Expected Date';
            DataClassification = CustomerContent;
        }
        field(10; "No.Series"; Code[20])
        {
            Description = 'No Series';
        }
        // Change the field name and/or TableRelation
        field(11; "Purchase Order No."; Code[20]) // Renamed for clarity
        {
            Caption = 'Purchase Quote No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Purchase Header"."No." where("Document Type" = const(Order)); 
        }
        field(12; "Purchase Quote No."; Code[20]) // Renamed for clarity
        {
            Caption = 'Purchase Quote No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Purchase Header"."No." where("Document Type" = const(Quote)); // Changed to Quote
        }
        field(13; "Approval Status"; Option)
        {
            Caption = 'Approval Status';
            OptionMembers = Open,"Pending Approval",Approved,Rejected;
            OptionCaption = 'Open,Pending Approval,Approved,Rejected';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Request No.")
        {
            Clustered = true;
        }
    }

    var
        StatusChanged: Boolean;


    trigger OnInsert()
    var
        userSetup: Record "User Setup";
    begin
        if "Request No." = '' then begin
            PurchasesPayablesSetup.Get();
            PurchasesPayablesSetup.TestField("RFQ");
            "No.Series" := PurchasesPayablesSetup."RFQ";
            "Request No." := NoSeriesMgt.GetNextNo("No.Series", Today(), true);
            "Request Date" := Today();
            Status := Status::Open;
        end;

        if userSetup.Get(UserId()) then
            "Requested By" := userSetup."User ID";        

    end;


    var
        NoSeriesMgt: Codeunit "No. Series";

        PurchasesPayablesSetup: Record "Purchases & Payables Setup";

    procedure GetNoSeriesRelCode(NoSeriesCode: Code[20]): Code[10]
    var

        NoSrsRel: Record "No. Series Relationship";
    begin
        exit(GetNoSeriesRelCode(NoSeriesCode));


    end;


    trigger OnModify()
    begin
        if xRec.Status <> Rec.Status then
            StatusChanged := true;

        if StatusChanged then begin
            StatusChanged := false;
        end;
    end;

}