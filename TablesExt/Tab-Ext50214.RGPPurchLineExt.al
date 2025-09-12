namespace BCEXPERTROAD.BCEXPERTROAD;

using Microsoft.Purchases.Document;

tableextension 50214 RGPPurchLineExt extends "Purchase Line"
{
    fields
    {
        field(50214; "Request No."; Code[20])
        {
            Caption = 'Request No.';
            DataClassification = ToBeClassified;
        }
        field(50215; "Requested By"; Code[50])
        {
            Caption = 'Requested By';
            DataClassification = ToBeClassified;
        }
        field(50216; "Request Date"; Date)
        {
            Caption = 'Request Date';
            DataClassification = ToBeClassified;
        }
        field(50217; "Requested Quantity"; Decimal)
        {
            Caption = 'Requested Quantity';
            DataClassification = ToBeClassified;
        }
    }
}


