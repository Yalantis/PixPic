
getUserByObjectId = function (userId) {
	Parse.Cloud.useMasterKey();
	var userQuery = new Parse.Query(Parse.User);

	userQuery.equalTo("objectId", userId);

	return userQuery.first();
};

exports.getUserByObjectId = getUserByObjectId;
