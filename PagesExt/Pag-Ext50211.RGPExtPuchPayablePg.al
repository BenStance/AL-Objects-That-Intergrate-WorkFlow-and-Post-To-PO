namespace BCEXPERTROAD.BCEXPERTROAD;

using Microsoft.Purchases.Setup;

pageextension 50211 RGPExtPuchPayablePg extends "Purchases & Payables Setup"
{
    layout
    {
        
     addbefore(RFQ)
        
        {        
        
            field(RFQ2;Rec.RFQ2)
            {
                ApplicationArea = All;
                
               
                Editable = true;
            }
               
              
        }
    }
}
