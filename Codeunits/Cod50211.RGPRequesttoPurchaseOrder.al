codeunit 50211 "RGP Habdle Request to Purch Quote(Yes/No)"
{
    TableNo = "RGP Request Header";

    trigger OnRun()
    var
        ConfirmManagement: Codeunit "Confirm Management";
        RGPRequestToPurchQuote: Codeunit "RGP Request to Purch Quote";
        QuoteCount: Integer;
        IsHandled: Boolean;
    begin
        if not (Rec.Status in [ Rec.Status::Approved]) then
            Error('Request status must be Approved to create Purchase Quotes. Current status is %1.', Rec.Status);

        // Check if quotes already exist
        QuoteCount := RGPRequestToPurchQuote.GetQuoteCount(Rec."Request No.");
        if QuoteCount > 0 then
            Error('%1 Purchase Quote(s) have already been created from this Request.', QuoteCount);

        if not ConfirmManagement.GetResponseOrDefault(ConvertRequestToQuotesQst, true) then
            exit;

        IsHandled := false;
        OnBeforeRGPRequestToPurchQuotes(Rec, IsHandled);
        if IsHandled then
            exit;

        RGPRequestToPurchQuote.Run(Rec);

        // Always retrieve the first created quote
        RGPRequestToPurchQuote.GetFirstPurchQuoteHeader(PurchQuoteHeader);

        IsHandled := false;
        OnAfterCreatePurchQuotes(PurchQuoteHeader, IsHandled);

        if not IsHandled then
            if ConfirmManagement.GetResponseOrDefault(OpenNewQuotesQst, true) then
                Page.Run(Page::"Purchase Quote", PurchQuoteHeader);
    end;

    var
        ConvertRequestToQuotesQst: Label 'Do you want to convert the request to purchase quotes for all vendors?';
        PurchQuoteHeader: Record "Purchase Header";
        RGPRequestToPurchQuote: Codeunit "RGP Request to Purch Quote";
        OpenNewQuotesQst: Label 'Purchase Quote has been created. Do you want to open the first one?';

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatePurchQuotes(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRGPRequestToPurchQuotes(var RGPRequestHeader: Record "RGP Request Header"; var IsHandled: Boolean)
    begin
    end;
}
