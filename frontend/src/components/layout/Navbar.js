import React from "react";
import { MdRowing } from 'react-icons/md'

import './Navbar.css'

function Navbar() {
  return (
    <div className="Navbar">
      <div className="wrapper">
        <a href="/"><MdRowing size={36}/></a>
        <h1>Coxswain</h1>
      </div>
    </div>
  );
}

export default Navbar;
