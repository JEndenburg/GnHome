

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
     * @param {String} queryContent 
     * @param {Function} callback 
     */
    constructor(queryName, queryContent, callback)
    {
        this._queryName = queryName;
        this._queryContent = queryContent;
        this._callback = callback;
    }

    get queryName()
    {
        return this._queryName;
    }

    get queryContent()
    {
        return this._queryContent;
    }

    call(params) { return this._callback(params); }
}

class GraphQLType
{
    /**
     * 
     * @param {String} typeName 
     * @param {String} typeContents 
     * @param {Function} callback
     */
    constructor(typeName, typeContents, callback)
    {
        this._typeName = typeName;
        this._typeContents = typeContents;
        this._callback = callback;
    }

    get name()
    {
        return this._typeName;
    }

    get contents()
    {
        return this._typeContents;
    }

    call(params) { return this._callback(params); }
}

exports = module.exports = Schema;
exports.GraphQLQuery = GraphQLQuery;
exports.GraphQLType = GraphQLType;