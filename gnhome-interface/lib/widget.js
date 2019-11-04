
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
     * @returns {string} A JSON response
     */
    onQuery(query) { return ""; }
}


module.exports = Widget;