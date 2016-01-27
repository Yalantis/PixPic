
var utils = require("cloud/Utils/index.js");

postAfterSave = function(request) {	
	utils.getUserByObjectId(request.user.id).then(function(user) {
		var username = user.get("username");
		return Parse.Promise.as(username);
	}).then(function (username) {
		var message = "'" + username + "'" + " posted new photo!";
		var pushQuery = new Parse.Query(Parse.Installation);
		var data = {
			alert: message,
			sound: "default"
		};

		return Parse.Push.send({
			where: pushQuery,
			data: data
		});
	}).fail(function (error) {
		console.log("failed with error" + error);
	});
};

exports.postAfterSave = postAfterSave;
