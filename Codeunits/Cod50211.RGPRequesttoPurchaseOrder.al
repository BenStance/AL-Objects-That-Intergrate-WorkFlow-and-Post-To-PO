codeunit 50211 "RGP Request to Purchase Order"
{
    TableNo = "RGP Request Header";

    trigger OnRun()
    begin
        CreatePurchaseOrderFromRequest(Rec);
    end;

    procedure CreatePurchaseOrderFromRequest(var RGPRequestHeader: Record "RGP Request Header")
    var
        RGPRequestVendorLine: Record "RGP Request Vendor Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        RGPRequestItemLine: Record "RGP Request Item Line";
        Vendor: Record Vendor;
        NoSeries: Codeunit "No. Series";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        LineNo: Integer;
    begin
        // Validate that the request is approved
        RGPRequestHeader.TestField(Status, RGPRequestHeader.Status::Approved);

        // Check if there are any vendor lines
        RGPRequestVendorLine.Reset();
        RGPRequestVendorLine.SetRange("Request No.", RGPRequestHeader."Request No.");
        if not RGPRequestVendorLine.FindSet() then
            Error('No vendors found for request %1. Please add vendors before converting to purchase order.', RGPRequestHeader."Request No.");

        // Get purchase setup
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.TestField("Order Nos.");

        // Process each vendor
        repeat
            // Validate vendor
            if not Vendor.Get(RGPRequestVendorLine."Vendor No.") then
                Error('Vendor %1 does not exist.', RGPRequestVendorLine."Vendor No.");

            // Create purchase header for each vendor
            PurchaseHeader.Init();
            PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
            PurchaseHeader."No." := NoSeries.GetNextNo(PurchasesPayablesSetup."Order Nos.", WorkDate(), true);
            PurchaseHeader.Validate("Buy-from Vendor No.", RGPRequestVendorLine."Vendor No.");
            PurchaseHeader.Validate("Order Date", WorkDate());
            PurchaseHeader.Validate("Posting Date", WorkDate());
            PurchaseHeader.Validate("Expected Receipt Date", RGPRequestHeader."Expected Date");
            PurchaseHeader.Validate("Shortcut Dimension 1 Code", RGPRequestHeader."Shortcut Dimension 1 Code");
            PurchaseHeader.Validate("Shortcut Dimension 2 Code", RGPRequestHeader."Shortcut Dimension 2 Code");
            PurchaseHeader."RGP Request No." := RGPRequestHeader."Request No.";
            PurchaseHeader.Insert(true);

            // Add items to purchase lines
            LineNo := 10000;
            RGPRequestItemLine.Reset();
            RGPRequestItemLine.SetRange("Request No.", RGPRequestHeader."Request No.");
            if RGPRequestItemLine.FindSet() then
                repeat
                    PurchaseLine.Init();
                    PurchaseLine."Document Type" := PurchaseLine."Document Type"::Order;
                    PurchaseLine."Document No." := PurchaseHeader."No.";
                    PurchaseLine."Line No." := LineNo;
                    PurchaseLine.Validate(Type, RGPRequestItemLine.Type);
                    PurchaseLine.Validate("No.", RGPRequestItemLine."No.");
                    PurchaseLine.Validate(Quantity, RGPRequestItemLine.Quantity);
                    PurchaseLine.Validate("Direct Unit Cost", RGPRequestItemLine."Unit Price");
                    PurchaseLine.Validate("Location Code", RGPRequestItemLine."Location Code");
                    PurchaseLine.Validate("Unit of Measure Code", RGPRequestItemLine."Unit of Measure Code");
                    PurchaseLine.Validate("Shortcut Dimension 1 Code", RGPRequestHeader."Shortcut Dimension 1 Code");
                    PurchaseLine.Validate("Shortcut Dimension 2 Code", RGPRequestHeader."Shortcut Dimension 2 Code");
                    PurchaseLine."RGP Request No." := RGPRequestHeader."Request No.";
                    PurchaseLine.Insert(true);
                    
                    LineNo += 10000;
                until RGPRequestItemLine.Next() = 0;

            // Update vendor line with purchase order number
            RGPRequestVendorLine."Purchase Order No." := PurchaseHeader."No.";
            RGPRequestVendorLine.Modify();

            // Show success message for each created PO
            Message('Purchase Order %1 created for Vendor %2 from Request %3.', 
                PurchaseHeader."No.", RGPRequestVendorLine."Vendor No.", RGPRequestHeader."Request No.");

        until RGPRequestVendorLine.Next() = 0;

        // Update request status to Completed
        RGPRequestHeader.Status := RGPRequestHeader.Status::Approved;
        RGPRequestHeader.Modify();

        Message('Successfully created purchase orders for all vendors from Request %1.', RGPRequestHeader."Request No.");
    end;

    procedure CreatePurchaseOrderForAcceptedVendor(var RGPRequestHeader: Record "RGP Request Header")
    var
        RGPRequestVendorLine: Record "RGP Request Vendor Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        RGPRequestItemLine: Record "RGP Request Item Line";
        Vendor: Record Vendor;
        NoSeriesMgt: Codeunit "No. Series";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        LineNo: Integer;
    begin
        // Validate that the request is approved
        RGPRequestHeader.TestField(Status, RGPRequestHeader.Status::Approved);

        // Find the accepted vendor
        RGPRequestVendorLine.Reset();
        RGPRequestVendorLine.SetRange("Request No.", RGPRequestHeader."Request No.");
        RGPRequestVendorLine.SetRange(Accepted, true);
        if not RGPRequestVendorLine.FindFirst() then
            Error('No accepted vendor found for request %1. Please accept a vendor before converting to purchase order.', RGPRequestHeader."Request No.");

        // Validate vendor
        if not Vendor.Get(RGPRequestVendorLine."Vendor No.") then
            Error('Vendor %1 does not exist.', RGPRequestVendorLine."Vendor No.");

        // Get purchase setup
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.TestField("Order Nos.");

        // Create purchase header for the accepted vendor
        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
        PurchaseHeader."No." := NoSeriesMgt.GetNextNo(PurchasesPayablesSetup."Order Nos.", WorkDate(), true);
        PurchaseHeader.Validate("Buy-from Vendor No.", RGPRequestVendorLine."Vendor No.");
        PurchaseHeader.Validate("Order Date", WorkDate());
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Validate("Expected Receipt Date", RGPRequestHeader."Expected Date");
        PurchaseHeader.Validate("Shortcut Dimension 1 Code", RGPRequestHeader."Shortcut Dimension 1 Code");
        PurchaseHeader.Validate("Shortcut Dimension 2 Code", RGPRequestHeader."Shortcut Dimension 2 Code");
        PurchaseHeader."RGP Request No." := RGPRequestHeader."Request No.";
        PurchaseHeader.Insert(true);

        // Add items to purchase lines
        LineNo := 10000;
        RGPRequestItemLine.Reset();
        RGPRequestItemLine.SetRange("Request No.", RGPRequestHeader."Request No.");
        if RGPRequestItemLine.FindSet() then
            repeat
                PurchaseLine.Init();
                PurchaseLine."Document Type" := PurchaseLine."Document Type"::Order;
                PurchaseLine."Document No." := PurchaseHeader."No.";
                PurchaseLine."Line No." := LineNo;
                PurchaseLine.Validate(Type, RGPRequestItemLine.Type);
                PurchaseLine.Validate("No.", RGPRequestItemLine."No.");
                PurchaseLine.Validate(Quantity, RGPRequestItemLine.Quantity);
                PurchaseLine.Validate("Direct Unit Cost", RGPRequestItemLine."Unit Price");
                PurchaseLine.Validate("Location Code", RGPRequestItemLine."Location Code");
                PurchaseLine.Validate("Unit of Measure Code", RGPRequestItemLine."Unit of Measure Code");
                PurchaseLine.Validate("Shortcut Dimension 1 Code", RGPRequestHeader."Shortcut Dimension 1 Code");
                PurchaseLine.Validate("Shortcut Dimension 2 Code", RGPRequestHeader."Shortcut Dimension 2 Code");
                PurchaseLine."RGP Request No." := RGPRequestHeader."Request No.";
                PurchaseLine.Insert(true);
                
                LineNo += 10000;
            until RGPRequestItemLine.Next() = 0;

        // Update vendor line with purchase order number
        RGPRequestVendorLine."Purchase Order No." := PurchaseHeader."No.";
        RGPRequestVendorLine.Modify();

        // Update request status to Completed
        RGPRequestHeader.Status := RGPRequestHeader.Status::Approved;
        RGPRequestHeader.Modify();

        Message('Purchase Order %1 created for Accepted Vendor %2 from Request %3.', 
            PurchaseHeader."No.", RGPRequestVendorLine."Vendor No.", RGPRequestHeader."Request No.");
    end;
}