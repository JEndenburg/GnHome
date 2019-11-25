const gnhomeInterface = require("gnhome-interface");
const ws = require("ws");

class ChatWidget extends gnhomeInterface.Widget
{
    constructor()
    {
        const port = 9000;
        const schema = new gnhomeInterface.Widget.Schema([], [], []);
        super(528324727, "WebChat", "0.0.1", "Find new friends, talk with old ones.", new gnhomeInterface.Widget.Size(500, 400), schema);

        this._clients = [];
        this._history = [];
        this._server = new ws.Server({ port: port }, () => console.log(`Chat server listening on ${port}`));
        this._server.on("connection", (client, req) => this.onClientConnected(client, req));
    }

    onClientConnected(client, req)
    {
        const ip = req.connection.remoteAddress;
        client.on("message", (message) => this.onMessageReceived(ip, message));
        client.on("close", () => this.onClientDisconnected(ip));
        console.log(`CW: [${ip}] connected.`);
        client.send("REQUEST $username");
        this._clients.push({
            ip: ip,
            socket: client,
            username: null,
        });
    }

    onClientDisconnected(ip)
    {
        for(let i = 0; i < this._clients.length; i++)
        {
            let client = this._clients[i];
            if(client.ip === ip)
            {
                this._clients.splice(i, 1);
                break;
            }
        }
        console.log(`CW: [${ip}] disconnected.`);
    }

    /**
     * @param {String} message 
     */
    onMessageReceived(ip, message)
    {
        const splitMessage = message.split(/\s/);
        this.handleCommand(ip, splitMessage[0], splitMessage.slice(1, splitMessage.length));
    }
    
    handleCommand(ip, command, params)
    {
        switch(command)
        {
            case "RECEIVE": this.acceptResource(ip, params[0], params.slice(1, params.length).join(' ')); break;
            case "REQUEST": this.onRequestCommand(ip, params[0]); break;
        }
    }

    onRequestCommand(ip, requestedResource)
    {
        let currentClient = this.getClientFromIP(ip);
        switch(requestedResource)
        {
            default: currentClient.socket.send("INVALID"); break;
            case "$history": currentClient.socket.send("RECEIVE $history " + JSON.stringify(this._history)); break;
        }
    }

    acceptResource(ip, resourceType, resourceContent)
    {
        let currentClient = this.getClientFromIP(ip);
        switch(resourceType)
        {
            default: currentClient.socket.send("INVALID"); break;
            case "$username": currentClient.username = resourceContent; currentClient.socket.send("WELCOME"); break;
            case "$message": this.acceptMessage(currentClient, resourceContent); break;
        }
    }

    acceptMessage(client, message)
    {
        const date = new Date();
        const storedMessage = {
            author: client.username,
            timestamp: date.toISOString(),
            content: message,
        };

        this._history.push(storedMessage);

        for(let c of this._clients)
            c.socket.send("RECEIVE $message " + JSON.stringify(storedMessage));
    }

    getClientFromIP(ip)
    {
        for(let client of this._clients)
        {
            if(client.ip === ip)
                return client;
        }
        return null;
    }

    get status()
    {
        return this.createResponse(200, "OK", {});
    }
}

gnhomeInterface.registerWidget(new ChatWidget());