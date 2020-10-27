import React, { useState, useEffect } from "react";
import { useParams, useHistory } from "react-router-dom";

import EditCard from '../components/Card/EditCard/Card.js';
import Loader from '../components/Loader/Loader.js';
import { getServices, updateServices } from '../services/servicesApi.js';

const EditPage = () => {
  const history = useHistory()
  const [loading, setLoading] = useState(false)
  let [dockerService, setDockerService] = useState({})
  const [dockerServices, setDockerServices] = useState([])
  const { id } = useParams();
  const loadServices = async () => {
    setLoading(true)
    let res = await getServices()
    setDockerServices(res.servers)
    setDockerService(res.servers[id])
    setLoading(false)
  }
  const handleValueUpdate = (key, value) => {
    let tempDockerService = {...dockerService}
    tempDockerService[key] = value
    setDockerService(tempDockerService)
  }
  const handleConfigSave = async () => {
    dockerServices[id] = dockerService
    await updateServices({servers: dockerServices})
    history.push("/")
  }

  useEffect(() => {
    loadServices()
  }, [])
  
  return loading ? (<Loader />) : ( 
    <EditCard
      info={dockerService}
      handleValueUpdate={handleValueUpdate}
      handleConfigSave={handleConfigSave}/>
  )
}

export default EditPage
