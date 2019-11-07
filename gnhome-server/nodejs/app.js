const express = require("express");
const widgetLoader = require("./lib/widget-loader");
const interface = require("gnhome-interface");
const APIGraphQL = require("./lib/api/graphql-api");
const port = 8000;
const cors = require("cors");

widgetLoader.loadWidgets(__dirname + "/widgets");

const app = express();

app.set("view engine", "ejs");
app.set("views", "site/views/");
app.use(cors());
app.use(express.static("site/static"));

let graphQL = new APIGraphQL(app);

app.use((req, res, next) => {
    let path = "pages/" + req.path;

    try
    {
        res.render(path, (error, html) => {
            if(error == null)
                res.send(html);
            else
            {
                path += "/index";
                res.render(path, (error2, html2) => {
                    if(error2 == null)
                        res.send(html2);
                    else
                        next(error2);
                })
            }
        });
    }
    catch(exception)
    {
        next();
    }
});

//Fallback in case of 404
app.use((req, res, next) => {
    if(req.path.indexOf(/.*\..+/) == -1)
        res.status(404).send("404 - Page not found: " + req.path);
    else
        next();
});

app.listen(port, () => console.log(`Now listening on port ${port}!`));

function runInterfaces()
{
    let widgetList = interface.getWidgetList();
    for(let name in widgetList)
        widgetList[name].run();
}

setInterval(runInterfaces, 1);