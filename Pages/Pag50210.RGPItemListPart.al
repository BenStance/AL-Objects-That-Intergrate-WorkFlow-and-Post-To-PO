page 50210 "RGP Request Item Subform"
{
    Caption = 'RGP Request Subform';
    PageType = ListPart;
    SourceTable = "RGP Request Item Line";
    SourceTableView = sorting("Request No.", "Line No.");

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Type;Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of line (G/L Account, Item, or Fixed Asset).';
                    Editable = IsEditable;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the G/L Account, Item, or Fixed Asset.';
                    Editable = IsEditable;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the item.';
                    Editable = IsEditable;
                }
                
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit of measure code.';
                    Editable = false;
                }
                 field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity requested.';
                    Editable = IsEditable;
                }
                 field("VAT %"; Rec."VAT %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the VAT percentage.';
                    Editable = IsEditable;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit price.';
                    Editable = IsEditable;
                }
               
                field("Total Amount Excl. VAT";Rec."Total Amount Excl. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total amount excluding VAT.';
                    Editable = false;
                }
                field("VAT Amount";Rec."VAT Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the VAT amount.';
                    Editable = false;
                }
                field("Total Amount Incl. VAT";Rec."Total Amount Incl. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total amount including VAT.';
                    Editable = false;
                }
                
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetEditable();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetEditable();
    end;

    local procedure SetEditable()
    var
        RGPRequestHeader: Record "RGP Request Header";
    begin
        if RGPRequestHeader.Get(Rec."Request No.") then
            IsEditable := RGPRequestHeader.Status = RGPRequestHeader.Status::Open
        else
            IsEditable := true;
    end;

    var
        IsEditable: Boolean;
}