codeunit 50542 "Perf Sample CaseChain Good"
{
    procedure IsShippableLine(SalesLine: Record "Sales Line"): Boolean
    var
        Item: Record Item;
    begin
        // 'case false of' matches the value sets in order and stops at the first
        // match, so each value set is reached only when the previous one passed —
        // and Item.Get is never called for a non-item line.
        case false of
            // Pure field reads with no side effects and no order dependency, so
            // they share one value set and one action.
            (SalesLine.Type = SalesLine.Type::Item),
            (SalesLine."No." <> ''),
            (SalesLine."Qty. to Ship" > 0):
                exit(false);
            // These two keep their own value sets even though the action repeats:
            // ordering across separate value sets is what the documentation
            // guarantees. The Get must not run until the checks above pass, and
            // Blocked must not be read until the Get succeeded.
            Item.Get(SalesLine."No."):
                exit(false);
            (not Item.Blocked):
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
