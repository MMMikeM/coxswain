import request from './request'

export const getServices = async () => {
  let response = await request("GET", "/config")
  return response.json()
}

export const updateServices = async (body) => {
  let response = await request("PUT", "/config", JSON.stringify(body))
  return response.json()
}

export const nginx = async (command) => {
  let response = await request("GET", `/${command}`)
  return response.json()
}
