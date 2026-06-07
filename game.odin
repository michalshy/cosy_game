package main

import rl "vendor:raylib"

PlayerSide :: enum {
    LEFT,
    RIGHT
}

Player :: struct {
    pos: rl.Vector2,
    vel: rl.Vector2,
    grounded: bool,
    side: PlayerSide
}
player_size: rl.Vector2 : {20, 60}

Boat :: struct {
    pos: rl.Vector2
}
boat_size: rl.Vector2 : {600, 80}
boat_height: f32 : 250.0


update :: proc(delta_time: f32, players: ^[2]Player) {
    for &player in players {
        update_player(&player)
    }
    update_boat()
    update_env()
}

update_player :: proc(player: ^Player) {

}

update_boat :: proc() {

}

update_env :: proc() {

}

draw :: proc(players: ^[2]Player) {
    for &player in players {
        draw_player(&player)
    }
    draw_boat()
    draw_env()
}

draw_player :: proc(player: ^Player) {
    rl.DrawRectangleV(
        player.pos,
        player_size,
        player.side == PlayerSide.LEFT ? rl.RED : rl.GREEN
    )
}

draw_boat :: proc() {

}

draw_env :: proc() {

}

main :: proc() {

    rl.InitWindow(0, 0, "Fishy")
    rl.ToggleBorderlessWindowed()
    rl.SetTargetFPS(120)
    
    SCREEN_WIDTH := rl.GetScreenWidth()
    SCREEN_HEIGHT := rl.GetScreenHeight()
    respawn_offset :: 150
    starting_y := f32(SCREEN_HEIGHT)  - player_size.y - boat_height
    players := [2]Player{
        Player{
            pos = {f32(SCREEN_WIDTH / 4) + respawn_offset, starting_y},
            side = PlayerSide.LEFT
        }, 
        Player{
            pos = {f32(SCREEN_WIDTH - (SCREEN_WIDTH / 4)) - respawn_offset, starting_y},
            side = PlayerSide.RIGHT
        }
    }

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.SKYBLUE)

        update(rl.GetFrameTime(), &players)
        draw(&players)

        rl.EndDrawing()
    }
}