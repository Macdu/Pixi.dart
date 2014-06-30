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

	/// <summary>Stores attachments by slot index and attachment name.</summary>
class Skin {
		String _name;
		Map<_KeyValuePair<int, String>, Attachment> attachments =
			new Map<_KeyValuePair<int, String>, Attachment>();//(AttachmentComparer.Instance);

		String get name => name;

		Skin (String name) {
			if (name == null) throw new ArgumentError("name cannot be null.");
			this._name = name;
		}

		void addAttachment (int slotIndex, String name, Attachment attachment) {
			if (attachment == null) throw new ArgumentError("attachment cannot be null.");
			attachments[new _KeyValuePair<int, String>(slotIndex, name)] = attachment;
		}

		/// <returns>May be null.</returns>
		Attachment getAttachment (int slotIndex, String name) {
		  Attachment attachment;
		  if(!attachments.containsKey(new _KeyValuePair<int, String>(slotIndex, name))){
		    return null;
		  }
		  return attachments[new _KeyValuePair<int, String>(slotIndex, name)];
		}

		void findNamesForSlot (int slotIndex, List<String> names) {
			if (names == null) throw new ArgumentError("names cannot be null.");
			for(_KeyValuePair<int, String> key in attachments.keys)
				if (key.key == slotIndex) names.add(key.value);
		}

		void findAttachmentsForSlot (int slotIndex, List<Attachment> attachments) {
			if (attachments == null) throw new ArgumentError("attachments cannot be null.");
			this.attachments.forEach((_KeyValuePair<int, String> entry, Attachment value){
			  if (entry.key == slotIndex) attachments.add(value);
			});
		}

		@override 
		String toString () {
			return _name;
		}

		/// <summary>Attach all attachments from this skin if the corresponding attachment from the old skin is currently attached.</summary>
		void attachAll (Skeleton skeleton, Skin oldSkin) {
		  oldSkin.attachments.forEach((_KeyValuePair<int, String> entry, Attachment value){
				int slotIndex = entry.key;
				Slot slot = skeleton.slots[slotIndex];
				if (slot.attachment == value) {
					Attachment attachment = getAttachment(slotIndex, entry.value);
					if (attachment != null) slot.attachment = attachment;
				}
			});
		}
		
}
/*

		// Avoids boxing in the dictionary.
		private class AttachmentComparer : IEqualityComparer<KeyValuePair<int, String>> {
			internal static readonly AttachmentComparer Instance = new AttachmentComparer();

			bool IEqualityComparer<KeyValuePair<int, string>>.Equals (KeyValuePair<int, string> o1, KeyValuePair<int, string> o2) {
				return o1.Key == o2.Key && o1.Value == o2.Value;
			}

			int IEqualityComparer<KeyValuePair<int, string>>.GetHashCode (KeyValuePair<int, string> o) {
				return o.Key;
			}
		}
	}
*/
