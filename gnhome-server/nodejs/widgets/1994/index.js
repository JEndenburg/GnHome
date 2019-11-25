const gnhomeInterface = require("gnhome-interface");

class RecipeGoWidget extends gnhomeInterface.Widget
{
    constructor()
    {
        const schema = new gnhomeInterface.Widget.Schema([], [], []);
        super(1994, "Recipe & Go", "0.0.1", "Find your favourite recipes!", new gnhomeInterface.Widget.Size(600, 300), schema);
    }

    get status()
    {
        return this.createResponse(200, "OK", {});
    }
}

gnhomeInterface.registerWidget(new RecipeGoWidget());