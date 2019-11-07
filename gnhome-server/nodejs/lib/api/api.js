const express = require("express");
const gnhomeInterface = require("gnhome-interface");
const Response = gnhomeInterface.Response;

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
            name: widget.name,
            description: widget.description,
            version: widget.version,
            status: this.parseResponseToObject(widget.status),
            html: this.parseResponseToObject(widget.widgetHTML),
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
}

module.exports = API