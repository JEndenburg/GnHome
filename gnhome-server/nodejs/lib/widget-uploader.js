module.exports = init;

const multer = require("multer");
const express = require("express");
const fs = require("fs");
const admZip = require("adm-zip");

const uploadHandler = multer();

const expectedFiles = 2;
const fileMaxSize = 1000000;

const locations = {
    "back-end" : "\\widgets",
    "front-end" : "\\site\\static\\widget",
}

const secret = "panda";//Math.round(Math.random() * 1000000000).toString("16");
console.log("Secret for this session is " + secret);


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
        let validationResult = -3;
        if((validationResult = areFilesValid(req.files)) === 0)
        {
            try
            {
                const uuid = BigInt(req.body.id);
                if(!isValidAuthentication(uuid, req.body.auth))
                    res.status(403).render("pages/uploading/invalid-auth.ejs");
                else
                {
                    try
                    {
                        saveFiles(req.files, root, uuid, () => {
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
            catch(ex)
            {
                res.status(400).render("pages/uploading/invalid-auth.ejs");
            }
        }
        else
        {
            if(validationResult == -2)
                res.status(400).render("pages/uploading/too-big.ejs");
            else
                res.status(400).render("pages/uploading/invalid-file.ejs");
        }
    });
}

/**
 * 
 * @param {BigInt} uuid 
 * @param {String} authenticationSecret 
 */
function isValidAuthentication(uuid, authenticationSecret)
{
    return authenticationSecret == secret;
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
        console.log(file);
        if(file.mimetype != "application/x-zip-compressed" && file.mimetype != "application/zip")
            return -1;
        else if(file.size > fileMaxSize)
            return -2;
    }

    return (fileCount === expectedFiles) ? 0 : -1;
}

/**
 * 
 * @param {Express.Multer.File[]} files 
 * @param {String} rootFolder
 * @param {BigInt} uuid
 * @param {Function} callback
 */
function saveFiles(files, rootFolder, uuid, callback)
{
    for(let fieldName in files)
    {
        let stream = null;
        let location = rootFolder + locations[fieldName] + "\\" + uuid.toString();
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