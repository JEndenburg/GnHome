const express = require("express");
const gnhomeInterface = require("gnhome-interface");
const mariadb = require("mariadb");
const fs = require("fs");
const Response = gnhomeInterface.Response;
const Size = gnhomeInterface.Widget.Size;

const dbpool = mariadb.createPool(JSON.parse(fs.readFileSync(__dirname + "\\mariadb.credentials")));

class API
{
    constructor()
    {
    }

    getPDA()
    {
        return {
            widgets: this.getWidgets(),
        };
    }

    /**
     * 
     * @param {String} name 
     * @param {gnhomeInterface.widgetList}
     */
    getWidgetByName(name, widgetList = gnhomeInterface.getWidgetList())
    {
        if(widgetList[name] == undefined)
            return null;
        
        const widget = widgetList[name];
        return {
            uuid: widget.uuid,
            name: widget.name,
            description: widget.description,
            version: widget.version,
            status: this.parseResponseToObject(widget.status),
            size: this.parseSizeToObject(widget.size),
        };
    }

    getWidgets()
    {
        let widgets = [];
        const widgetList = gnhomeInterface.getWidgetList();
        let index = 0;

        for(let name in widgetList)
        {
            widgets[index] = this.getWidgetByName(name, widgetList);
            index++;
        }

        return widgets;
    }

    /**
     * @param {BigInt} userUUID 
     */
    async getUserById(userUUID)
    {
        let connection = null;
        let response = {
            statusCode: 500,
            statusMessage: "Internal Server Error",
            data: null,    
        };

        try
        {
            connection = await dbpool.getConnection();
            let result = await connection.query("SELECT * FROM User WHERE id=" + userUUID);

            if(result.length > 0)
            {
                let data = {
                    uuid: result[0].id.toString(),
                    firstName: result[0].first_name,
                    lastName: result[0].last_name,
                };

                response = {
                    statusCode: 200,
                    statusMessage: "OK",
                    data: data,
                };
            }
            else
            {
                response = {
                    statusCode: 404,
                    statusMessage: "Not Found",
                    data: null,
                }
            }
        }
        catch(ex)
        {
        }
        finally
        {
            if(connection != null)
                await connection.end();
        }

        return response;
    }

    /**
     * @param {BigInt} userUUID 
     */
    async getWidgetUserStates(userUUID)
    {
        let connection = null;
        let response = {
            statusCode: 500,
            statusMessage: "Internal Server Error",
            data: null,    
        };

        try
        {
            connection = await dbpool.getConnection();
            let result = await connection.query("SELECT * FROM Widget_State WHERE owner_id=" + userUUID);

            let data = [];

            for(let i = 0; i < result.length; i++)
            {
                data[i] = {
                    uuid: result[i].widget_id.toString(),
                    position: { x: result[i].pos_x, y: result[i].pos_y, z: result[i].pos_z },
                };
            }

            response = {
                statusCode: 200,
                statusMessage: "OK",
                data: data,
            };
        }
        catch(ex)
        {
        }
        finally
        {
            if(connection != null)
                await connection.end();
        }

        return response;
    }

    /**
     * @param {BigInt} userUUID 
     * @param {BigInt} widgetUUID 
     * @param {Number} xPos
     * @param {Number} yPos
     * @param {Number} zPos
     */
    async setWidgetUserState(userUUID, widgetUUID, xPos, yPos, zPos)
    {
        let connection = null;
        let response = {
            statusCode: 500,
            statusMessage: "Internal Server Error",
        };

        try
        {
            connection = await dbpool.getConnection();
            let result;
            if(await this.doesWidgetStateExist(userUUID, widgetUUID, connection))
                result = await connection.query(`UPDATE Widget_State SET pos_x=${xPos}, pos_y=${yPos}, pos_z=${zPos} WHERE owner_id=${userUUID} AND widget_id=${widgetUUID}`);
            else
                result = await connection.query(`INSERT INTO Widget_State VALUES (${widgetUUID}, ${userUUID}, ${widgetUUID}, ${xPos}, ${yPos}, ${zPos})`);

            if(result.affectedRows > 0)
            {
                response = {
                    statusCode: 200,
                    statusMessage: "OK",
                };
            }
            else
            {
                response = {
                    statusCode: 400,
                    statusMessage: "Bad Request",
                }
            }
        }
        catch(ex)
        {
            console.log(ex);
        }
        finally
        {
            if(connection != null)
                await connection.end();
        }

        return response;
    }

    /**
     * @param {BigInt} userUUID 
     * @param {BigInt} widgetUUID 
     */
    async deleteWidgetUserState(userUUID, widgetUUID)
    {
        let connection = null;
        let response = {
            statusCode: 500,
            statusMessage: "Internal Server Error",
        };

        try
        {
            connection = await dbpool.getConnection();
            let result;
            result = await connection.query(`DELETE FROM Widget_State WHERE owner_id=${userUUID} AND widget_id=${widgetUUID}`);

            if(result.affectedRows > 0)
            {
                response = {
                    statusCode: 200,
                    statusMessage: "OK",
                };
            }
            else
            {
                response = {
                    statusCode: 404,
                    statusMessage: "Not Found",
                }
            }
        }
        catch(ex)
        {
            console.log(ex);
        }
        finally
        {
            if(connection != null)
                await connection.end();
        }

        return response;
    }

    /**
     * @param {BigInt} userUUID 
     * @param {BigInt} widgetUUID 
     * @param {mariadb.PoolConnection} connection
     */
    async doesWidgetStateExist(userUUID, widgetUUID, connection)
    {
        let result = await connection.query(`SELECT * FROM Widget_State WHERE owner_id=${userUUID} AND widget_id=${widgetUUID}`);
        return (result.length > 0)
    }

    /**
     * 
     * @param {Response} response 
     */
    parseResponseToObject(response)
    {
        return {
            statusCode: response.status,
            statusMessage: response.message,
            responseJson: JSON.stringify(response.content),
        };
    }

    /**
     * 
     * @param {Size} size 
     */
    parseSizeToObject(size)
    {
        return {
            width: size.width,
            height: size.height,
        };
    }
}

module.exports = API