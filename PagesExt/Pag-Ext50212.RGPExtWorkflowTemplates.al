pageextension 50212 "RGP Workflow Template Ext" extends "Workflow Templates"
{
    actions
    {
        addlast(processing)
        {
            action(CreateRGPRequestWorkflowTemplate)
            {
                ApplicationArea = All;
                Caption = 'Generate RGP Template';
                Image = NewDocument;
                ToolTip = 'Create a workflow template for RGP Request approval process.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    RGPCustomWorkflowMgmt: Codeunit "RGP Custom Workflow Mgmt";
                begin
                    RGPCustomWorkflowMgmt.InsertRGPRequestWorkFlowTemplate();
                end;
            }
        }
    }
}