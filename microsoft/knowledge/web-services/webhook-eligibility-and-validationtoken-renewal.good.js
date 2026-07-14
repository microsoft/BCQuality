function receiveBusinessCentralWebhook(request, response) {
    const validationToken = request.query.validationToken;

    if (typeof validationToken === "string") {
        response.status(200).type("text/plain").send(validationToken);
        return;
    }

    processNotifications(request.body.value);
    response.sendStatus(200);
}
