const Response = require("./response");
const fs = require("fs");

class Widget
{
    /**
     * @param {string} name 
     * @param {string} version 
     * @param {string} description
     * @param {Function} execution
     */
    constructor(name, version, description)
    {
        if(!name || !description || !version )
            throw "Constructor parameters may not be undefined";
            
        this._name = name;
        this._version = version;
        this._description = description;
    }

    get name() { return this._name; }
    get version() { return this._version; }
    get description() { return this._description; }

    /**
     * Getter to respond with current widget's global status.
     * @returns {Response} A response
     */
    get status() { return new Response(501, "Not Implemented"); }

    /**
     * Getter to respond with widget content's URL.
     */
    get widgetURL() { return new Response(501, "Not Implemented") }

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

    /**
     * 
     * @param {String} filePath 
     */
    getFileContent(filePath)
    {
        return fs.readFileSync(filePath);
    }

    run()
    {
    }
}


module.exports = Widget;