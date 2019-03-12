const elmServerless = require('elm-serverless');

const elm = require('./Hello.elm');

exports.handler = elmServerless.httpApi({
  handler: elm.Hello,
  requestPort: 'requestPort',
  responsePort: 'responsePort'
})
