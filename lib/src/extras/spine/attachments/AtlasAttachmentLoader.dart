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


class AtlasAttachmentLoader implements AttachmentLoader {
  
		Atlas _atlas;

		AtlasAttachmentLoader (Atlas atlas) {
			if (atlas == null) throw new ArgumentError("atlas cannot be null.");
			this._atlas = atlas;
		}

		RegionAttachment newRegionAttachment (Skin skin, String name, String path) {
			AtlasRegion region = _atlas.findRegion(path);
			if (region == null) throw new Exception("Region not found in atlas: " + path + " (region attachment: " + name + ")");
			RegionAttachment attachment = new RegionAttachment(name);
			attachment.rendererObject = region;
			attachment.setUVs(region.u, region.v, region.u2, region.v2, region.rotate);
			attachment.regionOffsetX = region.offsetX;
			attachment.regionOffsetY = region.offsetY;
			attachment.regionWidth = region.width.toDouble();
			attachment.regionHeight = region.height.toDouble();
			attachment.regionOriginalWidth = region.originalWidth.toDouble();
			attachment.regionOriginalHeight = region.originalHeight.toDouble();
			return attachment;
		}

		MeshAttachment newMeshAttachment (Skin skin, String name, String path) {
			AtlasRegion region = _atlas.findRegion(path);
			if (region == null) throw new Exception("Region not found in atlas: " + path + " (mesh attachment: " + name + ")");
			MeshAttachment attachment = new MeshAttachment(name);
			attachment.rendererObject = region;
			attachment.regionU = region.u;
			attachment.regionV = region.v;
			attachment.regionU2 = region.u2;
			attachment.regionV2 = region.v2;
			attachment.regionRotate = region.rotate;
			attachment.regionOffsetX = region.offsetX;
			attachment.regionOffsetY = region.offsetY;
			attachment.regionWidth = region.width.toDouble();
			attachment.regionHeight = region.height.toDouble();
			attachment.regionOriginalWidth = region.originalWidth.toDouble();
			attachment.regionOriginalHeight = region.originalHeight.toDouble();
			return attachment;
		}

		SkinnedMeshAttachment newSkinnedMeshAttachment (Skin skin, String name, String path) {
			AtlasRegion region = _atlas.findRegion(path);
			if (region == null) throw new Exception("Region not found in atlas: " + path + " (skinned mesh attachment: " + name + ")");
			SkinnedMeshAttachment attachment = new SkinnedMeshAttachment(name);
			attachment.rendererObject = region;
			attachment.regionU = region.u;
			attachment.regionV = region.v;
			attachment.regionU2 = region.u2;
			attachment.regionV2 = region.v2;
			attachment.regionRotate = region.rotate;
			attachment.regionOffsetX = region.offsetX;
			attachment.regionOffsetY = region.offsetY;
			attachment.regionWidth = region.width.toDouble();
			attachment.regionHeight = region.height.toDouble();
			attachment.regionOriginalWidth = region.originalWidth.toDouble();
			attachment.regionOriginalHeight = region.originalHeight.toDouble();
			return attachment;
		}

		BoundingBoxAttachment newBoundingBoxAttachment (Skin skin, String name) {
			return new BoundingBoxAttachment(name);
		}
		
}
