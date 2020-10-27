import React from "react";
import {
  BrowserRouter as Router,
  Switch,
  Route,
} from "react-router-dom";

import "./App.css";
import Navbar from './components/layout/Navbar.js';
import ServerStatusBar from './components/ServerStatusBar/ServerStatusBar.js';
import Backdrop from './components/Backdrop/Backdrop.js';
import IndexPage from './pages/index.js';
import EditPage from './pages/edit.js';

function App() {
    return (
      <>
        <Backdrop />
        <Navbar />
        <ServerStatusBar />
        <div className="container">
          <Router>
            <Switch>
              <Route path="/:id/edit">
                <EditPage />
              </Route>
              <Route path="/">
                <IndexPage />
              </Route>
            </Switch>
          </Router>
        </div>
      </>
    )
}

export default App;
