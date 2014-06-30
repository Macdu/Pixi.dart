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

class Slot {
		SlotData _data;
		Bone _bone;
		Skeleton _skeleton;
		double r, g, b, a;
		Attachment _attachment;
		double _attachmentTime;
		List<double> attachmentVertices = new List<double>(0);
		int attachmentVerticesCount;

		SlotData get data => data;
		Bone get bone => _bone;
		Skeleton get skeleton => _skeleton;
		/// <summary>May be null.</summary>
		Attachment get attachment => _attachment;
		  set attachment (Attachment value){
				attachment = value;
				_attachmentTime = skeleton.time;
				attachmentVerticesCount = 0;
			}
		

		double get attachmentTime => _skeleton.time - _attachmentTime;
		  set attachmentTime(double value){
				attachmentTime = skeleton.time - value;
			}
		
		Slot (SlotData data, Skeleton skeleton, Bone bone) {
			if (data == null) throw new ArgumentError("data cannot be null.");
			if (skeleton == null) throw new ArgumentError("skeleton cannot be null.");
			if (bone == null) throw new ArgumentError("bone cannot be null.");
			this._data = data;
			this._skeleton = skeleton;
			this._bone = bone;
			setToSetupPose();
		}

		void setToSetupPose ([int slotIndex = null]) {
		  if(slotIndex == null)slotIndex = skeleton.data.slots.indexOf(data);
			r = data.r;
			g = data.g;
			b = data.b;
			a = data.a;
			_attachment = data.attachmentName == null ? null : skeleton.getAttachment(slotIndex, data.attachmentName);
		}

		@override 
		String toString () {
			return data.name;
		}
}

