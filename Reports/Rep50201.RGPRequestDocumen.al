report 50214 "RGP Request Document"
{
    Caption = 'RGP Request Document';
    DefaultLayout = RDLC;
    RDLCLayout = './RequestDocument/Layouts/RGPRequestDocument.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Header; "RGP Request Header")
        {
            RequestFilterFields = "Request No.", Status;
           
            column(RequestNo; "Request No.") { }
            column(RequestDate; "Request Date") { }
            column(Type; Type) { }
            column(RequestedBy; "Requested By") { }
            column(ShortcutDimension1Code; "Shortcut Dimension 1 Code") { }
            column(ShortcutDimension2Code; "Shortcut Dimension 2 Code") { }
            column(ExpectedDate; "Expected Date") { }
            column(ApprovalStatus; "Approval Status") { }

            column(Name; CompanyInfo.Name) { }
            column(Logo; CompanyInfo.Picture) { }
            column(E_Mail; CompanyInfo."E-Mail") { }
            column(City; CompanyInfo.City) { }
            column(Address; CompanyInfo.Address) { }
            column(Phone_No_; CompanyInfo."Phone No.") { }
            column(Domain; CompanyInfo."Address 2") { }
            column(VAT_Reg; CompanyInfo."VAT Registration No.") { }
            column(Bank_Name; CompanyInfo."Bank Name") { }
            column(TIN; CompanyInfo."Registration No.") { }

            dataitem(ItemLines; "RGP Request Item Line")
            {
                DataItemLink = "Request No." = field("Request No.");
                DataItemTableView = sorting("Request No.", "Line No.");

                column(ItemLineNo; "Line No.") { }
                column(ItemNo; "No.") { }
                column(ItemDescription; Description) { }
                column(ItemLocationCode; "Location Code") { }
                column(ItemUnitofMeasureCode; "Unit of Measure Code") { }
                column(ItemUnitPrice; "Unit Price") { }
                column(ItemQuantity; Quantity) { }
                column(ItemComments; Comments) { }
            }

            dataitem(VendorLines; "RGP Request Vendor Line")
            {
                DataItemLink = "Request No." = field("Request No.");
                DataItemTableView = sorting("Request No.", "Line No.");

                column(VendorLineNo; "Line No.") { }
                column(VendorNo; "Vendor No.") { }
                column(VendorName; "Vendor Name") { }
                column(VendorAddress; Address) { }
                column(VendorPostCode; "Post Code") { }
                column(VendorCity; City) { }
                column(VendorPhoneNo; "Phone No.") { }
                column(VendorEmail; Email) { }
                column(VendorContactPerson; "Contact Person") { }
                column(VendorAccepted; Accepted) { }
                column(VendorComments; Comments) { }
            }

            trigger OnPreDataItem()
            begin
                CompanyInfo.Get();
                CompanyInfo.CalcFields(Picture);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field(ShowDetails; ShowDetails)
                    {
                        ApplicationArea = All;
                        Caption = 'Show Detailed Information';
                        ToolTip = 'Specifies if detailed item and vendor information should be shown.';
                    }
                }
            }
        }
    }

    var
        CompanyInfo: Record "Company Information";
        ShowDetails: Boolean;

    procedure InitializeRequest(RequestNo: Code[20])
    var
        RGPRequestHeader: Record "RGP Request Header";
    begin
        if RGPRequestHeader.Get(RequestNo) then
            Header.SetRange("Request No.", RequestNo);
    end;
}