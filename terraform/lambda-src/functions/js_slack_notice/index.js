const http = require('http');
const HOOK_URL = process.env.HOOK_URL;

exports.handler = function(event, context) {
  let message = 'お試しです。';

//  let options = {
//    url:     HOOK_URL,
//    headers: {'Content-type': 'application/json'},
//    body:    '{"text":"'+message+'"}'
//  };
  console.log(message);
//  http.request(options);
};