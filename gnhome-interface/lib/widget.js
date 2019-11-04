const Response = require("./response");

class Widget
{
    /**
     * @param {string} name 
     * @param {string} version 
     * @param {string} description
     * @param {Function} execution
     */
    constructor(name, version, description, execution)
    {
        if(!name || !description || !version  || !execution)
            throw "Constructor parameters may not be undefined";
            
        this.name = name;
        this.version = version;
        this.description = description;
        this.run = execution;
    }

    /**
     * Function to be run when receiving a query.
     * @param {string} query A JSON query
     * @returns {Response} A response
     */
    onQuery(query) { return new Response(501, "Not Implemented"); }
}


module.exports = Widget;