module.exports = init;

const multer = require("multer");
const express = require("express");

const uploadHandler = multer();

const expectedFiles = 2;
const nameLengthRange = { min: 4, max: 30 };
const versionLengthRange = { min: 1, max: 20 }
const descriptionLengthRange = { min: 20, max: 1000 }


/**
 * 
 * @param {express.Express} app 
 */
function init(app)
{
    app.post("/api/widget", uploadHandler.fields([{name: "back-end", maxCount: 1},{name: "front-end", maxCount: 1}]), (req, res, next) => {
        if(areFilesValid(req.files))
        {
            if(!isInRange(req.body.name, nameLengthRange))
                res.status(400).send("Name out of bounds.");
            else if(!isInRange(req.body.version, versionLengthRange))
                res.status(400).send("Version out of bounds.");
            else if(!isInRange(req.body.description, descriptionLengthRange))
                res.status(400).send("Description out of bounds.");
            else
                res.status(200).send("🎉");
        }
        else
        {
            res.status(400).send("Invalid files.");
        }
    });
}

/**
 * 
 * @param {String} toCheck 
 * @param {*} range 
 */
function isInRange(toCheck, range)
{
    return (toCheck.length >= range.min) && (toCheck.length <= range.max);
}

/**
 * 
 * @param {Express.Multer.File[]} files 
 */
function areFilesValid(files)
{
    let fileCount = 0;
    for(let fieldName in files)
    {
        fileCount++;
        let file = files[fieldName][0];
        if(file.mimetype != "application/x-zip-compressed")
            return false;
    }

    return fileCount === expectedFiles;
}