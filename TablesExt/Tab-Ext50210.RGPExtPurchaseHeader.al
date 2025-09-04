namespace BCEXPERTROAD.BCEXPERTROAD;

using Microsoft.Purchases.Document;

tableextension 50210 RGPExtPurchaseHeader extends "Purchase Header"
{
    fields
    {

        field(50210; "RGP Request No."; Code[20])
        {
            Caption = 'RGP Request No.';
            DataClassification = CustomerContent;
            TableRelation = "RGP Request Header"."Request No.";
        }

    }
}
