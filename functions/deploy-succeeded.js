const atomicalgolia = require('atomic-algolia')

const response = (status, body) => {
  return {
    statusCode: status,
    body: body
  }
}

exports.handler = (event, context, callback) => {
  if (!process.env.ALGOLIA_APP_ID || !process.env.ALGOLIA_ADMIN_KEY) {
    console.log('Not used in this context')
    callback(null, response(204, 'no content'))
    return
  }

  const indexFile = require(process.env.ALGOLIA_INDEX_FILE)
  const indexName = process.env.ALGOLIA_INDEX_NAME

  atomicalgolia(indexName, indexFile, {verbose: true}, (error, result) => {
    if (error) {
      console.error(error.message)
      callback(error.message, response(500, JSON.stringify({ error: error.message })))
      return
    }

    console.log('Status: ok. TaskID: ', result.taskID)
    callback(null, response(200, 'ok'))
  })
}
