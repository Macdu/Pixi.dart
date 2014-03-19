part of pixi;

/**
 * @author Mat Groves http://matgroves.com/ @Doormat23
 */


/*
* @class Matrix
* The Matrix class is now an object, which makes it a lot faster, 
* here is a representation of it : 
* | a | b | tx|
* | c | c | ty|
* | 0 | 0 | 1 |
*
*/
class Matrix{
  
  double a = 1.0;
  double b = 0.0;
  double c = 0.0;
  double d = 1.0;
  double tx = 0.0;
  double ty = 0.0;
  
  Float32List list;
  
  Matrix();
  
  /**
   * Creates a pixi matrix object based on the array given as a parameter
   *
   * @method fromList
   * @param list {Float32List} The list that the matrix will be filled with
   */
  Matrix.fromList(Float32List list)
  {
      this.a = list[0];
      this.b = list[1];
      this.c = list[3];
      this.d = list[4];
      this.tx = list[2];
      this.ty = list[5];
  }
  
  /**
   * Creates a list from the current Matrix object
   *
   * @method toList
   * @param transpose {Boolean} Whether we need to transpose the matrix or not
   * @return list {Float32List} the newly created list which contains the matrix
   */
  Float32List toList([ bool transpose = false])
  {
      if(this.list == null) this.list = new Float32List(9);
      var array = this.list;
  
      if(transpose)
      {
          this.list[0] = this.a;
          this.list[1] = this.c;
          this.list[2] = 0.0;
          this.list[3] = this.b;
          this.list[4] = this.d;
          this.list[5] = 0.0;
          this.list[6] = this.tx;
          this.list[7] = this.ty;
          this.list[8] = 1.0;
      }
      else
      {
          this.list[0] = this.a;
          this.list[1] = this.b;
          this.list[2] = this.tx;
          this.list[3] = this.c;
          this.list[4] = this.d;
          this.list[5] = this.ty;
          this.list[6] = 0.0;
          this.list[7] = 0.0;
          this.list[8] = 1.0;
      }
  
      return array;//[this.a, this.b, this.tx, this.c, this.d, this.ty, 0, 0, 1];
  }

}

Matrix identityMatrix = new Matrix();