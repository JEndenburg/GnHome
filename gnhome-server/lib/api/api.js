const express = require("express");
const graphQLAPI = require("./api-graphql");

const response = {
    [404] : { code: 404, message: "Page not found." },
};

/**
 * 
 * @param {express.Express} app 
 * @param {Function} getWidgetList
 */
function init(app, getWidgetList)
{
    graphQLAPI(app, getWidgetList);

    app.use("/api", (req, res, next) => {
        /** @type {String} */
        let communicationLanguage = req.query["lang"] || "graphql";
        
        if(req.path.length > 1)
        {
            next();
            return;
        }

        switch(communicationLanguage.toLowerCase())
        {
            case "graphql":
                res.redirect("/api/graphql");
                break;
            default:
                res.status(404).json(response[404]);
                break;
        }
    });
}

module.exports = init;