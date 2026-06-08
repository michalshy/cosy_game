package main

import "core:math"
import rl "vendor:raylib"
import ent "entities"
import p "physics"
import "scene"
import u "utils"

players := [2]ent.Player{}
boat := ent.Boat{}

update :: proc(delta_time: f32) {
    for &player in players {
        ent.update_player(delta_time, &player)
    }
    ent.update_boat(&boat, delta_time)
    scene.update_env()
    for &player in players {
        p.collisions(&player, &boat)
    }
}

draw :: proc() {
    for &player in players {
        ent.draw_player(&player)
    }
    ent.draw_boat(&boat)
    scene.draw_env()
}

main :: proc() {

    rl.InitWindow(0, 0, "Fishy")
    rl.ToggleBorderlessWindowed()
    rl.SetTargetFPS(120)
    
    SCREEN_WIDTH := rl.GetScreenWidth()
    SCREEN_HEIGHT := rl.GetScreenHeight()
    respawn_offset :: 150
    starting_y := f32(SCREEN_HEIGHT)  - u.player_size.y - u.boat_init_y - 10
    
    // init players
    players[0] = ent.Player{
        pos = {f32(SCREEN_WIDTH / 4) + respawn_offset, starting_y},
        side = ent.PlayerSide.LEFT
    }
    players[1] = ent.Player{
        pos = {f32(SCREEN_WIDTH - (SCREEN_WIDTH / 4)) - respawn_offset, starting_y},
        side = ent.PlayerSide.RIGHT
    }
    
    // init boat
    boat = ent.Boat{
        pos = {(f32(SCREEN_WIDTH) - u.boat_size.x) / 2.0, f32(SCREEN_HEIGHT) - u.boat_init_y}
    }

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.SKYBLUE)

        update(rl.GetFrameTime())
        draw()

        rl.EndDrawing()
    }
}