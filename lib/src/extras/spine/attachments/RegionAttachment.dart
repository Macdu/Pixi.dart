part of spine;
/******************************************************************************
 * Spine Runtimes Software License
 * Version 2.1
 * 
 * Copyright (c) 2013, Esoteric Software
 * All rights reserved.
 * 
 * You are granted a perpetual, non-exclusive, non-sublicensable and
 * non-transferable license to install, execute and perform the Spine Runtimes
 * Software (the "Software") solely for internal use. Without the written
 * permission of Esoteric Software (typically granted by licensing Spine), you
 * may not (a) modify, translate, adapt or otherwise create derivative works,
 * improvements of the Software or develop new applications using the Software
 * or (b) remove, delete, alter or obscure any trademarks or any copyright,
 * trademark, patent or other intellectual property or proprietary rights
 * notices on or in the Software, including any copy thereof. Redistributions
 * in binary or source form must include this license and terms.
 * 
 * THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL ESOTERIC SOFTARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/


/// <summary>Attachment that displays a texture region.</summary>
class RegionAttachment extends Attachment {
  static const int X1 = 0;
  static const int Y1 = 1;
  static const int X2 = 2;
  static const int Y2 = 3;
  static const int X3 = 4;
  static const int Y3 = 5;
  static const int X4 = 6;
  static const int Y4 = 7;

  double x,
      y,
      rotation,
      scaleX = 1.0,
      scaleY = 1.0,
      width,
      height;
  double regionOffsetX, regionOffsetY, regionWidth, regionHeight, regionOriginalWidth, regionOriginalHeight;
  List<double> _offset = new List<double>(8),
      _uvs = new List<double>(8);
  double r = 1.0,
      g = 1.0,
      b = 1.0,
      a = 1.0;

  String path;
  Object rendererObject;

  List<double> get offset => _offset;
  List<double> get uvs => _uvs;

  RegionAttachment(String name)
      : super(name) {
  }

  void setUVs(double u, double v, double u2, double v2, bool rotate) {
    List<double> uvs = this._uvs;
    if (rotate) {
      uvs[X2] = u;
      uvs[Y2] = v2;
      uvs[X3] = u;
      uvs[Y3] = v;
      uvs[X4] = u2;
      uvs[Y4] = v;
      uvs[X1] = u2;
      uvs[Y1] = v2;
    } else {
      uvs[X1] = u;
      uvs[Y1] = v2;
      uvs[X2] = u;
      uvs[Y2] = v;
      uvs[X3] = u2;
      uvs[Y3] = v;
      uvs[X4] = u2;
      uvs[Y4] = v2;
    }
  }

  void updateOffset() {
    double width = this.width;
    double height = this.height;
    double scaleX = this.scaleX;
    double scaleY = this.scaleY;
    double regionScaleX = width / regionOriginalWidth * scaleX;
    double regionScaleY = height / regionOriginalHeight * scaleY;
    double localX = -width / 2 * scaleX + regionOffsetX * regionScaleX;
    double localY = -height / 2 * scaleY + regionOffsetY * regionScaleY;
    double localX2 = localX + regionWidth * regionScaleX;
    double localY2 = localY + regionHeight * regionScaleY;
    double radians = rotation * Math.PI / 180;
    double cos = Math.cos(radians);
    double sin = Math.sin(radians);
    double x = this.x;
    double y = this.y;
    double localXCos = localX * cos + x;
    double localXSin = localX * sin;
    double localYCos = localY * cos + y;
    double localYSin = localY * sin;
    double localX2Cos = localX2 * cos + x;
    double localX2Sin = localX2 * sin;
    double localY2Cos = localY2 * cos + y;
    double localY2Sin = localY2 * sin;
    List<double> offset = this.offset;
    offset[X1] = localXCos - localYSin;
    offset[Y1] = localYCos + localXSin;
    offset[X2] = localXCos - localY2Sin;
    offset[Y2] = localY2Cos + localXSin;
    offset[X3] = localX2Cos - localY2Sin;
    offset[Y3] = localY2Cos + localX2Sin;
    offset[X4] = localX2Cos - localYSin;
    offset[Y4] = localYCos + localX2Sin;
  }

  void computeWorldVertices(double x, double y, Bone bone, List<double> worldVertices) {
    x += bone.worldX;
    y += bone.worldY;
    double m00 = bone.m00,
        m01 = bone.m01,
        m10 = bone.m10,
        m11 = bone.m11;
    List<double> offset = this.offset;
    worldVertices[X1] = offset[X1] * m00 + offset[Y1] * m01 + x;
    worldVertices[Y1] = offset[X1] * m10 + offset[Y1] * m11 + y;
    worldVertices[X2] = offset[X2] * m00 + offset[Y2] * m01 + x;
    worldVertices[Y2] = offset[X2] * m10 + offset[Y2] * m11 + y;
    worldVertices[X3] = offset[X3] * m00 + offset[Y3] * m01 + x;
    worldVertices[Y3] = offset[X3] * m10 + offset[Y3] * m11 + y;
    worldVertices[X4] = offset[X4] * m00 + offset[Y4] * m01 + x;
    worldVertices[Y4] = offset[X4] * m10 + offset[Y4] * m11 + y;
  }
}
