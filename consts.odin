package main

import rl "vendor:raylib"

RENDER_W :: 640
RENDER_H :: 360

gravity: f32 : 980

boat_speed: f32 : 1
boat_amplitude: f32 : 10
boat_size: rl.Vector2 : {240, 40}
boat_init_y: f32 : 80

fishing_zone_size: rl.Vector2 : {20,30}
fishing_pond_size: rl.Vector2 : {40, 10}
fishing_pond_offset: int : 120
bobber_size: rl.Vector2 : {10,10}

throwing_time: f32 : 2.0
wait_time_low: f32 : 3.0
wait_time_high: f32 : 20.0
bite_time_low: f32 : 0.5
bite_time_high: f32 : 1

player_base_speed: f32 : 60.0
player_size: rl.Vector2 : {32, 48}

fight_bar_width: i32 : 50
fight_bar_height: i32 : 150

fish_stats := [FishType]FishStats{
      .ROACH       = { 3,  8,  1.5, 5, 80,  60, 5   },
      .PERCH       = { 5,  12, 1.0, 6, 130, 50, 15  },
      .CARP        = { 8,  15, 0.8, 7, 110, 45, 25  },
      .PIKE        = { 10, 18, 0.7, 8, 180, 40, 50  },
      .CATFISH     = { 12, 20, 0.6, 9, 160, 35, 60  },
      .EEL         = { 8,  16, 0.5, 10, 220, 30, 80  },
      .GOLDFISH    = { 15, 20, 0.4, 11, 250, 25, 200 },
  }

bar_pos := [Side]rl.Vector2{
    .LEFT = {470, 260},
    .RIGHT = {120, 260}
}