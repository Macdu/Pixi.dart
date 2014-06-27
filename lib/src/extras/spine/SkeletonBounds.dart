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

class SkeletonBounds {
  
		List<Polygon> polygonPool = new List<Polygon>();
		double minX, minY, maxX, maxY;
		
		List<BoundingBoxAttachment> _boundingBoxes = new List<BoundingBoxAttachment>();
		List<Polygon> _polygons = new List<Polygon>();

		List<BoundingBoxAttachment> get boundingBoxes => _boundingBoxes;
		List<Polygon> get polygons => _polygons;
		double get width => maxX - minX;
		double get height => maxY - minY;

		void update (Skeleton skeleton, bool updateAabb) {
			List<BoundingBoxAttachment> boundingBoxes = _boundingBoxes;
			List<Polygon> polygons = _polygons;
			List<Slot> slots = skeleton.slots;
			int slotCount = slots.length;
			double x = skeleton.x, y = skeleton.y;

			boundingBoxes.clear();
			for(Polygon polygon in polygons)
				polygonPool.add(polygon);
			polygons.clear();

			for (int i = 0; i < slotCount; i++) {
				Slot slot = slots[i];
				BoundingBoxAttachment boundingBox = slot.attachment as BoundingBoxAttachment;
				if (boundingBox == null) continue;
				boundingBoxes.add(boundingBox);

				Polygon polygon = null;
				int poolCount = polygonPool.length;
				if (poolCount > 0) {
					polygon = polygonPool[poolCount - 1];
					polygonPool.removeAt(poolCount - 1);
				} else
					polygon = new Polygon();
				polygons.add(polygon);

				int count = boundingBox.vertices.length;
				polygon.length = count;
				if (polygon.vertices.length < count) polygon.vertices = new List<double>(count);
				boundingBox.computeWorldVertices(x, y, slot.bone, polygon.vertices);
			}

			if (updateAabb) aabbCompute();
		}

		void aabbCompute () {
			double minX = double.MAX_FINITE, minY = double.MAX_FINITE,
			    maxX = -double.MAX_FINITE, maxY = -double.MAX_FINITE;
			List<Polygon> polygons = _polygons;
			for (int i = 0, n = polygons.length; i < n; i++) {
				Polygon polygon = polygons[i];
				List<double> vertices = polygon.vertices;
				for (int ii = 0, nn = polygon.length; ii < nn; ii += 2) {
					double x = vertices[ii];
					double y = vertices[ii + 1];
					minX = Math.min(minX, x);
					minY = Math.min(minY, y);
					maxX = Math.max(maxX, x);
					maxY = Math.max(maxY, y);
				}
			}
			this.minX = minX;
			this.minY = minY;
			this.maxX = maxX;
			this.maxY = maxY;
		}


		/// <summary>Returns true if the axis aligned bounding box contains the point.</summary>
		bool aabbContainsPoint (double x, double y) {
			return x >= minX && x <= maxX && y >= minY && y <= maxY;
		}

		/// <summary>Returns true if the axis aligned bounding box intersects the line segment.</summary>
		bool aabbIntersectsSegment (double x1, double y1, double x2, double y2) {
		  double minX = this.minX;
		  double minY = this.minY;
		  double maxX = this.maxX;
		  double maxY = this.maxY;
			if ((x1 <= minX && x2 <= minX) || (y1 <= minY && y2 <= minY) || (x1 >= maxX && x2 >= maxX) || (y1 >= maxY && y2 >= maxY))
				return false;
			double m = (y2 - y1) / (x2 - x1);
			double y = m * (minX - x1) + y1;
			if (y > minY && y < maxY) return true;
			y = m * (maxX - x1) + y1;
			if (y > minY && y < maxY) return true;
			double x = (minY - y1) / m + x1;
			if (x > minX && x < maxX) return true;
			x = (maxY - y1) / m + x1;
			if (x > minX && x < maxX) return true;
			return false;
		}

		/// <summary>Returns true if the axis aligned bounding box intersects the axis aligned bounding box of the specified bounds.</summary>
		bool aabbIntersectsSkeleton (SkeletonBounds bounds) {
			return minX < bounds.maxX && maxX > bounds.minX && minY < bounds.maxY && maxY > bounds.minY;
		}

		/// <summary>Returns true if the polygon contains the point.</summary>
		bool containsPointWithPolygon (Polygon polygon, double x, double y) {
			List<double> vertices = polygon.vertices;
			int nn = polygon.length;

			int prevIndex = nn - 2;
			bool inside = false;
			for (int ii = 0; ii < nn; ii += 2) {
			  double vertexY = vertices[ii + 1];
			  double prevY = vertices[prevIndex + 1];
				if ((vertexY < y && prevY >= y) || (prevY < y && vertexY >= y)) {
				  double vertexX = vertices[ii];
					if (vertexX + (y - vertexY) / (prevY - vertexY) * (vertices[prevIndex] - vertexX) < x) inside = !inside;
				}
				prevIndex = ii;
			}
			return inside;
		}

		/// <summary>Returns the first bounding box attachment that contains the point, or null. When doing many checks, it is usually more
		/// efficient to only call this method if {@link #aabbContainsPoint(float, float)} returns true.</summary>
		BoundingBoxAttachment containsPoint (double x, double y) {
			List<Polygon> polygons = _polygons;
			for (int i = 0, n = polygons.length; i < n; i++)
				if (containsPointWithPolygon(polygons[i], x, y)) return _boundingBoxes[i];
			return null;
		}

		/// <summary>Returns the first bounding box attachment that contains the line segment, or null. When doing many checks, it is usually
		/// more efficient to only call this method if {@link #aabbIntersectsSegment(float, float, float, float)} returns true.</summary>
		BoundingBoxAttachment intersectsSegment (double x1, double y1, double x2, double y2) {
			List<Polygon> polygons = _polygons;
			for (int i = 0, n = polygons.length; i < n; i++)
				if (intersectsSegmentWithPolygon(polygons[i], x1, y1, x2, y2)) return _boundingBoxes[i];
			return null;
		}

		/// <summary>Returns true if the polygon contains the line segment.</summary>
		bool intersectsSegmentWithPolygon (Polygon polygon, double x1, double y1, double x2, double y2) {
			List<double> vertices = polygon.vertices;
			int nn = polygon.length;

			double width12 = x1 - x2, height12 = y1 - y2;
			double det1 = x1 * y2 - y1 * x2;
			double x3 = vertices[nn - 2], y3 = vertices[nn - 1];
			for (int ii = 0; ii < nn; ii += 2) {
			  double x4 = vertices[ii], y4 = vertices[ii + 1];
			  double det2 = x3 * y4 - y3 * x4;
			  double width34 = x3 - x4, height34 = y3 - y4;
			  double det3 = width12 * height34 - height12 * width34;
			  double x = (det1 * width34 - width12 * det2) / det3;
				if (((x >= x3 && x <= x4) || (x >= x4 && x <= x3)) && ((x >= x1 && x <= x2) || (x >= x2 && x <= x1))) {
				  double y = (det1 * height34 - height12 * det2) / det3;
					if (((y >= y3 && y <= y4) || (y >= y4 && y <= y3)) && ((y >= y1 && y <= y2) || (y >= y2 && y <= y1))) return true;
				}
				x3 = x4;
				y3 = y4;
			}
			return false;
		}

		Polygon getPolygon (BoundingBoxAttachment attachment) {
			int index = _boundingBoxes.indexOf(attachment);
			return index == -1 ? null : _polygons[index];
		}
	}

class Polygon {
		List<double> vertices = new List<double>(16);
		int length;
	}

