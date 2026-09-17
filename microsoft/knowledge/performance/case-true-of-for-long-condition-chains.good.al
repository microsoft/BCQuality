codeunit 50542 "Perf Sample CaseChain Good"
{
    procedure IsShippableLine(SalesLine: Record "Sales Line"): Boolean
    var
        Item: Record Item;
    begin
        // 'case false of' matches value sets in order and stops at the first match.
        // The first three checks are pure and order-independent, so they share one
        // value set. Get and Blocked are each their own value set, in order, because
        // the ordering the documentation guarantees is across value sets, not within
        // one — Item.Get must run, and succeed, before Blocked is read.
        case false of
            SalesLine.Type = SalesLine.Type::Item,
            SalesLine."No." <> '',
            SalesLine."Qty. to Ship" > 0:
                exit(false);
            Item.Get(SalesLine."No."):
                exit(false);
            not Item.Blocked:
                exit(false);
        end;
        exit(true);
    end;

    procedure FindOpenDocumentType(CustomerNo: Code[20]): Text
    begin
        // 'case true of' stops at the first condition that holds, so the later
        // lookups never run once an earlier one matched.
        case true of
            HasOpenDocument(CustomerNo, "Sales Document Type"::Quote):
                exit('Quote');
            HasOpenDocument(CustomerNo, "Sales Document Type"::Order):
                exit('Order');
            HasOpenDocument(CustomerNo, "Sales Document Type"::Invoice):
                exit('Invoice');
        end;
        exit('None');
    end;

    local procedure HasOpenDocument(CustomerNo: Code[20]; DocumentType: Enum "Sales Document Type"): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", DocumentType);
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        exit(not SalesHeader.IsEmpty());
    end;
}
