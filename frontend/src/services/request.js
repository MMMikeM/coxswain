const request = async (method, path, body) => {
  const baseUrl = "http://localhost:3000"
  const token = "ck1f9y8fo0000t0xyc66fleqk"
  const url = `${baseUrl}/nginx${path}?token=${token}`
  const headers = new Headers({})
  headers.set('Content-Type', 'application/json')
  const fetchOptions = { method, headers, body }

  const response = await fetch(url, fetchOptions)

  const validStatuses = [200, 201, 302]
  const invalidStatuses = [401, 404, 500]

  if (validStatuses.includes(response.status)) {
    return response
  } else if (invalidStatuses.includes(response.status)) {
    console.error(`Error fetching ${url}: ${response.status} (${response.statusCode}) ${response.body}`)
  }

  return response
}

export default request
