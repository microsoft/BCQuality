tableextension 50100 "G/L Entry Extra Ext" extends "G/L Entry"
{
    fields
    {
        // Stored companion columns are joined on every G/L Entry read.
        field(50100; "External Reference"; Text[50]) { }
        field(50101; "Integration Payload"; Blob) { }
    }
}
