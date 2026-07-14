function startSendingRows(rows) {
    window.setInterval(() => {
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
            "StoreRows",
            [JSON.stringify(rows)],
            false);
    }, 100);
}
