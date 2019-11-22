const gnhomeInterface = require("gnhome-interface");
const net = require("net");

class ChatWidget extends gnhomeInterface.Widget
{
    constructor()
    {
        const schema = new gnhomeInterface.Widget.Schema([], [], []);
        super(528324727, "WebChat", "0.0.1", "Find new friends, talk with old ones.", new gnhomeInterface.Widget.Size(500, 400), schema);

        this._clients = [];
        this._server = net.createServer((socket) => this.onConnected(socket));
        this._server.listen(9000);
    }

    /**
     * 
     * @param {net.Socket} socket 
     */
    onConnected(socket)
    {
        socket.write("REQ $username");
        socket.on("close", () => this.onDisconnected(socket));
        socket.on("data", (buffer) => this.onMessageReceived(socket, buffer));
        socket.on("error", () => {});
        this.clients.push(socket);
    }

    /**
     * @param {net.Socket} socket 
     */
    onDisconnected(socket)
    {
        this._clients = this.clients.filter((element) => { return element !== socket });
        socket.end();
    }

    /**
     * 
     * @param {net.Socket} socket 
     * @param {Buffer} buffer 
     */
    onMessageReceived(socket, buffer)
    {

    }

    get status()
    {
        return this.createResponse(200, "OK", {});
    }

    /**
     * @returns {net.Socket[]}
     */
    get clients()
    {
        return this._clients;
    }
}

gnhomeInterface.registerWidget(new ChatWidget());