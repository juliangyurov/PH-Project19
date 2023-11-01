var Action = function () {}

Action.prototype = {
    
run: function(parameters) {
    parameters.completionFunction({
        "URL": document.URL,
        "title": document.title
//        "body": document.body,
//        "head": document.head,
//        "doctype": document.doctype
    })
},
finalize: function(parameters) {
    var customJavaScript = parameters["customJavaScript"];
    eval(customJavaScript);
}
};

var ExtensionPreprocessingJS = new Action
