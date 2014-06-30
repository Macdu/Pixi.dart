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


class Atlas {
		List<AtlasPage> pages = new List<AtlasPage>();
		List<AtlasRegion> regions = new List<AtlasRegion>();
		TextureLoader textureLoader;

		Atlas(String path, TextureLoader textureLoader) {
		  HttpRequest.getString(path).then((String value){
        List<String> pathSplitted = path.split('/');
        pathSplitted.removeLast();
		    this._load(value,pathSplitted.join('/'),textureLoader);
		  });
		}

		Atlas.fromString(String reader, String dir, TextureLoader textureLoader) {
			_load(reader, dir, textureLoader);
		}

		Atlas.fomPages(List<AtlasPage> pages, List<AtlasRegion> regions) {
			this.pages = pages;
			this.regions = regions;
			this.textureLoader = null;
		}

		void _load (String text, String imagesDir, TextureLoader textureLoader) {
			if (textureLoader == null) throw new ArgumentError("textureLoader cannot be null.");
			this.textureLoader = textureLoader;

			List<String> tuple = new List<String>(4);
			List<String> reader = text.split('\n').reversed;
			AtlasPage page;
			while (true) {
				String line = reader.removeLast();
				if (line == null) break;
				if (line.trim().length == 0)
					page = null;
				else if (page == null) {
					page = new AtlasPage();
					page.name = line;

					if (Atlas.readTuple(reader, tuple) == 2) { // size is only optional for an atlas packed with an old TexturePacker.
						page.width = int.parse(tuple[0]);
						page.height = int.parse(tuple[1]);
						Atlas.readTuple(reader, tuple);
					}
					//page.format = Enum.Parse(typeof(Format), tuple[0], false) as Format;
          page.format = tuple[0];

					Atlas.readTuple(reader, tuple);
					/*
  					page.minFilter = (TextureFilter)Enum.Parse(typeof(TextureFilter), tuple[0], false);
  					page.magFilter = (TextureFilter)Enum.Parse(typeof(TextureFilter), tuple[1], false);
					*/
					page.minFilter = tuple[0];
          page.magFilter = tuple[1];

					String direction = readValue(reader);
					page.uWrap = 'ClampToEdge';
					page.vWrap = 'ClampToEdge';
					if (direction == "x")
						page.uWrap = 'Repeat';
					else if (direction == "y")
						page.vWrap = 'Repeat';
					else if (direction == "xy")
						page.uWrap = page.vWrap = 'Repeat';

					textureLoader.load(page, imagesDir + '/' + line);

					pages.add(page);

				} else {
					AtlasRegion region = new AtlasRegion();
					region.name = line;
					region.page = page;

					String rotate = readValue(reader);
					region.rotate = rotate == '1' || rotate.toLowerCase() == 'true';

					readTuple(reader, tuple);
					int x = int.parse(tuple[0]);
					int y = int.parse(tuple[1]);

					readTuple(reader, tuple);
					int width = int.parse(tuple[0]);
					int height = int.parse(tuple[1]);

					region.u = x / page.width;
					region.v = y / page.height;
					if (region.rotate) {
						region.u2 = (x + height) / page.width;
						region.v2 = (y + width) / page.height;
					} else {
						region.u2 = (x + width) / page.width;
						region.v2 = (y + height) / page.height;
					}
					region.x = x;
					region.y = y;
					region.width = width.abs();
					region.height = height.abs();

					if (readTuple(reader, tuple) == 4) { // split is optional
						region.splits = [int.parse(tuple[0]), int.parse(tuple[1]),
								int.parse(tuple[2]), int.parse(tuple[3])];

						if (readTuple(reader, tuple) == 4) { // pad is optional, but only present with splits
							region.pads = [int.parse(tuple[0]), int.parse(tuple[1]),
									int.parse(tuple[2]), int.parse(tuple[3])];

							readTuple(reader, tuple);
						}
					}

					region.originalWidth = int.parse(tuple[0]);
					region.originalHeight = int.parse(tuple[1]);

					readTuple(reader, tuple);
					region.offsetX = int.parse(tuple[0]).toDouble();
					region.offsetY = int.parse(tuple[1]).toDouble();

					region.index = int.parse(readValue(reader));

					regions.add(region);
				}
			}
		}

		static String readValue (List<String> reader) {
			String line = reader.removeLast();
			int colon = line.indexOf(':');
			if (colon == -1) throw new Exception("Invalid line: " + line);
			return line.substring(colon + 1).trim();
		}

		/// <summary>Returns the number of tuple values read (1, 2 or 4).</summary>
		static int readTuple (List<String> reader, List<String> tuple) {
			String line = reader.removeLast();
			int colon = line.indexOf(':');
			if (colon == -1) throw new Exception("Invalid line: " + line);
			int i = 0, lastMatch = colon + 1;
			for (; i < 3; i++) {
				int comma = line.indexOf(',', lastMatch);
				if (comma == -1) break;
				tuple[i] = line.substring(lastMatch, comma - lastMatch).trim();
				lastMatch = comma + 1;
			}
			tuple[i] = line.substring(lastMatch).trim();
			return i + 1;
		}

		void FlipV () {
			for (int i = 0, n = regions.length; i < n; i++) {
				AtlasRegion region = regions[i];
				region.v = 1 - region.v;
				region.v2 = 1 - region.v2;
			}
		}

		/// <summary>Returns the first region found with the specified name. This method uses string comparison to find the region, so the result
		/// should be cached rather than calling this method multiple times.</summary>
		/// <returns>The region, or null.</returns>
		AtlasRegion findRegion (String name) {
			for (int i = 0, n = regions.length; i < n; i++)
				if (regions[i].name == name) return regions[i];
			return null;
		}

		void dispose () {
			if (textureLoader == null) return;
			for (int i = 0, n = pages.length; i < n; i++)
				textureLoader.unload(pages[i].rendererObject);
		}
	}

	const List<String> Formats = const [
		'Alpha',
		'Intensity',
		'LuminanceAlpha',
		'RGB565',
		'RGBA4444',
		'RGB888',
		'RGBA8888'
	];

	const List<String> TextureFilters = const[
		'Nearest',
		'Linear',
		'MipMap',
		'MipMapNearestNearest',
		'MipMapLinearNearest',
		'MipMapNearestLinear',
		'MipMapLinearLinear'
	];

	const List<String> TextureWraps = const[
		'MirroredRepeat',
		'ClampToEdge',
		'Repeat'
	];

	class AtlasPage {
		String name;
		String format;
		String minFilter;
		String magFilter;
		String uWrap;
		String vWrap;
		Object rendererObject;
		int width, height;
	}

	class AtlasRegion {
		AtlasPage page;
		String name;
		int x, y, width, height;
		double u, v, u2, v2;
		double offsetX, offsetY;
		int originalWidth, originalHeight;
		int index;
		bool rotate;
		List<int> splits;
		List<int> pads;
	}

	abstract class TextureLoader {
		void load (AtlasPage page, String path);
		void unload (Object texture);
	}

