namespace BCEXPERTROAD.BCEXPERTROAD;

using Microsoft.Purchases.Document;

pageextension 50214 RGPPurchaseQuoteSubformExt extends "Purchase Quote Subform"
{
    layout
    {
        addafter("Shortcut Dimension 2 Code")
        {
            field("Request No."; Rec."RGP Request No.")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Req Quantity";Rec."Requested Quantity")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Requested By"; Rec."Requested By")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Request Date"; Rec."Request Date")
            {
                ApplicationArea = All;
                Editable = false; 
            }
        }
    }
}
