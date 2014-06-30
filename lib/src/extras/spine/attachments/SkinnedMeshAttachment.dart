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
class SkinnedMeshAttachment extends Attachment {

  List<int> bones;
  List<double> weights, uvs, regionUVs;
  List<double> triangles;
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

  SkinnedMeshAttachment(String name)
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
    List<Bone> skeletonBones = slot.skeleton.bones;
    List<double> weights = this.weights;
    List<int> bones = this.bones;
    if (slot.attachmentVerticesCount == 0) {
      for (int w = 0,
          v = 0,
          b = 0,
          n = bones.length; v < n; w += 2) {
        double wx = 0.0,
            wy = 0.0;
        int nn = bones[v++] + v;
        for ( ; v < nn; v++, b += 3) {
          Bone bone = skeletonBones[bones[v]];
          double vx = weights[b],
              vy = weights[b + 1],
              weight = weights[b + 2];
          wx += (vx * bone.m00 + vy * bone.m01 + bone.worldX) * weight;
          wy += (vx * bone.m10 + vy * bone.m11 + bone.worldY) * weight;
        }
        worldVertices[w] = wx + x;
        worldVertices[w + 1] = wy + y;
      }
    } else {
      List<double> ffd = slot.attachmentVertices;
      for (int w = 0,
          v = 0,
          b = 0,
          f = 0,
          n = bones.length; v < n; w += 2) {
        double wx = 0.0,
            wy = 0.0;
        int nn = bones[v++] + v;
        for ( ; v < nn; v++, b += 3, f += 2) {
          Bone bone = skeletonBones[bones[v]];
          double vx = weights[b] + ffd[f],
              vy = weights[b + 1] + ffd[f + 1],
              weight = weights[b + 2];
          wx += (vx * bone.m00 + vy * bone.m01 + bone.worldX) * weight;
          wy += (vx * bone.m10 + vy * bone.m11 + bone.worldY) * weight;
        }
        worldVertices[w] = wx + x;
        worldVertices[w + 1] = wy + y;
      }
    }
  }
}
