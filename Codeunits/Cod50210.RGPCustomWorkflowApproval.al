codeunit 50210 "RGP Custom Workflow Mgmt"
{
    //Rise events for workflow
    [IntegrationEvent(false, false)]
    procedure OnSendRGPRequestForApproval(var RGPRequestHeader: Record "RGP Request Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelRGPRequestForApproval(var RGPRequestHeader: Record "RGP Request Header")
    begin
    end;

    //Create events for WF
    procedure RunWorkflowOnSendRGPRequestForApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnSendRGPRequestForApproval'))
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"RGP Custom Workflow Mgmt", 'OnSendRGPRequestForApproval', '', true, true)]
    local procedure RunWorkflowOnSendRGPRequestForApproval(var RGPRequestHeader: Record "RGP Request Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendRGPRequestForApprovalCode, RGPRequestHeader);
    end;

    procedure RunWorkflowOnCancelRGPRequestApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelRGPRequestApproval'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"RGP Custom Workflow Mgmt", 'OnCancelRGPRequestForApproval', '', true, true)]
    local procedure RunWorkflowOnCancelRGPRequestApproval(var RGPRequestHeader: Record "RGP Request Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelRGPRequestApprovalCode, RGPRequestHeader);
    end;

    //Add events to library
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', true, true)]
    local procedure OnAddWorkflowEventsToLibrary()
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendRGPRequestForApprovalCode, Database::"RGP Request Header", 'The RGP Request approval request has been sent', 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelRGPRequestApprovalCode, Database::"RGP Request Header", 'The RGP Request approval request has been Cancelled', 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventPredecessorsToLibrary', '', true, true)]
    local procedure OnAddWorkflowEventPredecessorsToLibrary(EventFunctionName: Code[128])
    begin
        case EventFunctionName of
            RunWorkflowOnCancelRGPRequestApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelRGPRequestApprovalCode, RunWorkflowOnSendRGPRequestForApprovalCode);
            WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode:
                WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendRGPRequestForApprovalCode);
            WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode:
                WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendRGPRequestForApprovalCode);
            WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode:
                WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendRGPRequestForApprovalCode);
        end;
    end;

    //Check workflow
    procedure CheckRGPRequestApprovalsWorkflowEnable(var RGPRequestHeader: Record "RGP Request Header"): Boolean
    begin
        if Not WorkflowManagement.CanExecuteWorkflow(RGPRequestHeader, RunWorkflowOnSendRGPRequestForApprovalCode()) then
            Error(NoWorkflowEnabledTxt);
        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
    local procedure OnPopulateApprovalEntryArgument(var ApprovalEntryArgument: Record "Approval Entry"; var RecRef: RecordRef; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        RGPRequestHeader: Record "RGP Request Header";
    begin
        if RecRef.Number = database::"RGP Request Header" then begin
            RecRef.SetTable(RGPRequestHeader);
            ApprovalEntryArgument."Document No." := RGPRequestHeader."Request No.";
        end;
    end;
    //responses handled in workflowresponseEXT codeunit

    //add librabert
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', false, false)]
    local procedure OnAddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    var
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
    begin
        case ResponseFunctionName of
            WorkflowResponseHandling.SetStatusToPendingApprovalCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, RunWorkflowOnSendRGPRequestForApprovalCode());
            WorkflowResponseHandling.SendApprovalRequestForApprovalCode:
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, RunWorkflowOnSendRGPRequestForApprovalCode);
            WorkflowResponseHandling.CancelAllApprovalRequestsCode:
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, RunWorkflowOnCancelRGPRequestApprovalCode());
            WorkflowResponseHandling.OpenDocumentCode:
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, RunWorkflowOnCancelRGPRequestApprovalCode);
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", OnSetStatusToPendingApproval, '', false, false)]
    local procedure OnSetStatusToPendingApproval(var Variant: Variant; RecRef: RecordRef; var IsHandled: Boolean)
    var
        RGPHdr: Record "RGP Request Header";
    begin
        if RecRef.Number <> Database::"RGP Request Header" then
            exit;
        RecRef.SetTable(RGPHdr);
        RGPHdr.Validate(Status, RGPHdr.Status::Pending);
        RGPHdr.Modify(true);
        Variant := RGPHdr;
        IsHandled := true;
    end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", OnReleaseDocument, '', false, false)]
    local procedure OnReleaseDocument(RecRef: RecordRef;var Handled: Boolean)
    var
        RGPHdr: Record "RGP Request Header";
    begin
        if RecRef.Number <> Database::"RGP Request Header" then
            exit;
             RecRef.SetTable(RGPHdr);
        RGPHdr.Validate(Status, RGPHdr.Status::Approved);
        RGPHdr.Modify(true);
        Handled := true;
        // RecRef.SetTable(RGPHdr);

        
    end;
    
     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", OnOpenDocument, '', false, false)]
    local procedure OnOpenDocument(RecRef: RecordRef;var Handled: Boolean)
    var
        RGPHdr: Record "RGP Request Header";
    begin
        if RecRef.Number <> Database::"RGP Request Header" then
            exit;
             RecRef.SetTable(RGPHdr);
        RGPHdr.Validate(Status, RGPHdr.Status::Open);
        RGPHdr.Modify(true);
        Handled := true;
        // RecRef.SetTable(RGPHdr);

        
    end;










    //<< Create Template for RGP Request workflow
    procedure InsertRGPRequestWorkFlowTemplate()
    var
        AppEntry: Record "Approval Entry";
        workflow: Record Workflow;
    begin
        WorkFlowSetup.InsertTableRelation(Database::"RGP Request Header", 0, Database::"Approval Entry", AppEntry.FieldNo("Record ID to Approve"));
        WorkFlowSetup.InsertWorkflowTemplate(workflow, RGPRequestWFCodeTxt, RGPRequestWFDescTxt, RGPRequestCodeTxt);
        InsertRGPRequestWorkflowDetails(workflow);
        WorkFlowSetup.MarkWorkflowAsTemplate(workflow);
        Message('workflow template created');
    end;

    local procedure InsertRGPRequestWorkflowDetails(var workflow: Record Workflow)
    var

        WorkflowStepArgument: Record 1523;
        BlankDateFormula: DateFormula;
        WorkflowResponseHandling: Codeunit 1521;
        RGPRequestHeader: Record "RGP Request Header";
    Begin
        WorkflowSetup.InitWorkflowStepArgument(WorkflowStepArgument, WorkflowStepArgument."Approver Type"::Approver, WorkflowStepArgument."Approver Limit Type"::"Direct Approver",
        0, '', BlankDateFormula, TRUE);

        WorkflowSetup.InsertDocApprovalWorkflowSteps(Workflow,
        BuildRGPRequestTypeConditions(RGPRequestHeader.Status::Open),
        RunWorkflowOnSendRGPRequestForApprovalCode(),
        BuildRGPRequestTypeConditions(RGPRequestHeader.Status::Pending),
        RunWorkflowOnCancelRGPRequestApprovalCode(),
        WorkflowStepArgument,
        TRUE);

    End;

    local procedure BuildRGPRequestTypeConditions(Status: Integer): Text
    var
        RGPRequestHeader: Record "RGP Request Header";
    begin
        RGPRequestHeader.SetRange(Status, Status);
        EXIT(STRSUBSTNO(RGPRequestTypeCondTxt, WorkflowSetup.Encode(RGPRequestHeader.GETVIEW(FALSE))));
    end;

    //>> End;

    var
        WorkflowManagement: codeunit "Workflow Management";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkFlowSetup: Codeunit "Workflow Setup";
        NoWorkflowEnabledTxt: Label 'No approval workflow for this record type is enabled.';
        RGPRequestCodeTxt: Label 'RGP';
        RGPRequestWFCodeTxt: Label 'RGPAPW-002';
        RGPRequestWFDescTxt: Label 'RGP Request Workflow 002';
        RGPRequestTypeCondTxt: Label '<?xml version = "1.0" encoding="utf-8" standalone="yes"?><ReportParameters><DataItems><DataItem name="RGP Request Header">%1</DataItem></DataItems></ReportParameters>';

}