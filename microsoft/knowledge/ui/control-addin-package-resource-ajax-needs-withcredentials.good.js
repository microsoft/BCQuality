function loadPackagedTemplate(url) {
    return $.ajax({
        url: url,
        xhrFields: {
            withCredentials: true
        }
    }).done(renderTemplate);
}
