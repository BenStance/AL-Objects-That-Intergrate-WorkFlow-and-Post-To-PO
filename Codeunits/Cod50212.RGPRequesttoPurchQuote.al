codeunit 50212 "RGP Request to Purch Quote"
{
    TableNo = "RGP Request Header";

    trigger OnRun()
    var
        RGPRequestVendorLine: Record "RGP Request Vendor Line";
        Vendor: Record Vendor;
        IsHandled: Boolean;
        QuoteCount: Integer;
    begin
        OnBeforeRun(Rec);

        // Validate the request
        if not (Rec.Status in [Rec.Status::Approved]) then
            Error('Request status must be Approved to create Purchase Quotes. Current status is %1.', Rec.Status);

        // Check if there are vendor lines
        RGPRequestVendorLine.Reset();
        RGPRequestVendorLine.SetRange("Request No.", Rec."Request No.");
        if RGPRequestVendorLine.IsEmpty() then
            Error('Cannot create Purchase Quotes. There are no vendors specified for Request %1.', Rec."Request No.");

        // Loop through all vendor lines and create quotes
        if RGPRequestVendorLine.FindSet() then
            repeat
                // Create quote for this vendor
                CreatePurchHeader(Rec, RGPRequestVendorLine);
                TransferRequestToQuoteLines(Rec, PurchQuoteHeader, RGPRequestVendorLine);

                // Update the Vendor Line with the PQ Number
                RGPRequestVendorLine."Purchase Quote No." := PurchQuoteHeader."No.";
                RGPRequestVendorLine.Modify();

                QuoteCount += 1;

                // Store the first created header
                if QuoteCount = 1 then
                    FirstPurchQuoteHeader := PurchQuoteHeader;

                SetPurchQuoteHeader(PurchQuoteHeader);

            until RGPRequestVendorLine.Next() = 0;

        if QuoteCount = 0 then
            Error('No valid vendors found to create Purchase Quotes.');

        // Update the main request header if only one quote was created
        if QuoteCount = 1 then begin
            Rec."Purchase Quote No." := PurchQuoteHeader."No.";
            Rec.Modify();
        end;

        OnAfterRun(Rec, PurchQuoteHeader, QuoteCount);
    end;

    local procedure CreatePurchHeader(RGPRequestHeader: Record "RGP Request Header"; RGPRequestVendorLine: Record "RGP Request Vendor Line")
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit "No. Series";
    begin
        OnBeforeCreatePurchHeader(RGPRequestHeader, RGPRequestVendorLine);

        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.TestField("Quote Nos.");

        PurchQuoteHeader.Init();
        PurchQuoteHeader."Document Type" := PurchQuoteHeader."Document Type"::Quote;
        PurchQuoteHeader."No." := NoSeriesMgt.GetNextNo(PurchasesPayablesSetup."Quote Nos.", WorkDate(), true);
        PurchQuoteHeader."Buy-from Vendor No." := RGPRequestVendorLine."Vendor No.";
        PurchQuoteHeader."Order Date" := WorkDate();
        PurchQuoteHeader."Posting Date" := WorkDate();
        PurchQuoteHeader."Expected Receipt Date" := RGPRequestHeader."Expected Date";
        PurchQuoteHeader."Shortcut Dimension 1 Code" := RGPRequestHeader."Shortcut Dimension 1 Code";
        PurchQuoteHeader."Shortcut Dimension 2 Code" := RGPRequestHeader."Shortcut Dimension 2 Code";
        PurchQuoteHeader."Your Reference" :=
            CopyStr(StrSubstNo('Created from RGP Request %1 for Vendor %2',
                RGPRequestHeader."Request No.", RGPRequestVendorLine."Vendor No."),
                1, MaxStrLen(PurchQuoteHeader."Your Reference"));
        PurchQuoteHeader."RGP Request No." := RGPRequestHeader."Request No.";
        PurchQuoteHeader."RGP Request No." := RGPRequestHeader."Request No.";  
        PurchQuoteHeader."Requested By" := RGPRequestHeader."Requested By";  
        PurchQuoteHeader."Request Date" := RGPRequestHeader."Request Date";


        OnCreatePurchHeaderOnBeforePurchQuoteHeaderInsert(PurchQuoteHeader, RGPRequestHeader, RGPRequestVendorLine);
        PurchQuoteHeader.Insert(true);
        OnCreatePurchHeaderOnAfterPurchQuoteHeaderInsert(PurchQuoteHeader, RGPRequestHeader, RGPRequestVendorLine);

        PurchQuoteHeader.Validate("Buy-from Vendor No.", RGPRequestVendorLine."Vendor No.");
        PurchQuoteHeader.Modify(true);

        OnAfterCreatePurchHeader(PurchQuoteHeader, RGPRequestHeader, RGPRequestVendorLine);
    end;

    local procedure TransferRequestToQuoteLines(RGPRequestHeader: Record "RGP Request Header"; var PurchQuoteHeader: Record "Purchase Header"; RGPRequestVendorLine: Record "RGP Request Vendor Line")
    var
        RGPRequestItemLine: Record "RGP Request Item Line";
        PurchQuoteLine: Record "Purchase Line";
        LineNo: Integer;
    begin
        RGPRequestItemLine.Reset();
        RGPRequestItemLine.SetRange("Request No.", RGPRequestHeader."Request No.");
        OnTransferRequestToQuoteLinesOnAfterRGPRequestItemLineSetFilters(RGPRequestItemLine, RGPRequestHeader, PurchQuoteHeader, RGPRequestVendorLine);
        
        if RGPRequestItemLine.FindSet() then
            repeat
                LineNo := LineNo + 10000;
                
                PurchQuoteLine.Init();
                PurchQuoteLine."Document Type" := PurchQuoteHeader."Document Type";
                PurchQuoteLine."Document No." := PurchQuoteHeader."No.";
                PurchQuoteLine."Line No." := LineNo;
                PurchQuoteLine.Validate("Type", RGPRequestItemLine.Type.AsInteger());
                PurchQuoteLine.Validate("No.", RGPRequestItemLine."No.");
                PurchQuoteLine.Description := RGPRequestItemLine.Description;
                PurchQuoteLine.Validate(Quantity, RGPRequestItemLine.Quantity);
                
                if RGPRequestVendorLine."Quoted Amount" > 0 then
                    PurchQuoteLine.Validate("Direct Unit Cost", RGPRequestVendorLine."Quoted Amount" / RGPRequestItemLine.Quantity)
                else
                    PurchQuoteLine.Validate("Direct Unit Cost", RGPRequestItemLine."Unit Price");
                
                PurchQuoteLine.Validate("Location Code", RGPRequestItemLine."Location Code");
                PurchQuoteLine.Validate("Unit of Measure Code", RGPRequestItemLine."Unit of Measure Code");
                PurchQuoteLine.Validate("Shortcut Dimension 1 Code", RGPRequestHeader."Shortcut Dimension 1 Code");
                PurchQuoteLine.Validate("Shortcut Dimension 2 Code", RGPRequestHeader."Shortcut Dimension 2 Code");

                PurchQuoteHeader."RGP Request No." := RGPRequestHeader."Request No.";
                PurchQuoteLine."RGP Request No." := PurchQuoteHeader."RGP Request No."; 
                PurchQuoteLine."Requested By" := RGPRequestHeader."Requested By";
                PurchQuoteLine."Request Date" := RGPRequestHeader."Request Date";
                PurchQuoteLine."Requested Quantity" := RGPRequestItemLine.Quantity;

                OnBeforeInsertPurchQuoteLine(PurchQuoteLine, PurchQuoteHeader, RGPRequestItemLine, RGPRequestHeader, RGPRequestVendorLine);
                PurchQuoteLine.Insert(true);
                OnAfterInsertPurchQuoteLine(RGPRequestItemLine, PurchQuoteLine, RGPRequestVendorLine);

            until RGPRequestItemLine.Next() = 0;
    end;

    procedure GetPurchQuoteHeader(var PurchHeader: Record "Purchase Header")
    begin
        PurchHeader := PurchQuoteHeader;
    end;

    procedure GetFirstPurchQuoteHeader(var PurchHeader: Record "Purchase Header")
    begin
        PurchHeader := FirstPurchQuoteHeader;
    end;

    local procedure SetPurchQuoteHeader(var PurchHeader: Record "Purchase Header")
    begin
        PurchQuoteHeader := PurchHeader;
    end;

    procedure GetQuoteCount(RequestNo: Code[20]): Integer
    var
        RGPRequestVendorLine: Record "RGP Request Vendor Line";
    begin
        RGPRequestVendorLine.Reset();
        RGPRequestVendorLine.SetRange("Request No.", RequestNo);
        RGPRequestVendorLine.SetFilter("Purchase Quote No.", '<>%1', '');
        exit(RGPRequestVendorLine.Count);
    end;

    var
        PurchQuoteHeader: Record "Purchase Header";
        FirstPurchQuoteHeader: Record "Purchase Header"; // New variable

    // Events unchanged
    [IntegrationEvent(false, false)]
    local procedure OnBeforeRun(var RGPRequestHeader: Record "RGP Request Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRun(var RGPRequestHeader: Record "RGP Request Header"; PurchQuoteHeader: Record "Purchase Header"; QuoteCount: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreatePurchHeader(var RGPRequestHeader: Record "RGP Request Header"; var RGPRequestVendorLine: Record "RGP Request Vendor Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatePurchHeader(var PurchQuoteHeader: Record "Purchase Header"; RGPRequestHeader: Record "RGP Request Header"; RGPRequestVendorLine: Record "RGP Request Vendor Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreatePurchHeaderOnBeforePurchQuoteHeaderInsert(var PurchQuoteHeader: Record "Purchase Header"; var RGPRequestHeader: Record "RGP Request Header"; RGPRequestVendorLine: Record "RGP Request Vendor Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreatePurchHeaderOnAfterPurchQuoteHeaderInsert(var PurchQuoteHeader: Record "Purchase Header"; var RGPRequestHeader: Record "RGP Request Header"; RGPRequestVendorLine: Record "RGP Request Vendor Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPurchQuoteLine(var PurchQuoteLine: Record "Purchase Line"; PurchQuoteHeader: Record "Purchase Header"; RGPRequestItemLine: Record "RGP Request Item Line"; RGPRequestHeader: Record "RGP Request Header"; RGPRequestVendorLine: Record "RGP Request Vendor Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPurchQuoteLine(var RGPRequestItemLine: Record "RGP Request Item Line"; var PurchQuoteLine: Record "Purchase Line"; RGPRequestVendorLine: Record "RGP Request Vendor Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTransferRequestToQuoteLinesOnAfterRGPRequestItemLineSetFilters(var RGPRequestItemLine: Record "RGP Request Item Line"; var RGPRequestHeader: Record "RGP Request Header"; PurchQuoteHeader: Record "Purchase Header"; RGPRequestVendorLine: Record "RGP Request Vendor Line")
    begin
    end;
}
