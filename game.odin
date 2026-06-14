package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

// GLOBS

gravity: f32 : 980

boat_speed: f32 : 1.3
boat_amplitude: f32 : 15
boat_size: rl.Vector2 : {600, 80}
boat_init_y: f32 : 250.0

fishing_zone_size: rl.Vector2 : {80,100}
fishing_pond_size: rl.Vector2 : {120, 40}
fishing_pond_offset: int : 120
bobber_size: rl.Vector2 : {20,20}

throwing_time: f32 : 2.0
wait_time_low: f32 : 3.0
wait_time_high: f32 : 20.0
bite_time_low: f32 : 0.5
bite_time_high: f32 : 1

player_base_speed: f32 : 100.0
player_size: rl.Vector2 : {20, 60}

players := [2]Player{}
boat := Boat{}

PlayerSprites :: struct {
    idle: Sprite,
    walk: Sprite,
}

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
    pos: rl.Vector2,
    vel: rl.Vector2,
    grounded: bool,
    side: Side,
    fishing: Fishing,
    zone: ^FishingZone,
    sprites: PlayerSprites,
    current_sprite: ^Sprite
}

FishingZone :: struct {
    side: Side,
    pos: rl.Vector2,
    pond: rl.Vector2,
    bobber_pos: rl.Vector2
}

Fishing :: struct {
    state: FishingState,
    type: FishingType,
    timer: f32,
    power: f32,
    bobber_active: bool
}

Sprite :: struct {
    texture: rl.Texture2D,
    frame: i32,
    frame_count: i32,
    frame_w: f32,
    frame_h: f32,
    timer: f32,
    frame_time: f32
}

// INITS

init_zones :: proc(boat: ^Boat) -> [2]FishingZone {
    zones: [2]rl.Vector2 = get_fishing_zones(boat)
    ponds: [2]rl.Vector2 = get_fishing_ponds(boat)

    return {
        { side = Side.LEFT, pos = zones[0], pond = ponds[0] },
        { side = Side.RIGHT, pos = zones[1], pond = ponds[1] }
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
    update_fishing(player, dt);

    if !player.grounded {
        player.vel.y += gravity * dt
    }

    controls: Controls = get_controls(player.side)
    if player.fishing.state == .IDLE {
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

    if rl.IsKeyPressed(controls.interact) {
        if player.zone != nil && player.fishing.state == .IDLE {
            player.fishing.state = .THROW
            player.fishing.timer = throwing_time
        }
        if player.fishing.state == .BITE {
            player.fishing.state = .FIGHT
        }
    }
    if rl.IsKeyReleased(controls.interact) {
        if player.zone != nil && player.fishing.state == .THROW {
            // we still successed to throw
            if player.fishing.timer >= 0.0 {
                // add power
                player.fishing.state = .WAIT
                player.fishing.power = 1.0 - (player.fishing.timer / throwing_time)
                player.fishing.bobber_active = true
                t := player.side == .LEFT ? (1.0 - player.fishing.power) : player.fishing.power
                player.zone.bobber_pos.x = player.zone.pond.x + fishing_pond_size.x * t
                player.zone.bobber_pos.y = player.zone.pond.y + bobber_size.y/2
                player.fishing.timer = rand.float32_range(wait_time_low, wait_time_high)
            }
        }
    }

    if player.fishing.state == .FIGHT {
        player.fishing.state = .IDLE
        player.fishing.bobber_active = false
        player.fishing.power = 0
    }

    player.pos += player.vel * dt
}

update_fishing :: proc(player: ^Player, dt: f32) {
    player.fishing.timer -= dt
    switch player.fishing.state
    {
        case .IDLE: return
        case .THROW: {
            if player.fishing.timer <= 0 {
                player.fishing.state = .IDLE
            }
        }
        case .WAIT: {
            if player.fishing.timer <= 0 {
                player.fishing.state = .BITE
                player.fishing.timer = bite_time_high
            }
        }
        case .BITE: {
            if player.fishing.timer <= 0 {
                player.fishing.state = .IDLE
            }
        }
        case .FIGHT: {

        }
    }
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

    // debug
    for zone in boat.zones {
        rl.DrawRectangleV(
            zone.pos,
            fishing_zone_size,
            rl.Color{122, 122, 122, 30}
        )

        rl.DrawRectangleV(
            zone.pond,
            fishing_pond_size,
            rl.Color{122, 122, 122, 30}
        )
    }
}

draw_debug :: proc(player: ^Player) {
    text := fmt.ctprintf("Player: %v", player.fishing.state)
    rl.DrawText(text, 10, 10 + i32(player.side == Side.LEFT ? 2 : 1) * 25, 20, rl.WHITE)
}

draw_player :: proc(player: ^Player) {
    src := rl.Rectangle{
        f32(player.current_sprite.frame) * player.current_sprite.frame_w,
        0,
        player.current_sprite.frame_w,
        player.current_sprite.frame_h,
    }
    rl.DrawTextureRec(player.current_sprite.texture, src, player.pos, rl.WHITE)

    switch player.fishing.state {
        case .IDLE: break
        case .THROW: {
            draw_throwing(player)
        }
        case .WAIT: {
            draw_bobber(player)
        }
        case .BITE: {
            draw_bobber(player)
        }
        case .FIGHT: {
            draw_bobber(player)
        }
    }

    draw_debug(player)
}

draw_throwing :: proc(player: ^Player) {
    progress := 1.0 - (player.fishing.timer / throwing_time)

    bar_w: f32 = 60
    bar_h: f32 = 8
    x := player.pos.x - (bar_w - player_size.x) / 2
    y := player.pos.y - 20

    rl.DrawRectangle(i32(x), i32(y), i32(bar_w), i32(bar_h), rl.GRAY)
    rl.DrawRectangle(i32(x), i32(y), i32(bar_w * progress), i32(bar_h), rl.YELLOW)
}

draw_bobber :: proc(player: ^Player) {
    if player.fishing.bobber_active {
        rl.DrawRectangle(i32(player.zone.bobber_pos.x), i32(player.zone.bobber_pos.y), i32(bobber_size.x), i32(bobber_size.y), rl.RED)
    }
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

get_fishing_ponds :: proc(boat: ^Boat) -> [2]rl.Vector2 {
    return {
        { boat.pos.x - fishing_pond_size.x - f32(fishing_pond_offset), boat.pos.y + boat_size.y / 2 },
        { boat.pos.x + boat_size.x + f32(fishing_pond_offset), boat.pos.y + boat_size.y / 2 }
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

load_sprite :: proc(path: cstring, frame_count: i32, frame_time: f32) -> Sprite {
    tex := rl.LoadTexture(path)
    return {
        texture = tex,
        frame_count = frame_count,
        frame_w     = f32(tex.width) / f32(frame_count),
        frame_h     = f32(tex.height),
        frame_time  = frame_time,
    }
}

load_sprites :: proc() {
    players[0].sprites.idle = load_sprite("assets/fisherman/idle.png", 6, 0.15)
    players[0].sprites.walk = load_sprite("assets/fisherman/walk.png", 6, 0.15)
    players[1].sprites.idle = load_sprite("assets/fisherman/idle.png", 6, 0.15)
    players[1].sprites.walk = load_sprite("assets/fisherman/walk.png", 6, 0.15)
}

unload_sprites :: proc() {
    rl.UnloadTexture(players[0].sprites.idle.texture)
    rl.UnloadTexture(players[1].sprites.idle.texture)
    rl.UnloadTexture(players[0].sprites.walk.texture)
    rl.UnloadTexture(players[1].sprites.walk.texture)
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
        side = Side.LEFT
    }
    players[1] = Player{
        pos = {f32(SCREEN_WIDTH - (SCREEN_WIDTH / 4)) - respawn_offset, starting_y},
        side = Side.RIGHT
    }
    
    // init boat
    boat = Boat{
        pos = {(f32(SCREEN_WIDTH) - boat_size.x) / 2.0, f32(SCREEN_HEIGHT) - boat_init_y},
        time = 0.0,
    }
    boat.zones = init_zones(&boat)

    load_sprites()
    players[0].current_sprite = &players[0].sprites.idle;
    players[1].current_sprite = &players[1].sprites.idle;

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.SKYBLUE)

        update(rl.GetFrameTime())
        draw()

        rl.EndDrawing()
    }

    unload_sprites()
}