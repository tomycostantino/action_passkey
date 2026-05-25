import headers from "helpers/headers"

export default async function post(path, body) {
  const options = { method: "POST", headers }

  if (body !== undefined) {
    options.body = JSON.stringify(body)
  }

  const response = await fetch(path, options)

  if (!response.ok) {
    throw new Error(`POST ${path} failed`)
  }

  return response
}
