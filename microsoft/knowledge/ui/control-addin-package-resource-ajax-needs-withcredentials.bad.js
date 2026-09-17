function loadPackagedTemplate(url) {
    return $.get(url).done(renderTemplate);
}
