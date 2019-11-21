

class Schema
{
    /**
     * 
     * @param {GraphQLQuery[]} queries 
     * @param {GraphQLQuery[]} mutations 
     * @param {GraphQLType[]} types 
     */
    constructor(queries, mutations, types)
    {
        this._queries = queries;
        this._mutations = mutations;
        this._types = types;
    }

    get queries() { return this._queries; }
    get mutations() { return this._mutations; }
    get types() { return this._types; }
}

class GraphQLQuery
{
    /**
     * @param {String} queryName
     * @param {String} returnType 
     * @param {Function} callback 
     */
    constructor(queryName, returnType, callback)
    {
        this._queryName = queryName;
        this._returnType = returnType;
        this._callback = callback;
    }

    get queryName()
    {
        return this._queryName;
    }

    get returnType()
    {
        return this._returnType;
    }

    call(params) { return this._callback(params); }
}

class GraphQLType
{
    /**
     * 
     * @param {String} typeName 
     * @param {String[]} typeContents 
     */
    constructor(typeName, typeContents)
    {
        this._typeName = typeName;
        this._typeContents = typeContents;
    }

    get name()
    {
        return this._typeName;
    }

    get contents()
    {
        return this._typeContents;
    }
}

exports = module.exports = Schema;
exports.GraphQLQuery = GraphQLQuery;
exports.GraphQLType = GraphQLType;