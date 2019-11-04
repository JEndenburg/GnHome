
class Response
{
    /**
     * 
     * @param {number} status 
     * @param {string} message 
     * @param {object} content 
     */
    constructor(status, message, content = {})
    {
        this.status = status;
        this.message = message;
        this.content = content;
    }
}


module.exports = Response;