const express = require("express");
const graphqlHTTP = require("express-graphql");
const { buildSchema } = require("graphql");

const schema = buildSchema(`

type Query
{
    main: PDA!
    widget(name: String!): Widget
}

type PDA
{
    widgets: [Widget]!
}

type Widget
{
    name: String
}

`);

const root = 
{
    widget: (args) => getWidget(args),
    main: (args) => getPDA(args),
};

function getWidget(arg) { return getWidgetByName(arg.name); };

function getPDA(arg) { return {
    widgets: () => {
        let widgets = [];
        let actualWidgets = this.getWidgetList();
        let wi = 0;
        for(let widgetName in actualWidgets)
        {
            widgets[wi] = getWidgetByName(widgetName, actualWidgets);
            wi++;
        }
        return widgets;
    },
}};

function getWidgetByName(name, widgetList = this.getWidgetList())
{
    if(widgetList[name] == undefined)
        return null;

    return {
        name: name,
    };
}

/** @returns {Object.<string, import("gnhome-interface")>} */
let getWidgetList = () => {};

/**
 * 
 * @param {express.Express} app 
 * @param {Function} getWidgetList
 */
function init(app, getWidgetList)
{
    this.getWidgetList = getWidgetList;

    app.use("/api/graphql", graphqlHTTP({
        schema: schema,
        rootValue: root,
        graphiql: true,
    }));
}

module.exports = init;