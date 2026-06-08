class_name MiniMap
extends Control


@export var map_size: Vector2i = Vector2i(512, 256)

@onready var map: TextureRect = $Map

var terrain_gen: TerrainGen

var minimap_image: Image
var minimap_texture: ImageTexture

func init_minimap():
	minimap_image = Image.create(map_size.x, map_size.y, false, Image.FORMAT_RGBA8)
	minimap_texture = ImageTexture.create_from_image(minimap_image)

	map.texture = minimap_texture

func update_minimap_tile(tile_pos: Vector2i, color: Color):
	var center = Vector2i(int(map_size.x/2.0), int(map_size.y/2.0))

	var map_pos = center + tile_pos
	if (map_pos.x >= 0 and
		map_pos.y >= 0 and
		map_pos.x < minimap_image.get_width() and
		map_pos.y < minimap_image.get_height()
	):
		minimap_image.set_pixel(map_pos.x, map_pos.y, color)

func update_minimap():
	minimap_texture.update(minimap_image)
