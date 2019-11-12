class WidgetCanvas
{
    /**
     * 
     * @param {HTMLElement} observerTarget 
     */
    constructor(observerTarget)
    {
        this._observer = new MutationObserver((m,o) => this.updateWidgetList());
        this._observer.observe(observerTarget,
            {
                childList: true,
                subtree : true,
            });

        this._widgetList = [];
        this._focusWidget = null;
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
        for(let widget of this.widgetList)
        {
            console.log(widget);
        }

        const widgetElements = document.querySelectorAll(".widget");
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
}

class WidgetWindow
{
    /**
     * 
     * @param {HTMLElement} widgetElement 
     * @param {WidgetCanvas} canvas
     */
    constructor(widgetElement, canvas)
    {
        this._element = widgetElement;
        this._elementDragBar = widgetElement.querySelector(".widget-bar");
        this._elementFrameBlocker = widgetElement.querySelector(".blocker");
        this._canvas = canvas;
        this._x = widgetElement.style.left;
        this._y = widgetElement.style.top;
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
        this._x = this._mouseRelativeX - event.clientX;
        this._y = this._mouseRelativeY - event.clientY;
        this._mouseRelativeX = event.clientX;
        this._mouseRelativeY = event.clientY;
        this.updateStylePosition();
    }
    
    updateStylePosition()
    {
        this._element.style.left = (this._element.offsetLeft - this._x) + "px";
        this._element.style.top = (this._element.offsetTop - this._y) + "px";
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