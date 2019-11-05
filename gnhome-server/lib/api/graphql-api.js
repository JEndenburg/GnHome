const express = require("express");
const API = require("./api");
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
    version: String
    description: String
    status: Status
}

type Status
{
    statusCode: Int
    statusMessage: String
    responseJson: String
}

`);

class APIGraphQL extends API
{
    /**
     * 
     * @param {express.application} expressApp 
     */
    constructor(expressApp)
    {
        super();
        expressApp.use("/api/graphql", graphqlHTTP({
            schema: schema,
            rootValue: this.root,
            graphiql: true,
        }));
    }
    
    get root()
    {
        return {
            widget: (args) => super.getWidgetByName(args.name),
            main: (args) => super.getPDA(),
        }
    }
}


module.exports = APIGraphQL;