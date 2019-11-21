const express = require("express");
const API = require("./api");
const graphqlHTTP = require("express-graphql");
const { buildSchema } = require("graphql");
const gnhomeInterface = require("gnhome-interface");

const defaultMutations = `
type Mutation
{
    setWidgetState(userUUID: String! widgetUUID: String! x: Float! y: Float! z: Float!): MutationResponse
    deleteWidgetState(userUUID: String! widgetUUID: String!): MutationResponse
`;

const defaultQueries = `
type Query
{
    main: PDA!
    getWidget(name: String!): Widget
    getUser(uuid: String!): UserResponse
    getWidgetState(userUUID: String!) : WidgetStateResponse
`

const schemaString = `
type PDA
{
    widgets: [Widget]!
}

type Widget
{
    uuid: Int
    name: String
    version: String
    description: String
    status: Response
    size: Size
}

type Response
{
    statusCode: Int
    statusMessage: String
    responseJson: String
}

type Size
{
    width: Int
    height: Int
}

type UserResponse
{
    statusCode: Int
    statusMessage: String
    data: User
}

type User
{
    uuid: String
    firstName: String
    lastName: String
}

type WidgetStateResponse
{
    statusCode: Int
    statusMessage: String
    data: [WidgetState]
}

type WidgetState
{
    uuid: String
    position: Position
}

type Position
{
    x: Float
    y: Float
    z: Float
}

type MutationResponse
{
    statusCode: Int
    statusMessage: String
}

`;

class APIGraphQL extends API
{
    /**
     * 
     * @param {express.application} expressApp 
     */
    constructor(expressApp)
    {
        super();

        this._root = {
            getWidget: (args) => super.getWidgetByName(args.name),
            main: (args) => super.getPDA(),
            getUser: (args) => super.getUserById(BigInt(args.uuid)),
            getWidgetState: (args) => super.getWidgetUserStates(BigInt(args.userUUID)),
            setWidgetState: (args) => super.setWidgetUserState(BigInt(args.userUUID), BigInt(args.widgetUUID), args.x, args.y, args.z),
            deleteWidgetState: (args) => super.deleteWidgetUserState(BigInt(args.userUUID), BigInt(args.widgetUUID)),
        }

        const widgetList = gnhomeInterface.getWidgetList();

        let schema = schemaString;

        schema += defaultQueries;
        for(let widgetName in widgetList)
        {
            const widget = widgetList[widgetName];
            for(let query of widget.schema.queries)
            {
                const queryName = `widget_${widget.uuid}__${query.queryName}`;
                schema += `${queryName} : ${query.returnType}\n`;
                this._root[queryName] = (args) => query.call(args);
            }
        }
        schema += "}";

        schema += defaultMutations;
        for(let widgetName in widgetList)
        {
            const widget = widgetList[widgetName];
            for(let mutation of widget.schema.mutations)
            {
                const queryName = `widget_${widget.uuid}__${mutation.queryName}`;
                schema += `${queryName} : ${mutation.returnType}\n`;
                this._root[queryName] = (args) => mutation.call(args);
            }
        }
        schema += "}";

        for(let widgetName in widgetList)
        {
            const widget = widgetList[widgetName];
            for(let type_ of widget.schema.types)
            {
                schema += `
                type ${type_.name}
                {`;
                for(let content of type_.contents)
                    schema += `    ${content}\n`;
                schema += `
                }`
            }
        }
        expressApp.use("/api/graphql", graphqlHTTP({
            schema: buildSchema(schema),
            rootValue: this.root,
            graphiql: true,
        }));
    }
    
    get root()
    {
        return this._root;
    }
}


module.exports = APIGraphQL;