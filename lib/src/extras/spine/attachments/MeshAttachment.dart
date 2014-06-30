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
class MeshAttachment extends Attachment {

  List<double> vertices, uvs, regionUVs;
  List<int> triangles;
  double regionOffsetX, regionOffsetY, regionWidth, regionHeight, regionOriginalWidth, regionOriginalHeight;
  double r = 1.0,
      g = 1.0,
      b = 1.0,
      a = 1.0;

  int hullLength;

  String path;
  Object rendererObject;
  double regionU;
  double regionV;
  double regionU2;
  double regionV2;
  bool regionRotate;

  // Nonessential.
  List<int> edges;
  double width;
  double height;

  MeshAttachment(String name)
      : super(name) {
  }

  void updateUVs() {
    double u = regionU,
        v = regionV,
        width = regionU2 - regionU,
        height = regionV2 - regionV;
    List<double> regionUVs = this.regionUVs;
    if (this.uvs == null || this.uvs.length != regionUVs.length) this.uvs = new List<double>(regionUVs.length);
    List<double> uvs = this.uvs;
    if (regionRotate) {
      for (int i = 0,
          n = uvs.length; i < n; i += 2) {
        uvs[i] = u + regionUVs[i + 1] * width;
        uvs[i + 1] = v + height - regionUVs[i] * height;
      }
    } else {
      for (int i = 0,
          n = uvs.length; i < n; i += 2) {
        uvs[i] = u + regionUVs[i] * width;
        uvs[i + 1] = v + regionUVs[i + 1] * height;
      }
    }
  }

  void computeWorldVertices(double x, double y, Slot slot, List<double> worldVertices) {
    Bone bone = slot.bone;
    x += bone.worldX;
    y += bone.worldY;
    double m00 = bone.m00,
        m01 = bone.m01,
        m10 = bone.m10,
        m11 = bone.m11;
    List<double> vertices = this.vertices;
    int verticesCount = vertices.length;
    if (slot.attachmentVerticesCount == verticesCount) vertices = slot.attachmentVertices;
    for (int i = 0; i < verticesCount; i += 2) {
      double vx = vertices[i];
      double vy = vertices[i + 1];
      worldVertices[i] = vx * m00 + vy * m01 + x;
      worldVertices[i + 1] = vx * m10 + vy * m11 + y;
    }
  }
}
