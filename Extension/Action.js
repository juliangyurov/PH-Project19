var Action = function () {}

Action.prototype = {
    
run: function(parameters) {
    parameters.completionFunction({
        "URL": document.URL,
        "title": document.title,
        "body": document.body.innerText,
        "head": document.head.innerText,
        "doctype": document.doctype
    })
},
finalize: function(parameters) {
    var customJavaScript = parameters["customJavaScript"];
    eval(customJavaScript);
}
};

var ExtensionPreprocessingJS = new Action
