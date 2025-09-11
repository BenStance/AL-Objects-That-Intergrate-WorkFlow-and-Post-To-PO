namespace BCEXPERTROAD.BCEXPERTROAD;
using System.Automation;

page 50213 RGPRequestDocument
{
    Caption = 'RGP Request Document';
    PageType = Document;
    SourceTable = "RGP Request Header";
    ApplicationArea = All;
    UsageCategory = Documents;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Request No."; Rec."Request No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the request.';
                    Editable = IsEditable;
                }
                field("Request Date"; Rec."Request Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date of the request.';
                    Editable = IsEditable;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of request (Purchase or Transfer).';
                    Editable = IsEditable;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of the request.';
                    Editable = false;
                }
                field("Requested By"; Rec."Requested By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who requested this document.';
                    Editable = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the dimension value code for Shortcut Dimension 1.';
                    Editable = IsEditable;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the dimension value code for Shortcut Dimension 2.';
                    Editable = IsEditable;
                }
                field(Comments; Rec.Comments)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies any comments for this request.';
                    Editable = IsEditable;
                }
                field("Expected Date"; Rec."Expected Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the expected date for this request.';
                    Editable = IsEditable;
                }
            }
            part(ItemSubform; "RGP Request Item Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Request No." = field("Request No.");
                Editable = IsEditable;
            }
            part(VendorsSubform; "RGP Request Vendor Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Request No." = field("Request No.");
                Editable = IsEditable;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group("Document Actions")
            {
                Caption = 'Document Actions';
                Image = Document;

                action(Release)
                {
                    ApplicationArea = All;
                    Caption = 'Release';
                    ToolTip = 'Release the document to Pending status.';
                    Image = ReleaseDoc;
                    Enabled = IsEditable and not IsWorkflowEnabled;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        if Confirm('Are you sure you want to release this request?') then begin
                            Rec.TestField(Status, Rec.Status::Open);
                            Rec.Status := Rec.Status::Pending;
                            Rec.Modify(true);
                            Message('Request %1 has been released and is now Pending approval.', Rec."Request No.");
                        end;
                    end;
                }

                action(Reopen)
                {
                    ApplicationArea = All;
                    Caption = 'Reopen';
                    ToolTip = 'Reopen the document to Open status.';
                    Image = ReOpen;
                    Enabled = IsEditable and not IsWorkflowEnabled;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        if Confirm('Are you sure you want to reopen this request?') then begin
                            Rec.TestField(Status, Rec.Status::Pending);
                            Rec.Status := Rec.Status::Open;
                            Rec.Modify(true);
                            Message('Request %1 has been reopened.', Rec."Request No.");
                        end;
                    end;
                }
                action(Approvals)
                {
                    ApplicationArea = All;
                    Caption = 'Approvals';
                    Image = Approvals;
                    ToolTip = 'View approval requests.';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    // Visible = HasApprovalEntries;

                    trigger OnAction()
                    begin
                        ApprovalsMgmt.OpenApprovalEntriesPage(Rec.RecordId);
                    end;
                }



                group("Approval")
                {
                    Caption = 'Approval';
                    Image = Approval;

                    action(SendApprovalRequest)
                    {
                        ApplicationArea = All;
                        Caption = 'Send Approval Request';
                        Image = SendApprovalRequest;
                        ToolTip = 'Request approval of the document.';
                        Promoted = true;
                        PromotedCategory = Process;
                        PromotedIsBig = true;

                        trigger OnAction()
                        var
                            CustomWorkflowMgmt: Codeunit "RGP Custom Workflow Mgmt";
                            RecRef: RecordRef;
                        begin
                            RecRef.GetTable(Rec);
                            if CustomWorkflowMgmt.CheckRGPRequestApprovalsWorkflowEnable(Rec) then
                                CustomWorkflowMgmt.OnSendRGPRequestForApproval(Rec);
                        end;
                    }

                    action(CancelApprovalRequest)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Cancel Approval Request';
                        Enabled = CanCancelApprovalForRecord;
                        Image = CancelApprovalRequest;
                        ToolTip = 'Cancel the approval request.';
                        Promoted = true;
                        PromotedCategory = Process;

                        trigger OnAction()
                        var
                            CustomWorkflowMgmt: Codeunit "RGP Custom Workflow Mgmt";
                            RecRef: RecordRef;
                        begin
                            RecRef.GetTable(Rec);
                            CustomWorkflowMgmt.OnCancelRGPRequestForApproval(Rec);
                        end;
                    }


                    action("Convert to Purchase Quote")
                    {
                        ApplicationArea = All;
                        Caption = 'Convert to Purchase Quote';
                        ToolTip = 'Create a purchase quote from this request for the accepted vendor.';
                        Image = Quote;
                        Enabled = EnableConvertToQuote;
                        Promoted = true;
                        PromotedCategory = Process;
                        PromotedIsBig = true;

                        trigger OnAction()
                        var
                            RGPRequestToPurchaseQuote: Codeunit "RGP Req to Purch Quote(Yes/No)"; // New codeunit
                        begin
                            RGPRequestToPurchaseQuote.Run(Rec);
                        end;
                    }
                    action(Comment)
                    {
                        ApplicationArea = All;
                        Caption = 'Comments';
                        Image = ViewComments;
                        ToolTip = 'View or add comments for the record.';
                        Promoted = true;
                        PromotedCategory = Category5;
                        Visible = OpenApprovalEntriesExistCurrUser;

                        trigger OnAction()
                        begin
                            ApprovalsMgmt.GetApprovalComment(Rec);
                        end;
                    }

                }
            }


        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        SetEditable();
        OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        HasApprovalEntries := ApprovalsMgmt.HasApprovalEntries(Rec.RecordId);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetEditable();
    end;

    trigger OnOpenPage()
    begin
        SetEditable();
    end;

    trigger OnAfterGetRecord()
    begin
        SetEditable();
    end;


    local procedure SetEditable()
    var
        WorkflowManagement: Codeunit "Workflow Management";
    begin
        IsEditable := Rec.Status = Rec.Status::Open;
        EnableConvertToQuote := (Rec.Status = Rec.Status::Approved);
        IsWorkflowEnabled := WorkflowManagement.CanExecuteWorkflow(Rec, RGPCustomWorkflowMgmt.RunWorkflowOnSendRGPRequestForApprovalCode());
    end;

    var
        IsEditable: Boolean;

        IsWorkflowEnabled: Boolean;
        RGPCustomWorkflowMgmt: Codeunit "RGP Custom Workflow Mgmt";
        OpenApprovalEntriesExistCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        HasApprovalEntries: Boolean;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        EnableConvertToQuote: Boolean;
}