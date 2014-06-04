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

class Bone {
		static bool yDown;

		BoneData _data;
		Bone _parent;
		double x, y, rotation, scaleX, scaleY;
		double m00, m01, m10, m11;
		double worldX, worldY, worldRotation, worldScaleX, worldScaleY;

		BoneData get data => data;
		Bone get parent => parent;

		/// <param name="parent">May be null.</param>
		Bone (BoneData data, Bone parent) {
			if (data == null) throw new ArgumentError("data cannot be null.");
			this._data = data;
			this._parent = parent;
			setToSetupPose();
		}

		/// <summary>Computes the world SRT using the parent bone and the local SRT.</summary>
		void updateWorldTransform (bool flipX, bool flipY) {
			Bone parent = this.parent;
			if (parent != null) {
				worldX = x * parent.m00 + y * parent.m01 + parent.worldX;
				worldY = x * parent.m10 + y * parent.m11 + parent.worldY;
				if (data.inheritScale) {
					worldScaleX = parent.worldScaleX * scaleX;
					worldScaleY = parent.worldScaleY * scaleY;
				} else {
					worldScaleX = scaleX;
					worldScaleY = scaleY;
				}
				worldRotation = data.inheritRotation ? parent.worldRotation + rotation : rotation;
			} else {
				worldX = flipX ? -x : x;
				worldY = flipY != yDown ? -y : y;
				worldScaleX = scaleX;
				worldScaleY = scaleY;
				worldRotation = rotation;
			}
			double radians = worldRotation * Math.PI / 180;
			double cos = Math.cos(radians);
			double sin = Math.sin(radians);
			m00 = cos * worldScaleX;
			m10 = sin * worldScaleX;
			m01 = -sin * worldScaleY;
			m11 = cos * worldScaleY;
			if (flipX) {
				m00 = -m00;
				m01 = -m01;
			}
			if (flipY != yDown) {
				m10 = -m10;
				m11 = -m11;
			}
		}

		void setToSetupPose () {
			BoneData data = this.data;
			x = data.x;
			y = data.y;
			rotation = data.rotation;
			scaleX = data.scaleX;
			scaleY = data.scaleY;
		}

		@override
		String toString () {
			return data.name;
		}
	}

