const express = require("express");
const widgetLoader = require("./lib/widget-loader");
const interface = require("gnhome-interface");
const APIGraphQL = require("./lib/api/graphql-api");
const uploadHandler = require("./lib/widget-uploader");
const port = 8000;

widgetLoader.loadWidgets(__dirname + "/widgets");

const app = express();

app.set("view engine", "ejs");
app.set("views", "site/views/");
app.use(express.static("site/static"));

let graphQL = new APIGraphQL(app);
app.get("/mock/api/weather.json", (req, res) => {
    const imageList = [
        "bewolkt", "zonnig", "bliksem", "regen", "halfbewolkt",
        "hagel", "buien", "zwaarbewolkt", "mist", "sneeuw",
        "helderenacht", "nachtmist", "wolkennacht"
    ]

    let report = {
        liveweer: [
            {
                plaats: "De Bilt",
                temp: (Math.random() * 10.0 - 2.0).toFixed("1"),
                image: imageList[Math.floor(Math.random() * imageList.length)],
            }
        ]
    }

     res.send(report); 
}); //THIS IS A MOCK API

uploadHandler(app, __dirname);

app.get("/*", renderIndexPage);

/**
 * 
 * @param {express.Request} req 
 * @param {express.Response} res 
 */
function renderIndexPage(req, res)
{
    res.render("pages/index.ejs");
}

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