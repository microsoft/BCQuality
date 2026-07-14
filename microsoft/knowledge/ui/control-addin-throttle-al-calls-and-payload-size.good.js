const pendingChunks = [];
let callInProgress = false;
let transferHalted = false;

function sendRows(rows, maxArgumentsBytes) {
    if (transferHalted)
        throw new Error("Retry or discard the failed chunk before sending more rows.");

    const encoder = new TextEncoder();
    const chunks = [];
    let chunk = [];
    const argumentBytes = (payload) =>
        encoder.encode(JSON.stringify([payload])).length;

    for (const row of rows) {
        if (argumentBytes(JSON.stringify([row])) > maxArgumentsBytes)
            throw new Error("A row exceeds the configured payload limit.");

        const candidate = JSON.stringify([...chunk, row]);

        if (argumentBytes(candidate) <= maxArgumentsBytes) {
            chunk.push(row);
            continue;
        }

        chunks.push(JSON.stringify(chunk));
        chunk = [row];
    }

    if (chunk.length > 0)
        chunks.push(JSON.stringify(chunk));

    pendingChunks.push(...chunks);
    sendNextChunk();
}

function sendNextChunk() {
    if (callInProgress || pendingChunks.length === 0)
        return;

    callInProgress = true;
    const payload = pendingChunks[0];
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
        "StoreRows",
        [payload],
        false,
        () => {
            pendingChunks.shift();
            callInProgress = false;
            sendNextChunk();
        },
        () => {
            callInProgress = false;
            transferHalted = true;
            showTransferError();
        });
}

function retryFailedChunk() {
    if (!transferHalted)
        return;

    transferHalted = false;
    sendNextChunk();
}

function discardFailedChunk() {
    if (!transferHalted)
        return;

    pendingChunks.shift();
    transferHalted = false;
    sendNextChunk();
}
