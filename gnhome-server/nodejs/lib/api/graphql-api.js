const express = require("express");
const API = require("./api");
const graphqlHTTP = require("express-graphql");
const { buildSchema } = require("graphql");

const schema = buildSchema(`

type Mutation
{
    setWidgetState(userUUID: String! widgetUUID: String! x: Float! y: Float! z: Float!): MutationResponse
    deleteWidgetState(userUUID: String! widgetUUID: String!): MutationResponse
}

type Query
{
    main: PDA!
    getWidget(name: String!): Widget
    getUser(uuid: String!): UserResponse
    getWidgetState(userUUID: String!) : WidgetStateResponse
}

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
            getWidget: (args) => super.getWidgetByName(args.name),
            main: (args) => super.getPDA(),
            getUser: (args) => super.getUserById(BigInt(args.uuid)),
            getWidgetState: (args) => super.getWidgetUserStates(BigInt(args.userUUID)),
            setWidgetState: (args) => super.setWidgetUserState(BigInt(args.userUUID), BigInt(args.widgetUUID), args.x, args.y, args.z),
            deleteWidgetState: (args) => super.deleteWidgetUserState(BigInt(args.userUUID), BigInt(args.widgetUUID)),
        }
    }
}


module.exports = APIGraphQL;