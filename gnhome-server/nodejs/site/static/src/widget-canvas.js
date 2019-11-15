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
     */
    constructor(observerTarget)
    {
        super(observerTarget);
        this._observer = new MutationObserver((m,o) => this.updateWidgetList());
        this._observer.observe(observerTarget,
            {
                childList: true,
                subtree : true,
            });

        this._widgetList = [];
        this._focusWidget = null;
        this._elementBeingDragged = false;
        this._mouseRelativeX = 0;
        this._mouseRelativeY = 0;
        observerTarget.onmousedown = (e) => this.onMouseDown(e);
    }

    /**
     * @returns {WidgetWindow[]}
     */
    get widgetList()
    {
        return this._widgetList;
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
            if(!this.isElementPositioned(widget))
                this.positionElementToCenterOfScreen(widget);
            this._widgetList[index] = new WidgetWindow(widget, this);
            this.setFocus(this._widgetList[index]);
            index++;
        }
    }

    /**
     * 
     * @param {Element} element 
     */
    isElementPositioned(element)
    {
        return element.style.left.endsWith("px");
    }

    /**
     * 
     * @param {Element} element 
     */
    positionElementToCenterOfScreen(element)
    {
        const centerX = (document.body.offsetWidth / 2) + document.body.offsetLeft;
        const centerY = (document.body.offsetHeight / 2) + document.body.offsetTop;
        const elementCenterX = (element.offsetWidth / 2) + element.offsetLeft;
        const elementCenterY = (element.offsetHeight / 2) + element.offsetTop;
        element.style.left = (centerX - elementCenterX) + "px";
        element.style.top = (centerY - elementCenterY) + "px";
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
            event.preventDefault();
            this.blockedWidgets = true;
            this._mouseRelativeX = event.clientX;
            this._mouseRelativeY = event.clientY;
            this._element.classList.add("grabbed");
            document.onmousemove = (e) => this.onMouseMove(e);
            document.onmouseup = (e) => this.onMouseUp(e);
        }
    }

    /**
     * 
     * @param {MouseEvent} event 
     */
    onMouseMove(event)
    {
        this.moveBy(event.clientX - this._mouseRelativeX, event.clientY - this._mouseRelativeY);
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
        this.blockedWidgets = false;
        this._element.classList.remove("grabbed");
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
}