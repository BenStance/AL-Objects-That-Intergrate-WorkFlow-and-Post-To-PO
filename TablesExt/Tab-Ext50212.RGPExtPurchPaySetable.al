namespace BCEXPERTROAD.BCEXPERTROAD;

using Microsoft.Purchases.Setup;
using Microsoft.Foundation.NoSeries;

tableextension 50212 RGPExtPurchPaySetable extends "Purchases & Payables Setup"
{
    fields
    {
        field(50212; RFQ2; Code[20])
        {
            Caption = 'RFQ2';
            DataClassification = ToBeClassified;
            TableRelation="No. Series";
           
           
        }
       
    }
}
