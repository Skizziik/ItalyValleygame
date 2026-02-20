extends BaseMap
## Farmhouse interior — the player's home. Paints tiles programmatically.

const TILE_STONE := Vector2i(3, 0)
const TILE_WOOD := Vector2i(5, 0)
const TILESET_SOURCE_ID: int = 0

@onready var _ground_layer: TileMapLayer = $GroundLayer
@onready var _object_layer: TileMapLayer = $ObjectLayer


func _ready() -> void:
	map_name = "FarmHouse"
	is_interior = true
	map_width_px = Constants.FARMHOUSE_MAP_WIDTH * Constants.TILE_SIZE
	map_height_px = Constants.FARMHOUSE_MAP_HEIGHT * Constants.TILE_SIZE
	_paint_map()
	super._ready()


func _paint_map() -> void:
	var w := Constants.FARMHOUSE_MAP_WIDTH
	var h := Constants.FARMHOUSE_MAP_HEIGHT

	# Fill floor with wood planks
	for x in range(w):
		for y in range(h):
			_ground_layer.set_cell(Vector2i(x, y), TILESET_SOURCE_ID, TILE_WOOD)

	# Stone walls around edges
	for x in range(w):
		_object_layer.set_cell(Vector2i(x, 0), TILESET_SOURCE_ID, TILE_STONE)
		_object_layer.set_cell(Vector2i(x, h - 1), TILESET_SOURCE_ID, TILE_STONE)
	for y in range(h):
		_object_layer.set_cell(Vector2i(0, y), TILESET_SOURCE_ID, TILE_STONE)
		_object_layer.set_cell(Vector2i(w - 1, y), TILESET_SOURCE_ID, TILE_STONE)

	# Clear door opening at bottom center
	var door_x := w / 2
	_object_layer.erase_cell(Vector2i(door_x, h - 1))
	_object_layer.erase_cell(Vector2i(door_x - 1, h - 1))

	# Kitchen counter in top-left (stone blocks, 3 wide)
	for x in range(2, 5):
		_object_layer.set_cell(Vector2i(x, 1), TILESET_SOURCE_ID, TILE_STONE)
