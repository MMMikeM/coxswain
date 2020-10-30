import React, { useState, useEffect } from "react";
import Card from "../components/Card/card.js";
import Loader from "../components/Loader/Loader.js";
import { getServices, updateServices, nginx } from "../services/servicesApi.js";

const IndexPage = () => {
  const [loading, setLoading] = useState(false);
  const [dockerServices, setDockerServices] = useState([]);
  const loadServices = async () => {
    setLoading(true);
    let res = await getServices();
    setDockerServices(res.servers);
    setLoading(false);
  };

  const toggleProtected = async (index) => {
    let tempServices = [...dockerServices];
    if (tempServices[index].basic_auth) {
      delete tempServices[index].basic_auth;
    } else {
      tempServices[index].basic_auth = { message: "This is protected" };
    }
    setDockerServices(tempServices);
    updateServices({ servers: tempServices });
    nginx("restart");
  };

  useEffect(() => {
    loadServices();
  }, []);

  if (
    dockerServices.url == "localhost" &&
    dockerServices.exposed_port == "80"
  ) {
    return loading ? (
      <Loader />
    ) : (
      dockerServices.map((dockerService, index) => (
        <Card
          key={index}
          info={dockerService}
          index={index}
          toggleProtected={toggleProtected}
        />
      ))
    );
  }
};

export default IndexPage;
