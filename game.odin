package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

// CONSTANTS

gravity: f32 : 980

boat_speed: f32 : 1.3
boat_amplitude: f32 : 15
boat_size: rl.Vector2 : {600, 80}
boat_init_y: f32 : 250.0

fishing_zone_size: rl.Vector2 : {80,100}

player_base_speed: f32 : 100.0
player_size: rl.Vector2 : {20, 60}

players := [2]Player{}
boat := Boat{}

// ENUMS


FishingState :: enum {
    IDLE,
    THROW,
    WAIT,
    BITE,
    FIGHT
}

FishingType :: enum {
    NORMAL
}

Side :: enum {
    LEFT,
    RIGHT
}

// STRUCTURES

Boat :: struct {
    pos: rl.Vector2,
    vel: rl.Vector2,
    time: f32,
    zones: [2]FishingZone
}

Controls :: struct {
    left: rl.KeyboardKey,
    right: rl.KeyboardKey,
    interact: rl.KeyboardKey
}

Player :: struct {
    enable_movement: bool,
    pos: rl.Vector2,
    vel: rl.Vector2,
    grounded: bool,
    side: Side,
    fishing: Fishing,
    zone: ^FishingZone,
}

FishingZone :: struct {
    side: Side,
    pos: rl.Vector2
}

Fishing :: struct {
    state: FishingState,
    type: FishingType
}

// INITS

init_zones :: proc(boat: ^Boat) -> [2]FishingZone {
    zones: [2]rl.Vector2 = get_fishing_zones(boat)

    return {
        { side = Side.LEFT, pos = zones[0] },
        { side = Side.RIGHT, pos = zones[1] }
    }
}

// UPDATES

update :: proc(delta_time: f32) {
    for &player in players {
        update_player(delta_time, &player)
    }
    update_boat(&boat, delta_time)
    update_env()
    for &player in players {
        collisions(&player, &boat)
    }
}

update_boat :: proc(boat: ^Boat, dt: f32) {
    boat.time += dt
    move_boat(boat, dt)
}

update_player :: proc(dt: f32, player: ^Player) {
    if !player.grounded {
        player.vel.y += gravity * dt
    }

    controls: Controls = get_controls(player.side)
    if player.enable_movement {
        if rl.IsKeyDown(controls.left) {
            player.vel.x = -player_base_speed
        }
        else if rl.IsKeyDown(controls.right) {
            player.vel.x = player_base_speed
        } else {
            player.vel.x = 0.0
        }
    } else {
        player.vel.x = 0.0
    }

    if rl.IsKeyDown(controls.interact) {
        if player.zone != nil {
            player.fishing.state = FishingState.THROW
            player.enable_movement = false
        }
    }
    

    player.pos += player.vel * dt
}


// DRAWS

draw :: proc() {
    for &player in players {
        draw_player(&player)
    }
    draw_boat(&boat)
    draw_env()
}

draw_boat :: proc(boat: ^Boat) {
    rl.DrawRectangleV(
        boat.pos,
        boat_size,
        rl.DARKGRAY
    )

    for zone in boat.zones {
        rl.DrawRectangleV(
            zone.pos,
            fishing_zone_size,
            rl.Color{122, 122, 122, 30}
        )
    }
}

draw_debug :: proc(player: ^Player) {
    text := fmt.ctprintf("Player: %v", player.fishing.state)
    rl.DrawText(text, 10, 10 + i32(player.side == Side.LEFT ? 2 : 1) * 25, 20, rl.WHITE)
}

draw_player :: proc(player: ^Player) {
    rl.DrawRectangleV(
        player.pos,
        player_size,
        player.side == Side.LEFT ? rl.RED : rl.GREEN
    )

    draw_debug(player)
}

// RECTS

boat_rect :: proc(boat: ^Boat) -> rl.Rectangle {
    return { boat.pos.x, boat.pos.y, boat_size.x, boat_size.y }
}

zone_rect :: proc(zone: ^FishingZone) -> rl.Rectangle {
    return { zone.pos.x, zone.pos.y, fishing_zone_size.x, fishing_zone_size.y }
}

player_rect :: proc(player: ^Player) -> rl.Rectangle {
    return { player.pos.x, player.pos.y, player_size.x, player_size.y }
}

// PHYSICS

move_boat :: proc(boat: ^Boat, dt: f32) {
    boat.pos.y = f32(rl.GetScreenHeight()) - boat_init_y + math.sin(boat.time * boat_speed) * boat_amplitude
}

collisions :: proc(player: ^Player, boat: ^Boat) {
    if rl.CheckCollisionRecs(
        player_rect(player), boat_rect(boat)
    ) {
        player.grounded = true
        player.vel.y = 0
        player.pos.y = boat.pos.y - player_size.y
    } else {
        player.grounded = false
    }

    for &zone in boat.zones {
        if rl.CheckCollisionRecs(
            player_rect(player), zone_rect(&zone)
        ) {
            player.zone = &zone
            break
        } else {
            player.zone = nil
        }
    }
}

// GETTERS

get_fishing_zones :: proc(boat: ^Boat) -> [2]rl.Vector2 {
    return {
        { boat.pos.x, boat.pos.y - fishing_zone_size.y },
        { boat.pos.x + boat_size.x - fishing_zone_size.x, boat.pos.y - fishing_zone_size.y }
    }
}

get_controls :: proc(side: Side) -> Controls {
    switch side {
        case .LEFT: return { .A, .D, .S }
        case .RIGHT: return { .J, .L, .K }
    }
    return {} // required
}

update_env :: proc() {

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
    starting_y := f32(SCREEN_HEIGHT)  - player_size.y - boat_init_y - 10
    
    // init players
    players[0] = Player{
        pos = {f32(SCREEN_WIDTH / 4) + respawn_offset, starting_y},
        side = Side.LEFT,
        enable_movement = true
    }
    players[1] = Player{
        pos = {f32(SCREEN_WIDTH - (SCREEN_WIDTH / 4)) - respawn_offset, starting_y},
        side = Side.RIGHT,
        enable_movement = true
    }
    
    // init boat
    boat = Boat{
        pos = {(f32(SCREEN_WIDTH) - boat_size.x) / 2.0, f32(SCREEN_HEIGHT) - boat_init_y},
        time = 0.0,
    }
    boat.zones = init_zones(&boat)

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.SKYBLUE)

        update(rl.GetFrameTime())
        draw()

        rl.EndDrawing()
    }
}