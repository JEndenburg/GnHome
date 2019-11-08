

class Size
{
    constructor(width = 200, height = 150)
    {
        this._width = width;
        this._height = height;
    }

    get width() { return this._width; }
    get height() { return this._height; }
}

module.exports = Size;