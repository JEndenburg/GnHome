const Response = require("./response");

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
     * Function to be run when receiving a get query.
     * @returns {Response} A response
     */
    get status() { return new Response(501, "Not Implemented"); }

    run()
    {
    }
}


module.exports = Widget;