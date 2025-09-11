table 50212 "RGP Request Vendor Line"
{
    Caption = 'RGP Request Vendor Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Request No."; Code[20])
        {
            Caption = 'Request No.';
            TableRelation = "RGP Request Header"."Request No.";
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                if "Vendor No." <> xRec."Vendor No." then begin
                    // Clear all vendor-related fields when vendor changes
                    ClearVendorFields();

                    if Vendor.Get("Vendor No.") then
                        UpdateVendorFields(Vendor);
                end;
            end;
        }
        field(4; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = field("Vendor No.")));
            Editable = false;
        }
        field(5; Address; Text[100])
        {
            Caption = 'Address';
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Address where("No." = field("Vendor No.")));
            Editable = false;
        }
        field(6; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor."Address 2" where("No." = field("Vendor No.")));
            Editable = false;
        }
        field(7; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor."Post Code" where("No." = field("Vendor No.")));
            Editable = false;
        }
        field(8; City; Text[30])
        {
            Caption = 'City';
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.City where("No." = field("Vendor No.")));
            Editable = false;
        }
        field(9; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor."Country/Region Code" where("No." = field("Vendor No.")));
            Editable = false;
        }
        field(10; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor."Phone No." where("No." = field("Vendor No.")));
            Editable = false;
        }
        field(11; "Email"; Text[80])
        {
            Caption = 'Email';
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor."E-Mail" where("No." = field("Vendor No.")));
            Editable = false;
        }
        field(12; "Contact Person"; Text[100])
        {
            Caption = 'Contact Person';
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Contact where("No." = field("Vendor No.")));
            Editable = false;
        }
        field(13; "Vendor Rating"; Option)
        {
            Caption = 'Vendor Rating';
            OptionMembers = " ","A","B","C","D";
            OptionCaption = ' ,A,B,C,D';
            DataClassification = CustomerContent;
        }
        field(14; "Quoted Amount"; Decimal)
        {
            Caption = 'Quoted Amount';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(15; "Accepted"; Boolean)
        {
            Caption = 'Accepted';
            DataClassification = CustomerContent;

            
        }
        field(16; "Acceptance Date"; Date)
        {
            Caption = 'Acceptance Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(17; "Acceptance Time"; Time)
        {
            Caption = 'Acceptance Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18; "Accepted By"; Code[50])
        {
            Caption = 'Accepted By';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(19; Comments; Text[250])
        {
            Caption = 'Comments';
            DataClassification = CustomerContent;
        }
        field(20; "Purchase Order No."; Code[20])
        {
            Caption = 'Purchase Order No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Purchase Header"."No." where("Document Type" = const(Order));
        }
        field(21; "Purchase Quote No."; Code[20]) 
        {
            Caption = 'Purchase Quote No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Purchase Header"."No." where("Document Type" = const(Quote)); // Changed to Quote
        }
    }

    keys
    {
        key(PK; "Request No.", "Line No.")
        {
            Clustered = true;
        }
        key(Vendor; "Request No.", "Vendor No.")
        {
            Unique = true;
        }
        key(Accepted; "Request No.", Accepted)
        {
        }
    }

    trigger OnInsert()
    var
        RGPRequestVendorLine: Record "RGP Request Vendor Line";
    begin
        if "Line No." = 0 then begin
            RGPRequestVendorLine.SetRange("Request No.", "Request No.");
            if RGPRequestVendorLine.FindLast() then
                "Line No." := RGPRequestVendorLine."Line No." + 10000
            else
                "Line No." := 10000;
        end;
    end;

    trigger OnModify()
    begin
        if Accepted and (xRec.Accepted <> Accepted) then begin
            "Acceptance Date" := Today();
            "Acceptance Time" := Time();
            "Accepted By" := UserId();
        end
        else if not Accepted then begin
            Clear("Acceptance Date");
            Clear("Acceptance Time");
            Clear("Accepted By");
        end;
    end;

    local procedure ClearVendorFields()
    begin
        Clear("Vendor Rating");
        Clear("Quoted Amount");
        Clear(Comments);
        // Note: FlowFields are automatically cleared when Vendor No. changes
    end;

    local procedure UpdateVendorFields(Vendor: Record Vendor)
    begin
        // You can set default values based on vendor here if needed
        // For example, set default rating or other vendor-specific defaults
    end;

    procedure IsVendorAccepted(RequestNo: Code[20]): Boolean
    var
        RGPRequestVendorLine: Record "RGP Request Vendor Line";
    begin
        RGPRequestVendorLine.Reset();
        RGPRequestVendorLine.SetRange("Request No.", RequestNo);
        RGPRequestVendorLine.SetRange(Accepted, true);
        exit(RGPRequestVendorLine.FindFirst());
    end;

    procedure GetAcceptedVendor(RequestNo: Code[20]): Code[20]
    var
        RGPRequestVendorLine: Record "RGP Request Vendor Line";
    begin
        RGPRequestVendorLine.Reset();
        RGPRequestVendorLine.SetRange("Request No.", RequestNo);
        RGPRequestVendorLine.SetRange(Accepted, true);
        if RGPRequestVendorLine.FindFirst() then
            exit(RGPRequestVendorLine."Vendor No.");

        exit('');
    end;
}