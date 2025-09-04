page 50211 "RGP Request Vendor Subform"
{
    Caption = 'RGP Request Vendor Subform';
    PageType = ListPart;
    SourceTable = "RGP Request Vendor Line";
    SourceTableView = sorting("Request No.", "Line No.");
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor number.';
                    Editable = IsEditable;
                    ShowMandatory = true;
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor name.';
                    Editable = false;
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor address.';
                    Editable = false;
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the post code.';
                    Editable = false;
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the city.';
                    Editable = false;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the phone number.';
                    Editable = false;
                }
                field("Email"; Rec."Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the email address.';
                    Editable = false;
                }
                field("Contact Person"; Rec."Contact Person")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the contact person.';
                    Editable = false;
                }
                
                field(Accepted; Rec.Accepted)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the vendor has accepted the request. Only one vendor can be accepted per request.';
                    Editable = IsEditable;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Comments; Rec.Comments)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies any comments regarding this vendor.';
                    Editable = IsEditable;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(OpenVendorCard)
            {
                ApplicationArea = All;
                Caption = 'Open Vendor Card';
                ToolTip = 'Open the vendor card for the selected vendor.';
                Image = Vendor;
                

                trigger OnAction()
                var
                    Vendor: Record Vendor;
                begin
                    if Rec."Vendor No." = '' then
                        exit;

                    Vendor.Get(Rec."Vendor No.");
                    Page.Run(Page::"Vendor Card", Vendor);
                end;
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

    trigger OnOpenPage()
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
            IsEditable := false;
    end;

    var
        IsEditable: Boolean;
}