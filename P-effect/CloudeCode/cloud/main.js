
var afterSave = require("cloud/AfterSave/index.js");

Parse.Cloud.afterSave("Post", afterSave.postAfterSave);
