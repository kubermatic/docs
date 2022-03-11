const fetch = require('node-fetch')
const atomicalgolia = require('atomic-algolia')

const cb = function(error, result) {
  if (error) throw error

  console.log(result)
}

const response = (status, body) => {
  return {
    statusCode: status,
    body: body
  }
}

exports.handler = async (event, context) => {
  const indexName = process.env.ALGOLIA_INDEX_NAME
  const indexPath = process.env.ALGOLIA_INDEX_FILE
  const deployUrl = process.env.STAGE_URL || 'https://docs.kubermatic.com'

  try {
    let dataResponse = await fetch([deployUrl, indexPath].join('/'))
    let indexData = await dataResponse.json()

    await atomicalgolia(indexName, indexData, {verbose: true}, cb)
  } catch(error) {
    return response(500, error.message)
  }

  return response(200, 'ok')
}
