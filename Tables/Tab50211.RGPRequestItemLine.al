table 50211 "RGP Request Item Line"
{
    Caption = 'RGP Request Item Line';
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
        field(3; "Type"; Enum RGPLineTypesenum)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        
        field(4; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = 
                if (Type = const(Item)) Item."No."
                else if (Type = const("Fixed Asset")) "Fixed Asset"."No."
                else if (Type = const("G/L Account")) "G/L Account"."No.";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Item: Record Item;
                FixedAsset: Record "Fixed Asset";
                GLAccount: Record "G/L Account";
            begin
                Description := '';
                "Unit of Measure Code" := '';
                "Unit Price" := 0;
                
                case Type of
                    Type::Item:
                        if Item.Get("No.") then begin
                            Description := Item.Description;
                            "Unit of Measure Code" := Item."Base Unit of Measure";
                            "Unit Price" := Item."Unit Price";
                        end;
                    Type::"Fixed Asset":
                        if FixedAsset.Get("No.") then begin
                            Description := FixedAsset.Description;
                        end;
                    Type::"G/L Account":
                        if GLAccount.Get("No.") then begin
                            Description := GLAccount.Name;
                            "Direct Posting" := GLAccount."Direct Posting";
                        end;
                end;
                
                UpdateLineAmounts();
            end;
        }
        
        field(5; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        
        field(6; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location.Code;
            DataClassification = CustomerContent;        
        }
        
        field(7; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = 
                if (Type = const(Item)) "Item Unit of Measure".Code where("Item No." = field("No."))
                else "Unit of Measure".Code;
            DataClassification = CustomerContent;
            
            trigger OnValidate()
            begin
                UpdateLineAmounts();
            end;
        }
        
        field(8; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
            MinValue = 0;
            
            trigger OnValidate()
            begin
                UpdateLineAmounts();
            end;
        }
        
        field(9; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;
            
            trigger OnValidate()
            begin
                UpdateLineAmounts();
            end;
        }
        
        field(10; "Total Amount Excl. VAT"; Decimal)
        {
            Caption = 'Total Amount Excl. VAT';
            DataClassification = CustomerContent;
            Editable = false;
        }
        
        field(11; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 100;
            
            trigger OnValidate()
            begin
                UpdateLineAmounts();
            end;
        }
        
        field(12; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        
        field(13; "Total Amount Incl. VAT"; Decimal)
        {
            Caption = 'Total Amount Incl. VAT';
            DataClassification = CustomerContent;
            Editable = false;
        }
        
        field(14; "Direct Posting"; Boolean)
        {
            Caption = 'Direct Posting';
            DataClassification = CustomerContent;
            Editable = false;
        }
        
        field(15; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
            DataClassification = CustomerContent;
            
            trigger OnValidate()
            var
                VATPostingSetup: Record "VAT Posting Setup";
            begin
                if "VAT Prod. Posting Group" <> '' then begin
                    VATPostingSetup.Get('', "VAT Prod. Posting Group");
                    "VAT %" := VATPostingSetup."VAT %";
                end else begin
                    "VAT %" := 0;
                end;
                
                UpdateLineAmounts();
            end;
        }
        field(16; "Comments";Text[250])
        {
            Caption = 'Comments';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Request No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        RGPRequestLine: Record "RGP Request Item Line";
    begin
        if "Line No." = 0 then begin
            RGPRequestLine.SetRange("Request No.", "Request No.");
            if RGPRequestLine.FindLast() then
                "Line No." := RGPRequestLine."Line No." + 10000
            else
                "Line No." := 10000;
        end;
        
        // Set default VAT % if not specified
        if "VAT %" = 0 then
            "VAT %" := GetDefaultVATPercentage();
    end;

    trigger OnModify()
    begin
        UpdateLineAmounts();
    end;

    local procedure UpdateLineAmounts()
    begin
        // Calculate total amount excluding VAT
        "Total Amount Excl. VAT" := Quantity * "Unit Price";
        
        // Calculate VAT amount
        "VAT Amount" := "Total Amount Excl. VAT" * "VAT %" / 100;
        
        // Calculate total amount including VAT
        "Total Amount Incl. VAT" := "Total Amount Excl. VAT" + "VAT Amount";
    end;

    local procedure GetDefaultVATPercentage(): Decimal
var
    Item: Record Item;
    VATPostingSetup: Record "VAT Posting Setup";
begin
    // Check if the current line is of type Item and has a valid item number
    if (Type = Type::Item) and ("No." <> '') then begin
        // Attempt to retrieve the item record
        if Item.Get("No.") then begin
            // Try to get the VAT percentage from the item's VAT Posting Group
            if VATPostingSetup.Get('', Item."VAT Prod. Posting Group") then
                exit(VATPostingSetup."VAT %");
        end;
    end;

    // Fallback: Retrieve the first available VAT percentage if no specific VAT is found
    VATPostingSetup.Reset();
    // Removed SetRange for "Unrealized VAT Type" as the field does not exist
    VATPostingSetup.SetFilter("VAT %", '<>0');
    if VATPostingSetup.FindFirst() then
        exit(VATPostingSetup."VAT %");

    // Return 0 if no VAT percentage is found
    exit(0);
end;

}