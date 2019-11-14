const express = require("express");
const gnhomeInterface = require("gnhome-interface");
const Response = gnhomeInterface.Response;
const Size = gnhomeInterface.Widget.Size;

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
            active: widget.active,
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
     * @param {String} name
     * @param {Boolean} value 
     */
    setWidgetActive(name, value)
    {
        let success = false;
        const widgetList = gnhomeInterface.getWidgetList();
        if(widgetList[name])
        {
            widgetList[name].active = value;
            success = true;
        }
        console.log("Bwa");
        return success;
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