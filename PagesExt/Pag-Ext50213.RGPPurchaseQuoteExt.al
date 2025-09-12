namespace BCEXPERTROAD.BCEXPERTROAD;

using Microsoft.Purchases.Document;

pageextension 50213 RGPPurchaseQuoteExt extends "Purchase Quote"
{
    layout
    {
        addlast(General)
        {
            field("Request No."; Rec."RGP Request No.")
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

