namespace BCEXPERTROAD.BCEXPERTROAD;

using Microsoft.Purchases.Document;

tableextension 50211 RGPExtPurchaseLine extends "Purchase Line"
{
    fields
    {
        field(50211; "RGP Request No."; Code[20])
        {
            Caption = 'RGP Request No.';
            DataClassification = CustomerContent;
            TableRelation = "RGP Request Header"."Request No.";
        }
        
    }
}
