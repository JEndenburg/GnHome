const express = require("express");
const port = 8000;

const app = express();

app.set("view engine", "ejs");
app.use(express.static("static"));


//TODO: Put Page rendering here.

//Fallback in case of 404
app.use((req, res, next) => {
    res.status(404).send("404 - Page not found");
});


app.listen(port, () => console.log(`Now listening on port ${port}!`));