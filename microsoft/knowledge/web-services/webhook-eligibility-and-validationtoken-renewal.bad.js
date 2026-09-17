function receiveBusinessCentralWebhook(request, response) {
    processNotifications(request.body.value);
    response.sendStatus(200);
}
