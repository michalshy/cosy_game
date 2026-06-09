package entities

import "core:fmt"
import rl "vendor:raylib"
import u "../utils"

State :: enum {
    IDLE,
    THROW,
    WAIT,
    BITE,
    FIGHT
}

Type :: enum {
    NORMAL
}

ZoneSide :: enum {
    LEFT,
    RIGHT
}

FishingZone :: struct {
    side: ZoneSide,
    pos: rl.Vector2
}

Fishing :: struct {
    state: State,
    type: Type
}

init_zones :: proc(boat: ^Boat) -> [2]FishingZone {
    zones: [2]rl.Vector2 = get_fishing_zones(boat)

    return {
        { side = ZoneSide.LEFT, pos = zones[0] },
        { side = ZoneSide.RIGHT, pos = zones[1] }
    }
}

zone_rect :: proc(zone: ^FishingZone) -> rl.Rectangle {
    return { zone.pos.x, zone.pos.y, u.fishing_zone_size.x, u.fishing_zone_size.y }
}
