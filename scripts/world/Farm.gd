extends BaseMap
## Farm exterior — the player's home area. Paints tiles programmatically
## using the world tileset. Replace with editor-painted maps once art is ready.

## Tile atlas coordinates (column index in the tileset)
const TILE_GRASS := Vector2i(0, 0)
const TILE_DIRT := Vector2i(1, 0)
const TILE_WATER := Vector2i(2, 0)
const TILE_STONE := Vector2i(3, 0)
const TILE_SAND := Vector2i(4, 0)
const TILE_WOOD := Vector2i(5, 0)
const TILE_FARMLAND := Vector2i(6, 0)

const TILESET_SOURCE_ID: int = 0

@onready var _ground_layer: TileMapLayer = $GroundLayer
@onready var _object_layer: TileMapLayer = $ObjectLayer


func _ready() -> void:
	map_name = "Farm"
	is_interior = false
	map_width_px = Constants.FARM_MAP_WIDTH * Constants.TILE_SIZE
	map_height_px = Constants.FARM_MAP_HEIGHT * Constants.TILE_SIZE
	_paint_map()
	super._ready()


func _paint_map() -> void:
	var w := Constants.FARM_MAP_WIDTH
	var h := Constants.FARM_MAP_HEIGHT

	# Fill ground with grass
	for x in range(w):
		for y in range(h):
			_ground_layer.set_cell(Vector2i(x, y), TILESET_SOURCE_ID, TILE_GRASS)

	# Stone wall border (top, left, right edges)
	for x in range(w):
		_object_layer.set_cell(Vector2i(x, 0), TILESET_SOURCE_ID, TILE_STONE)
		_object_layer.set_cell(Vector2i(x, 1), TILESET_SOURCE_ID, TILE_STONE)
	for y in range(h):
		_object_layer.set_cell(Vector2i(0, y), TILESET_SOURCE_ID, TILE_STONE)
		_object_layer.set_cell(Vector2i(1, y), TILESET_SOURCE_ID, TILE_STONE)
		_object_layer.set_cell(Vector2i(w - 1, y), TILESET_SOURCE_ID, TILE_STONE)
		_object_layer.set_cell(Vector2i(w - 2, y), TILESET_SOURCE_ID, TILE_STONE)

	# Bottom edge with gap for village exit (center-right area)
	for x in range(w):
		if x < 16 or x > 22:
			_object_layer.set_cell(Vector2i(x, h - 1), TILESET_SOURCE_ID, TILE_STONE)
			_object_layer.set_cell(Vector2i(x, h - 2), TILESET_SOURCE_ID, TILE_STONE)

	# Dirt path from house (top center) to village exit (bottom center-right)
	var path_x := w / 2
	for y in range(5, h - 2):
		_ground_layer.set_cell(Vector2i(path_x, y), TILESET_SOURCE_ID, TILE_DIRT)
		_ground_layer.set_cell(Vector2i(path_x - 1, y), TILESET_SOURCE_ID, TILE_DIRT)

	# Horizontal path branch to farmland
	for x in range(path_x - 8, path_x - 1):
		_ground_layer.set_cell(Vector2i(x, 12), TILESET_SOURCE_ID, TILE_DIRT)

	# Path curves to exit
	for x in range(path_x, 20):
		_ground_layer.set_cell(Vector2i(x, h - 3), TILESET_SOURCE_ID, TILE_DIRT)
		_ground_layer.set_cell(Vector2i(x, h - 4), TILESET_SOURCE_ID, TILE_DIRT)

	# Farmland plots (left side, 6x4 area)
	for x in range(6, 12):
		for y in range(8, 18):
			_ground_layer.set_cell(Vector2i(x, y), TILESET_SOURCE_ID, TILE_FARMLAND)

	# Water pond (top-right area, 3x3)
	for x in range(w - 8, w - 5):
		for y in range(5, 8):
			_ground_layer.set_cell(Vector2i(x, y), TILESET_SOURCE_ID, TILE_WATER)
			_object_layer.set_cell(Vector2i(x, y), TILESET_SOURCE_ID, TILE_WATER)

	# House footprint (top center, represented as stone floor)
	var house_x := path_x - 2
	for x in range(house_x, house_x + 5):
		for y in range(2, 5):
			_object_layer.set_cell(Vector2i(x, y), TILESET_SOURCE_ID, TILE_STONE)
