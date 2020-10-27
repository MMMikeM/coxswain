import React, { useEffect } from "react";
import '../card.css'

import { MdSave } from 'react-icons/md'

const EditCard = ({ info, handleValueUpdate, handleConfigSave }) => {
  let localInfo = {}
  useEffect(() => {
    localInfo = info
  }, [localInfo])

  return (
    <div className="Card">
      <h2>Edit {info.host}</h2>
      <div className='float-right buttons'>
        <MdSave size={30} onClick={ () => handleConfigSave() }/>
      </div>
      <table>
        <tbody>
          <tr>
            <td>URL:</td>
            <td>
              <input
                type="text"
                value={info.url}
                onChange={ e => { handleValueUpdate('url', e.target.value) } }
              />
            </td>
          </tr>
          <tr>
            <td>Host:</td>
            <td>
              <input
                type="text"
                value={info.host}
                onChange={ e => { handleValueUpdate('host', e.target.value) } }
              />
            </td>
          </tr>
          <tr>
            <td>Container Port:</td>
            <td>
              <input
                type="text"
                value={info.port}
                onChange={ e => { handleValueUpdate('port', e.target.value) } }
              />
            </td>
          </tr>
          <tr>
            <td>Exposed Port:</td>
            <td>
              <input
                type="text"
                value={info.exposed_port}
                onChange={ e => { handleValueUpdate('exposed_port', e.target.value) } }
              />
            </td>
          </tr>
          <tr>
            <td>SSL Certificate:</td>
            <td>
              <input
                type="text"
                value={info.ssl_certificate}
                onChange={ e => { handleValueUpdate('ssl_certificate', e.target.value) } }
              />
            </td>
          </tr>
          <tr>
            <td>SSL Certificate Key:</td>
            <td>
              <input
                type="text"
                value={info.ssl_certificate_key}
                onChange={ e => { handleValueUpdate('ssl_certificate_key', e.target.value) } }
              />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  );
}

export default EditCard
