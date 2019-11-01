"use strict";
exports.handler = (event, context, callback) => {
  try {
    const response = event.Records[0].cf.response;
    const headers = response.headers;

    headers["x-frame-options"] = [{ value: "DENY", key: "X-Frame-Options" }];
    callback(null, response);
  } catch (e) {
    console.log(e.message);
  }
};
