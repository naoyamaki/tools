const request = require('request');
const HOOK_URL = process.env.HOOK_URL;
const MENTION = process.env.MENTION;

exports.handler = function(event, context) {

  let snsMessage = JSON.parse(event.Records[0].Sns.Message); // SNS経由で得たCloudWatchアラート情報
  let message = '{"text":"'+MENTION+'\n対象アラーム : '+snsMessage.AlarmName+'\nアラームの説明 : '+snsMessage.AlarmDescription+'\n原因 : '+snsMessage.NewStateReason+'"}';

  let options = {
    url:     HOOK_URL,
    headers: {'Content-type': 'application/json'},
    body:    message,
    json:    data
  };

  request.post(options, function(error, response, body) {
    if (!error && response.statusCode == 200) {
      context.succeed('Message posted successfully');
    } else  {
      context.fail('error occurred during post slack API: status code -> ' + response.statusCode);
    }
  });
};