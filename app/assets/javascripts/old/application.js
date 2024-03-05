$(document).ready(function () {
    // let the server know the user has JS enabled
    document.cookie = "javascript_enabled=1; path=/";

    $("input[placeholder]").textPlaceholder();
});
