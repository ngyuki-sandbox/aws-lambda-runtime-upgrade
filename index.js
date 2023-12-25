const AWS = require('aws-sdk');

const sts = new AWS.STS();

exports.handler = async function handler(event, context) {
    const identity = await sts.getCallerIdentity().promise();
    console.log(JSON.stringify({ nodejs: '16', context, identity }, null, 2));
    return {};
}
