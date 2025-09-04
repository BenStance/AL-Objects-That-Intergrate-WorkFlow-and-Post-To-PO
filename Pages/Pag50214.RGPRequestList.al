namespace BCEXPERTROAD.BCEXPERTROAD;

page 50214 "RGP Request List"
{
    Caption = 'RGP Requests';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "RGP Request Header";
    CardPageId = RGPRequestDocument;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Requests)
            {
                field("Request No."; Rec."Request No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the request number.';
                }
                field("Request Date"; Rec."Request Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the request date.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of request (Purchase or Transfer).';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of the request.';
                }
                field("Requested By"; Rec."Requested By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who requested this document.';
                }
                field("Expected Date"; Rec."Expected Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the expected date for this request.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewRequest)
            {
                Caption = 'New Request';
                ApplicationArea = All;
                Image = NewDocument;
                Promoted = true;
                PromotedCategory = New;
                PromotedIsBig = true;
                ToolTip = 'Create a new RGP Request.';

                trigger OnAction()
                var
                    RGPRequestHeader: Record "RGP Request Header";
                    RGPRequestDocument: Page RGPRequestDocument;
                begin
                    RGPRequestHeader.Init();
                    RGPRequestHeader.Insert(true);
                    RGPRequestDocument.SetRecord(RGPRequestHeader);
                    RGPRequestDocument.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Shows requests from the last 30 days by default
        Rec.SetFilter("Request Date", '>=%1', WorkDate() - 30);
    end;
}