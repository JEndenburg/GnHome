const express = require("express");
const widgetLoader = require("./lib/widget-loader");
const port = 8000;

let modules = widgetLoader.loadWidgets(__dirname + "/widgets");

const app = express();

app.set("view engine", "ejs");
app.use(express.static("static"));


//TODO: Put Page rendering here.

//Fallback in case of 404
app.use((req, res, next) => {
    res.status(404).send("404 - Page not found");
});


app.listen(port, () => console.log(`Now listening on port ${port}!`));