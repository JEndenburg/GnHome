class CanvasObject
{
    /**
     * 
     * @param {HTMLElement} element 
     */
    constructor(element)
    {
        this._element = element;
        this._x = Number(element.style.left.substr(0, element.style.left.length - 2));
        this._y = Number(element.style.top.substr(0, element.style.top.length - 2));
    }

    /**
     * 
     * @param {Number} x
     * @param {Number} y 
     */
    moveBy(x, y)
    {
        this._x += x;
        this._y += y;
        this.updateStylePosition();
    }
    
    updateStylePosition()
    {
        this._element.style.left = this._x + "px";
        this._element.style.top = this._y + "px";
    }

    /**
     * @returns {HTMLElement}
     */
    get element()
    {
        return this._element;
    }

    get x()
    {
        return this._x;
    }

    get y()
    {
        return this._y;
    }
}

class WidgetCanvas extends CanvasObject
{
    /**
     * 
     * @param {HTMLElement} observerTarget 
     * @param {bigint} userUUID
     */
    constructor(observerTarget, userUUID)
    {
        super(observerTarget);
        this._observer = new MutationObserver((m,o) => this.updateWidgetList());
        this._observer.observe(observerTarget,
            {
                childList: true,
                subtree : true,
            });

        this._user = userUUID;
        this._widgetList = [];
        this._focusWidget = null;
        this._elementBeingDragged = false;
        this._mouseRelativeX = 0;
        this._mouseRelativeY = 0;

        this._speed = { x: 0, y: 0 };
        this._mouseVelocity = { x: 0, y: 0 }
        this._friction = 1.0;
        this._maxSpeed = 15;
        this._acceleration = 1.5;
        this._active = true;

        this._keysPressed = {
            up: false,
            left: false,
            down: false,
            right: false,
            mouse: false,
        };
        observerTarget.onmousedown = (e) => this.onMouseDown(e);
        document.onkeydown = (e) => this.onKeyPress(e, true);
        document.onkeyup = (e) => this.onKeyPress(e, false);
        setInterval(() => this.update(), 10);
    }

    /**
     * @returns {WidgetWindow[]}
     */
    get widgetList()
    {
        return this._widgetList;
    }

    get userUUID()
    {
        return this._user;
    }

    updateWidgetList()
    {
        const widgetElements = document.querySelectorAll(".widget");

        for(let widget of this.widgetList)
        {
            widget.detach();
        }

        this._widgetList = [];

        let index = 0;
        for(let widget of widgetElements)
        {
            this._widgetList[index] = new WidgetWindow(widget, this);
            this.setFocus(this._widgetList[index]);
            index++;
        }
    }
    
    /**
     * @param {boolean} value
     */
    set blockedWidgets(value)
    {
        for(let widget of this.widgetList)
        {
            widget.blocked = value;
        }
        this._elementBeingDragged = value;
    }

    setFocus(widget)
    {
        if(this._focusWidget != widget)
        {
            let oldZIndex = widget.zIndex;
            for(let w of this.widgetList)
            {
                if(w != widget)
                {
                    if(w.zIndex > oldZIndex)
                        w.zIndex = w.zIndex - 1;
                    w.elementDragBar.classList.remove("focus");
                }
            }
            widget.zIndex = this._widgetList.length - 1;
            widget.elementDragBar.classList.add("focus");
            this._focusWidget = widget;
        }
    }

    /**
     * 
     * @param {MouseEvent} event 
     */
    onMouseDown(event)
    {
        if(!this._elementBeingDragged)
        {
            this.blockedWidgets = true;
            this._mouseRelativeX = event.clientX;
            this._mouseRelativeY = event.clientY;
            this._element.classList.add("grabbed");
            document.onmousemove = (e) => this.onMouseMove(e);
            document.onmouseup = (e) => this.onMouseUp(e);

            this._speed.x = this._speed.y = 0;
            this._keysPressed.mouse = true;
        }
    }

    /**
     * 
     * @param {MouseEvent} event 
     */
    onMouseMove(event)
    {
        this._mouseVelocity.x = event.clientX - this._mouseRelativeX;
        this._mouseVelocity.y = event.clientY - this._mouseRelativeY;
        this.moveBy(this._mouseVelocity.x, this._mouseVelocity.y);
        this._mouseRelativeX = event.clientX;
        this._mouseRelativeY = event.clientY;
    }

    /**
     * 
     * @param {MouseEvent} event 
     */
    onMouseUp(event)
    {
        document.onmouseup = document.onmousemove = null;

        this._speed.x = this._mouseVelocity.x;
        this._speed.y = this._mouseVelocity.y;
        this._keysPressed.mouse = false;

        this.blockedWidgets = false;
        this._element.classList.remove("grabbed");
    }

    /**
     * 
     * @param {KeyboardEvent} event 
     * @param {Boolean} isPressedDown
     */
    onKeyPress(event, isPressedDown)
    {
        if(!this._active || this._keysPressed.mouse)
        {
            this._keysPressed.left =
                this._keysPressed.right =
                this._keysPressed.up =
                this._keysPressed.down =
                false;
            return;
        }

        switch(event.keyCode)
        {
            case 37:
                this._keysPressed.left = isPressedDown;
                break;
            case 38:
                this._keysPressed.up = isPressedDown;
                break;
            case 39:
                this._keysPressed.right = isPressedDown;
                break;
            case 40:
                this._keysPressed.down = isPressedDown;
                break;
            case 32:
                this._speed.x = this._speed.y = 0;
                break;
            case 36:
                this.moveBy(-this.x, -this.y);
                break;
        }
    }

    update()
    {
        this._active = document.getElementById("modal-popup") == null;
        this.handleInputVelocity();
        this.updateVelocity();
        this._mouseVelocity.x = this._mouseVelocity.y = 0;
    }

    handleInputVelocity()
    {
        if(this._keysPressed.left && this._speed.x < this._maxSpeed)
            this._speed.x += this._acceleration;
        if(this._keysPressed.up && this._speed.y < this._maxSpeed)
            this._speed.y += this._acceleration;
        if(this._keysPressed.right && this._speed.x > -this._maxSpeed)
            this._speed.x -= this._acceleration;
        if(this._keysPressed.down && this._speed.y > -this._maxSpeed)
            this._speed.y -= this._acceleration;
    }

    updateVelocity()
    {
        this.moveBy(this._speed.x, this._speed.y);
        if(this._elementBeingDragged)
            this._focusWidget.moveBy(-this._speed.x, -this._speed.y);

        let signatureOfSpeed = { x: Math.sign(this._speed.x), y: Math.sign(this._speed.y) };
        if(!this._keysPressed.left && !this._keysPressed.right)
            this._speed.x -= this._friction * signatureOfSpeed.x;
        if(!this._keysPressed.up && !this._keysPressed.down)
            this._speed.y -= this._friction * signatureOfSpeed.y;

        if(Math.sign(this._speed.x) != signatureOfSpeed.x)
            this._speed.x = 0;
        if(Math.sign(this._speed.y) != signatureOfSpeed.y)
            this._speed.y = 0;
    }

    /**
     * 
     * @param {Number} x
     * @param {Number} y 
     */
    moveBy(x, y)
    {
        for(let widget of this.widgetList)
        {
            widget.moveBy(x, y);
        }
        this._x += x;
        this._y += y;
        this.updateStylePosition();
    }
    
    updateStylePosition()
    {
        document.body.style.backgroundPositionX = this._x + "px";
        document.body.style.backgroundPositionY = this._y + "px";
    }
}

class WidgetWindow extends CanvasObject
{
    /**
     * 
     * @param {HTMLElement} widgetElement 
     * @param {WidgetCanvas} canvas
     */
    constructor(widgetElement, canvas)
    {
        super(widgetElement);
        this._uuid = BigInt(widgetElement.id.substr(2));
        this._elementDragBar = widgetElement.querySelector(".widget-bar");
        this._elementFrameBlocker = widgetElement.querySelector(".blocker");
        this._canvas = canvas;
        this._mouseRelativeX = 0;
        this._mouseRelativeY = 0;

        this.attach();
    }

    /**
     * @returns {HTMLElement}
     */
    get elementDragBar()
    {
        return this._elementDragBar;
    }

    /**
     * @returns {HTMLElement}
     */
    get element()
    {
        return this._element;
    }

    attach()
    {
        this.elementDragBar.onmousedown = (e) => this.onDragBarMouseDown(e);
        this.element.onmousedown = (e) => this.onMouseDown(e);
    }

    detach()
    {
        this.elementDragBar.onmousedown = null;
        this.element.onmousedown = null;
    }

    /**
     * 
     * @param {MouseEvent} event 
     */
    onMouseDown(event)
    {
        this._canvas.setFocus(this);
    }

    /**
     * 
     * @param {MouseEvent} event 
     */
    onDragBarMouseDown(event)
    {
        event.preventDefault();
        this._mouseRelativeX = event.clientX;
        this._mouseRelativeY = event.clientY;
        document.onmousemove = (e) => this.onDragBarMouseMove(e);
        document.onmouseup = (e) => this.onDragBarMouseUp(e);
        this._canvas.blockedWidgets = true;
    }

    /**
     * 
     * @param {MouseEvent} event 
     */
    onDragBarMouseMove(event)
    {
        super.moveBy(event.clientX - this._mouseRelativeX, event.clientY - this._mouseRelativeY);
        this._mouseRelativeX = event.clientX;
        this._mouseRelativeY = event.clientY;
    }

    /**
     * 
     * @param {MouseEvent} event 
     */
    onDragBarMouseUp(event)
    {
        document.onmouseup = document.onmousemove = null;
        this._canvas.blockedWidgets = false;
        this.updatePosition();
    }

    /**
     * @param {boolean} value
     */
    set blocked(value)
    {
        this._elementFrameBlocker.style.display = value ? "block" : "none";
    }

    /**
     * @param {Number} value
     */
    set zIndex(value)
    {
        this._element.style.zIndex = value.toString();
    }

    /**
     * @returns {Number}
     */
    get zIndex()
    {
        return Number(this._element.style.zIndex);
    }

    async updatePosition()
    {
        let userUUID = this._canvas.userUUID;
        let x = this.x - this._canvas.x;
        let y = this.y - this._canvas.y;
        let response = await fetch("/api/graphql", {
            method: "POST",
            headers: { "content-type": "application/json" },
            body: JSON.stringify({query : `mutation{setWidgetState(userUUID:\"${userUUID}\"widgetUUID:\"${this._uuid}\"x:${x}y:${y}z:${this.zIndex}){statusCode}}`}),
        });
    }
}