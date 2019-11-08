const Response = require("./response");
const fs = require("fs");

class Widget
{
    /**
     * @param {number} uuid
     * @param {string} name 
     * @param {string} version 
     * @param {string} description
     */
    constructor(uuid, name, version, description)
    {
        if(!uuid || !name || !description || !version )
            throw "Constructor parameters may not be undefined";
            
        this._uuid = uuid;
        this._name = name;
        this._version = version;
        this._description = description;
    }

    get uuid() { return this._uuid; }
    get name() { return this._name; }
    get version() { return this._version; }
    get description() { return this._description; }

    /**
     * Getter to respond with current widget's global status.
     * @returns {Response} A response
     */
    get status() { return new Response(501, "Not Implemented"); }

    /**
     * Shorthand for creating a response object.
     * @param {number} statusCode 
     * @param {string} statusMessage 
     * @param {object} content 
     */
    createResponse(statusCode, statusMessage, content = {})
    {
        return new Response(statusCode, statusMessage, content);
    }

    run()
    {
    }
}


module.exports = Widget;