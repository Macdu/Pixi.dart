part of pixi;

/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */


/**
 * A DisplayObjectContainer represents a collection of display objects.
 * It is the base class of all display objects that act as a container for other objects.
 *
 * @class DisplayObjectContainer
 * @extends DisplayObject
 */
class DisplayObjectContainer extends DisplayObject
{
    
  List<DisplayObject> children = [];
  
  
  /**
   * The width of the displayObjectContainer, setting this will actually modify the scale to achieve the value set
   *
   * @property width
   * @type Number
   */
  
   /*
  Object.defineProperty(PIXI.DisplayObjectContainer.prototype, 'width', {
      get: function() {
          return this.scale.x * this.getLocalBounds().width;
      },
      set: function(value) {
          this.scale.x = value / (this.getLocalBounds().width/this.scale.x);
          this._width = value;
      }
  });
  */
  
  /**
   * The height of the displayObjectContainer, setting this will actually modify the scale to achieve the value set
   *
   * @property height
   * @type Number
   */
  
  /*
  Object.defineProperty(PIXI.DisplayObjectContainer.prototype, 'height', {
      get: function() {
          return  this.scale.y * this.getLocalBounds().height;
      },
      set: function(value) {
          this.scale.y = value / (this.getLocalBounds().height/this.scale.y);
          this._height = value;
      }
  });
  */
  
  /**
   * Adds a child to the container.
   *
   * @method addChild
   * @param child {DisplayObject} The DisplayObject to add to the container
   */
  void addChild(DisplayObject child)
  {
      this.addChildAt(child, this.children.length);
  }
  
  /**
   * Adds a child to the container at a specified index. If the index is out of bounds an error will be thrown
   *
   * @method addChildAt
   * @param child {DisplayObject} The child to add
   * @param index {Number} The index to place the child in
   */
  void addChildAt (DisplayObject child,int index)
  {
      if(index >= 0 && index <= this.children.length)
      {
          if(child.parent != null)
          {
              child.parent.removeChild(child);
          }
  
          child.parent = this;
  
          this.children[index] = child;
  
          if(this.stage)child.setStageReference(this.stage);
      }
      else
      {
          throw new Exception(child.toString() + ' The index '+ index.toString() +' supplied is out of bounds ' + this.children.length.toString());
      }
  }
  
  /**
   * [NYI] Swaps the depth of 2 displayObjects
   *
   * @method swapChildren
   * @param child {DisplayObject}
   * @param child2 {DisplayObject}
   * @private
   */
  void swapChildren(DisplayObject child,DisplayObject child2)
  {
      if(child == child2) {
          return;
      }
  
      var index1 = this.children.indexOf(child);
      var index2 = this.children.indexOf(child2);
  
      if(index1 < 0 || index2 < 0) {
          throw new Exception('swapChildren: Both the supplied DisplayObjects must be a child of the caller.');
      }
  
      this.children[index1] = child2;
      this.children[index2] = child;
      
  }
  
  /**
   * Returns the child at the specified index
   *
   * @method getChildAt
   * @param index {Number} The index to get the child from
   */
  DisplayObject getChildAt(int index)
  {
      if(index >= 0 && index < this.children.length)
      {
          return this.children[index];
      }
      else
      {
          throw new Exception('The supplied DisplayObjects must be a child of the caller ' + this.toString());
      }
  }
  
  /**
   * Removes a child from the container.
   *
   * @method removeChild
   * @param child {DisplayObject} The DisplayObject to remove
   */
  void removeChild(DisplayObjectContainer child)
  {
      int index = this.children.indexOf( child );
      if ( index != -1 )
      {
          // update the stage reference..
          if(this.stage)child.removeStageReference();
  
          child.parent = null;
          this.children.removeAt( index );
      }
      else
      {
          throw new Exception(child.toString() + ' The supplied DisplayObject must be a child of the caller ' + this.toString());
      }
  }
  
  
  /**
  * Removes all the children 
  *
  * @method removeAll
  * NOT tested yet
  */
  /* PIXI.DisplayObjectContainer.prototype.removeAll = function()
  {
  
  
      for(var i = 0 , j = this.children.length; i < j; i++)
      {
          this.removeChild(this.children[i]);
      }
      
  };
  */
  /*
   * Updates the container's childrens transform for rendering
   *
   * @method updateTransform
   * @private
   */
  void updateTransform()
  {
      //this._currentBounds = null;
  
      if(!this.visible)return;
  
      super.updateTransform();
  
      for(var i=0,j=this.children.length; i<j; i++)
      {
          this.children[i].updateTransform();
      }
  }
  
  /**
   * Retrieves the bounds of the displayObjectContainer as a rectangle object
   *
   * @method getBounds
   * @return {Rectangle} the rectangular bounding area
   */
  Rectangle getBounds([Matrix matrix = null])
  {
      if(this.children.length == 0)return EmptyRectangle;
  
      // TODO the bounds have already been calculated this render session so return what we have
      if(matrix != null)
      {
          Matrix matrixCache = this.worldTransform;
          this.worldTransform = matrix;
          this.updateTransform();
          this.worldTransform = matrixCache;
      }
  
      double minX = double.INFINITY;
      double minY = double.INFINITY;
  
      double maxX = double.NEGATIVE_INFINITY;
      double maxY = double.NEGATIVE_INFINITY;
  
      Rectangle childBounds;
      double childMaxX;
      double childMaxY;
  
      bool childVisible = false;
  
      for(int i=0,j=this.children.length; i<j; i++)
      {
          DisplayObject child = this.children[i];
          
          if(!child.visible)continue;
  
          childVisible = true;
  
          childBounds = this.children[i].getBounds( matrix );
       
          minX = minX < childBounds.x ? minX : childBounds.x;
          minY = minY < childBounds.y ? minY : childBounds.y;
  
          childMaxX = (childBounds.width + childBounds.x).toDouble();
          childMaxY = (childBounds.height + childBounds.y).toDouble();
  
          maxX = maxX > childMaxX ? maxX : childMaxX;
          maxY = maxY > childMaxY ? maxY : childMaxY;
      }
  
      if(!childVisible)
          return EmptyRectangle;
  
      var bounds = this._bounds;
  
      bounds.x = minX;
      bounds.y = minY;
      bounds.width = maxX - minX;
      bounds.height = maxY - minY;
  
      // TODO: store a reference so that if this function gets called again in the render cycle we do not have to recalculate
      //this._currentBounds = bounds;
     
      return bounds;
  }
  
  Rectangle getLocalBounds()
  {
      Matrix matrixCache = this.worldTransform;
  
      this.worldTransform = identityMatrix;
  
      for(int i=0,j=this.children.length; i<j; i++)
      {
          this.children[i].updateTransform();
      }
  
      Rectangle bounds = this.getBounds();
  
      this.worldTransform = matrixCache;
  
      return bounds;
  }
  
  /**
   * Sets the container's stage reference, the stage this object is connected to
   *
   * @method setStageReference
   * @param stage {Stage} the stage that the container will have as its current stage reference
   */
  void setStageReference(Stage stage)
  {
      this.stage = stage;
      if(this._interactive)this.stage.dirty = true;
  
      for(int i=0,j=this.children.length; i<j; i++)
      {
          DisplayObject child = this.children[i];
          child.setStageReference(stage);
      }
  }
  
  /**
   * removes the current stage reference of the container
   *
   * @method removeStageReference
   */
  void removeStageReference()
  {
  
      for(int i=0,j=this.children.length; i<j; i++)
      {
          DisplayObjectContainer child = this.children[i];
          child.removeStageReference();
      }
  
      if(this._interactive)this.stage.dirty = true;
      
      this.stage = null;
  }
  
  /**
  * Renders the object using the WebGL renderer
  *
  * @method _renderWebGL
  * @param renderSession {RenderSession} 
  * @private
  */
  void _renderWebGL(RenderSession renderSession)
  {
      if(!this.visible || this.alpha <= 0)return;
      
      int i,j;
  
      if(this._mask =! null || this._filters != null)
      {
          if(this._mask != null)
          {
              renderSession.spriteBatch.stop();
              renderSession.maskManager.pushMask(this.mask, renderSession);
              renderSession.spriteBatch.start();
          }
  
          if(this._filters != null)
          {
              renderSession.spriteBatch.flush();
              renderSession.filterManager.pushFilter(this._filterBlock);
          }
  
          // simple render children!
          i = 0;
          for(j=this.children.length; i<j; i++)
          {
              this.children[i]._renderWebGL(renderSession);
          }
  
          renderSession.spriteBatch.stop();
  
          if(this._filters != null)renderSession.filterManager.popFilter();
          if(this._mask != null)renderSession.maskManager.popMask(renderSession);
          
          renderSession.spriteBatch.start();
      }
      else
      {
          // simple render children!
          i = 0;
          for(j=this.children.length; i<j; i++)
          {
              this.children[i]._renderWebGL(renderSession);
          }
      }
  }
  
  /**
  * Renders the object using the Canvas renderer
  *
  * @method _renderCanvas
  * @param renderSession {RenderSession} 
  * @private
  */
  _renderCanvas (RenderSession renderSession)
  {
      if(this.visible == false || this.alpha == 0)return;
  
      if(this._mask != null)
      {
          renderSession.maskManager.pushMask(this._mask, renderSession.context);
      }
  
      for(int i=0,j=this.children.length; i<j; i++)
      {
          DisplayObject child = this.children[i];
          child._renderCanvas(renderSession);
      }
  
      if(this._mask != null)
      {
          renderSession.maskManager.popMask(renderSession.context);
      }
  }
  
}