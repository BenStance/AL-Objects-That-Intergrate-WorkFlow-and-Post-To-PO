pageextension 50210 "RGP Business Manager RC Ext" extends "Business Manager Role Center"
{
    actions
    {
        addlast(embedding)
        {
            action("RDP Requests")
            {
                ApplicationArea = All;
                Caption = 'RDP Requests';
                RunObject = Page "RGP Request List";
                ToolTip = 'View and manage material requests (Purchase or Transfer).';
                Image = Document;
            }
        }
    }
}