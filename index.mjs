import * as AWS from '@aws-sdk/client-sts'

const sts = new AWS.STS();

export async function handler(event, context) {
    const identity = await sts.getCallerIdentity();
    console.log(JSON.stringify({ nodejs: '20', context, identity }, null, 2));
    return {};
}
