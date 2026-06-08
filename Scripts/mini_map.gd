class_name MiniMap
extends Control


@onready var map: TextureRect = $Map

var terrain_gen: TerrainGen

func gen_minimap():
	map.texture = gen_minimap_texture(Vector2i(256, 256))

func gen_minimap_texture(map_size: Vector2i) -> ImageTexture:
	var image = Image.create(map_size.x, map_size.y, false, Image.FORMAT_RGBA8)

	for x in range(map_size.x):
		for y in range(map_size.y):
			var noise_value = terrain_gen.height_noise.get_noise_2d(x, y)
			noise_value = (noise_value + 1) / 2

			var color = Color.BLACK

			for terrain in terrain_gen.terrain_types:
				if terrain and noise_value < terrain.threshold:
					if terrain.is_liquid:
						color = Color.BLUE
					elif terrain.is_mineable:
						color = Color.YELLOW
					else:
						color = Color.GREEN
					break

			image.set_pixel(x, y, color)

	return ImageTexture.create_from_image(image)
