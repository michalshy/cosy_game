package main

import rl "vendor:raylib"

// enums

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

FishingPlaces :: enum {
    STANDARD
}

FishType :: enum {
    ROACH,
    CARP,
    PERCH,
    PIKE,
    CATFISH,
    EEL,
    GOLDFISH
}

FishStats :: struct {
    wait_min: f32,
    wait_max: f32,
    bite_time: f32,
    fight_time: f32,
    fish_speed: f32,
    bar_width: i32,
    value: i32
}

// structs

PlayerSprites :: struct {
    idle: Sprite,
    walk: Sprite,
}


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
    flip: bool,
    current_sprite: ^Sprite,
    fight_game: ^FightGame
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

FightGame :: struct {
    fish:         FishType,
    track_origin: rl.Vector2,  
    fish_t:       f32,         
    fish_vel:     f32,
    bar_t:        f32,         
    on_time:      f32,
}

GameState :: struct {
    players: [2]Player,
    boat: Boat
}