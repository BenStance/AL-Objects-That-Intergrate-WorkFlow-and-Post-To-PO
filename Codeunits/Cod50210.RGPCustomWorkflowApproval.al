codeunit 50210 "RGP Custom Workflow Mgmt"
{
    procedure CheckApprovalsWorkflowEnabled(var RecRef: RecordRef): Boolean
    begin
        if not WorkflowMgt.CanExecuteWorkflow(RecRef, GetWorkflowCode(RUNWORKFLOWONSENDFORAPPROVALCODE, RecRef)) then
            Error(NoWorkflowEnabledErr);
        exit(true);
    end;

    procedure GetWorkflowCode(WorkflowCode: code[128]; RecRef: RecordRef): Code[128]
    begin
        // Ensure the event name matches the format used in AddEventToLibrary and the workflow XML
        exit(StrSubstNo(WorkflowCode, RecRef.Name));
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendWorkflowForApproval(var RecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelWorkflowForApproval(var RecRef: RecordRef)
    begin
    end;

    // Add events to the library
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure OnAddWorkflowEventsToLibrary()
    var
        RecRef: RecordRef;
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin
        RecRef.Open(Database::"RGP Request Header");
        // The event name will be RUNWORKFLOWONSENDRGPREQUESTHEADERFORAPPROVAL and RUNWORKFLOWONCANCELRGPREQUESTHEADERFORAPPROVAL
        WorkflowEventHandling.AddEventToLibrary(
            'RUNWORKFLOWONSENDRGPREQUESTHEADERFORAPPROVAL',
            Database::"RGP Request Header",
            GetWorkflowEventDesc(WorkflowSendForApprovalEventDescTxt, RecRef), 0, false);
        WorkflowEventHandling.AddEventToLibrary(
            'RUNWORKFLOWONCANCELRGPREQUESTHEADERFORAPPROVAL',
            Database::"RGP Request Header",
            GetWorkflowEventDesc(WorkflowCancelForApprovalEventDescTxt, RecRef), 0, false);
    end;

    // subscribe
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"RGP Custom Workflow Mgmt", 'OnSendWorkflowForApproval', '', false, false)]
    local procedure RunWorkflowOnSendWorkflowForApproval(var RecRef: RecordRef)
    begin
        WorkflowMgt.HandleEvent('RUNWORKFLOWONSENDRGPREQUESTHEADERFORAPPROVAL', RecRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"RGP Custom Workflow Mgmt", 'OnCancelWorkflowForApproval', '', false, false)]
    local procedure RunWorkflowOnCancelWorkflowForApproval(var RecRef: RecordRef)
    begin
        WorkflowMgt.HandleEvent('RUNWORKFLOWONCANCELRGPREQUESTHEADERFORAPPROVAL', RecRef);
    end;

    procedure GetWorkflowEventDesc(WorkflowEventDesc: Text; RecRef: RecordRef): Text
    begin
        exit(StrSubstNo(WorkflowEventDesc, RecRef.Name));
    end;

    // handle the document
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    local procedure OnOpenDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        RGPRequestHeader: Record "RGP Request Header";
    begin
        case RecRef.Number of
            Database::"RGP Request Header":
                begin
                    RecRef.SetTable(RGPRequestHeader);
                    RGPRequestHeader.Validate(Status, RGPRequestHeader.Status::Open);
                    RGPRequestHeader.Modify(true);
                    Handled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    local procedure OnSetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        RGPRequestHeader: Record "RGP Request Header";
    begin
        case RecRef.Number of
            Database::"RGP Request Header":
                begin
                    RecRef.SetTable(RGPRequestHeader);
                    RGPRequestHeader.Validate(Status, RGPRequestHeader.Status::Pending);
                    RGPRequestHeader.Modify(true);
                    Variant := RGPRequestHeader;
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
    local procedure OnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        RGPRequestHeader: Record "RGP Request Header";
    begin
        case RecRef.Number of
            Database::"RGP Request Header":
                begin
                    RecRef.SetTable(RGPRequestHeader);
                    ApprovalEntryArgument."Document No." := RGPRequestHeader."Request No.";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    local procedure OnReleaseDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        RGPRequestHeader: Record "RGP Request Header";
    begin
        case RecRef.Number of
            Database::"RGP Request Header":
                begin
                    RecRef.SetTable(RGPRequestHeader);
                    RGPRequestHeader.Validate(Status, RGPRequestHeader.Status::Approved);
                    RGPRequestHeader.Modify(true);
                    Handled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnRejectApprovalRequest', '', false, false)]
    local procedure OnRejectApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        RGPRequestHeader: Record "RGP Request Header";
    begin
        case ApprovalEntry."Table ID" of
            Database::"RGP Request Header":
                begin
                    if RGPRequestHeader.Get(ApprovalEntry."Document No.") then begin
                        RGPRequestHeader.Validate(Status, RGPRequestHeader.Status::Open); // Changed from Rejected to Open
                        RGPRequestHeader.Modify(true);
                    end;
                end;
        end;
    end;

    var
        WorkflowMgt: Codeunit "Workflow Management";
        RUNWORKFLOWONSENDFORAPPROVALCODE: Label 'RUNWORKFLOWONSEND%1FORAPPROVAL';
        RUNWORKFLOWONCANCELFORAPPROVALCODE: Label 'RUNWORKFLOWONCANCEL%1FORAPPROVAL';
        NoWorkflowEnabledErr: Label 'No approval workflow for this record type is enabled.';
        WorkflowSendForApprovalEventDescTxt: Label 'Approval of %1 is requested.';
        WorkflowCancelForApprovalEventDescTxt: Label 'Approval of %1 is canceled.';
}