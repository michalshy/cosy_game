package main

import "core:math"
import rl "vendor:raylib"
import ent "entities"
import p "physics"

players := [2]ent.Player{}
boat := ent.Boat{}

update :: proc(delta_time: f32) {
    for &player in players {
        update_player(delta_time, &player)
    }
    update_boat(delta_time)
    update_env()
    collisions()
}

update_player :: proc(dt: f32, player: ^ent.Player) {
    if !player.grounded {
        player.vel.y += p.gravity * dt
    }

    controls: ent.Controls = ent.get_controls(player.side)
    if rl.IsKeyDown(controls.left) {
        player.vel.x = -p.player_base_speed * p.player_speed_ampl * dt
    }
    else if rl.IsKeyDown(controls.right) {
        player.vel.x = p.player_base_speed * p.player_speed_ampl * dt
    } else {
        player.vel.x = 0.0
    }

    player.pos += player.vel * dt
}

update_boat :: proc(dt: f32) {
    boat.time += dt
    move_boat(dt)
}

move_boat :: proc(dt: f32) {
    boat.pos.y += math.sin(boat.time * p.boat_speed) * p.boat_amplitude
}

update_env :: proc() {

}

collisions :: proc() {
    for &player in players {
        if rl.CheckCollisionRecs(
            ent.player_rect(&player), ent.boat_rect(&boat)
        ) {
            player.grounded = true
            player.vel.y = 0
            player.pos.y = boat.pos.y - ent.player_size.y
        } else {
            player.grounded = false
        }
    }
}

draw :: proc() {
    for &player in players {
        draw_player(&player)
    }
    draw_boat()
    draw_env()
}

draw_player :: proc(player: ^ent.Player) {
    rl.DrawRectangleV(
        player.pos,
        ent.player_size,
        player.side == ent.PlayerSide.LEFT ? rl.RED : rl.GREEN
    )
}

draw_boat :: proc() {
    rl.DrawRectangleV(
        boat.pos,
        ent.boat_size,
        rl.DARKGRAY
    )
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
    starting_y := f32(SCREEN_HEIGHT)  - ent.player_size.y - ent.boat_height - 10
    
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
        pos = {(f32(SCREEN_WIDTH) - ent.boat_size.x) / 2.0, f32(SCREEN_HEIGHT) - ent.boat_init_y}
    }

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.SKYBLUE)

        update(rl.GetFrameTime())
        draw()

        rl.EndDrawing()
    }
}