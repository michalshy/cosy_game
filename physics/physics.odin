package physics

import ent "../entities"
import rl "vendor:raylib"
import u "../utils"

collisions :: proc(player: ^ent.Player, boat: ^ent.Boat) {
    if rl.CheckCollisionRecs(
        ent.player_rect(player), ent.boat_rect(boat)
    ) {
        player.grounded = true
        player.vel.y = 0
        player.pos.y = boat.pos.y - u.player_size.y
    } else {
        player.grounded = false
    }

    for &zone in boat.zones {
        if rl.CheckCollisionRecs(
            ent.player_rect(player), ent.zone_rect(&zone)
        ) {
            player.zone = &zone
            break
        } else {
            player.zone = nil
        }
    }
}