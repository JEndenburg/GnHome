module.exports = init;

const multer = require("multer");
const express = require("express");
const fs = require("fs");
const admZip = require("adm-zip");

const uploadHandler = multer();

const expectedFiles = 2;
const nameLengthRange = { min: 4, max: 30 };
const versionLengthRange = { min: 1, max: 20 }
const descriptionLengthRange = { min: 20, max: 1000 }

const locations = {
    "back-end" : "\\widgets",
    "front-end" : "\\site\\static\\widget",
}


/**
 * 
 * @param {express.Express} app 
 * @param {String} root
 * @param {Function} callback
 */
function init(app, root, callback)
{
    let finishedFiled = 0;
    app.post("/api/widget", uploadHandler.fields([{name: "back-end", maxCount: 1},{name: "front-end", maxCount: 1}]), (req, res, next) => {
        if(areFilesValid(req.files))
        {
            if(!isInRange(req.body.name, nameLengthRange))
                res.status(400).render("pages/uploading/invalid-auth.ejs");

            else if(!isInRange(req.body.version, versionLengthRange))
                res.status(400).render("pages/uploading/invalid-auth.ejs");

            else if(!isInRange(req.body.description, descriptionLengthRange))
                res.status(400).render("pages/uploading/invalid-auth.ejs");

            else
            {
                try
                {
                    saveFiles(req.files, root, () => {
                        finishedFiled++;

                        if(finishedFiled === expectedFiles)
                            callback();
                    });
                    res.status(200).render("pages/uploading/success.ejs");
                }
                catch(exception)
                {
                    res.status(500).send("An internal server error occured:<br/>" + exception);
                }
            }
        }
        else
        {
            res.status(400).render("pages/uploading/invalid-file.ejs");
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

/**
 * 
 * @param {Express.Multer.File[]} files 
 * @param {String} rootFolder
 * @param {Function} callback
 */
function saveFiles(files, rootFolder, callback)
{
    for(let fieldName in files)
    {
        let stream = null;
        let location = rootFolder + locations[fieldName] + "\\1337";
        let fileLocation = location + "\\temp.zip";
        
        if(!fs.existsSync(location))
        fs.mkdirSync(location);

        stream = fs.createWriteStream(fileLocation);

        stream.on("ready", (fd) => {
            stream.write(files[fieldName][0].buffer, (e) => {});
            stream.end();
        });

        stream.on("close", () => {
            unzipFile(location, fileLocation);
            callback();
        });
    }
}

/**
 * 
 * @param {String} folderLocation 
 * @param {String} fileLocation 
 */
function unzipFile(folderLocation, fileLocation)
{
    const zipFile = new admZip(fileLocation);
    zipFile.extractAllTo(folderLocation, true);
}