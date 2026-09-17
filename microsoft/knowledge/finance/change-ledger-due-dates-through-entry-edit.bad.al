// Demonstration only; independently authored, not copied from BaseApp.
codeunit 50105 "Update Ledger Due Dates"
{
    procedure UpdateCustomerDueDate(EntryNo: Integer; NewDueDate: Date)
    var
        CustomerEntry: Record "Cust. Ledger Entry";
    begin
        CustomerEntry.Get(EntryNo);
        CustomerEntry.Validate("Due Date", NewDueDate);
        CustomerEntry.Modify(true);
    end;

    procedure UpdateVendorDueDate(EntryNo: Integer; NewDueDate: Date)
    var
        VendorEntry: Record "Vendor Ledger Entry";
    begin
        VendorEntry.Get(EntryNo);
        VendorEntry.Validate("Due Date", NewDueDate);
        VendorEntry.Modify(true);
    end;
}
