# ACTIVE TASK

## Current Phase: Phase 2 - Level Design (Fundamentals and Gravity/Physics)
### Block 2: Levels 01 to 06
- [x] Level 01: The floor is lava (Deadly lava floor; fixed platforms)
- [x] Level 02: Moon gravity (Reduced gravity (40%); floaty jumps)
- [x] Level 03: Moving platforms (Platforms moving along X and Y axes)
- [x] Level 04: Floor is ice (Zero floor friction; inertial sliding)
  - [x] Align requirements and physics edge cases via Grill-Me questionnaire
  - [x] Update TileSet in base_level.tscn with new SVG tiles (ice, broken station outter, corner, filling)
  - [x] Implement dynamic surface detection and ice physics in player.gd
  - [x] Create scripts/level_04.gd and scenes/level_04.tscn with 3-tier vertical parkour, narrow ice pillars (2-3 tiles), safe havens, and ceiling hazards
  - [x] Verify scene progression and syntax
- [x] Level 05: Spikes everywhere (Fixed spikes on primary paths)
  - [x] Align requirements and physics edge cases via Grill-Me questionnaire
  - [x] Add 4-directional spike alternatives (left, right) to TileSet in base_level.tscn
  - [x] Adjust spike hazard hitbox to fair precision tolerance (Geometry Dash rectangular inset hitboxes avoiding corner edge collisions)
  - [x] Refactor player hazard detection to check exact spike Rect2 intersection, preventing false deaths on platform corners and wall descents
  - [x] Create scripts/level_05.gd and scenes/level_05.tscn with intense maze layout (IWBTG / Every End style)
  - [x] Verify scene progression and syntax
- [x] Level 06: Saturn gravity (Heavy gravity (250%); extremely short jumps)
  - [x] Align requirements and physics edge cases via Grill-Me questionnaire
  - [x] Implement 4-tier vertical descent ("cima para baixo") in scripts/level_06.gd and scenes/level_06.tscn
  - [x] Configure heavy gravity multiplier (2.5x) with low ceiling drops, lateral shaft spikes, and base pedestal goal
  - [x] Verify scene progression and syntax

## Current Phase: Phase 5 - Presentation, Game Screens Workflow & Polish
### Block 5: Game Screens & Navigation
- [x] Startpage (Main Menu) with options: JOGAR (Start), CONFIGURAÇÕES (Settings), SAIR (Exit)
- [x] Helper & GitHub round buttons on Main Menu with controls modal dialog and link to GitHub profile
- [x] In-game visual and descriptive floating controls tutorial in Level 01
- [x] Simple unlockable Level Selector (Alien Escape trail style) with connected path, locks, and Back button
- [x] Settings Menu with Godot Audio Buses (Master, Music, SFX), interactive volume sliders and test sound
- [x] Translucent Pause Menu window (triggered by Esc) with Resume, Restart, Settings, and Main Menu options
- [x] GameManager autoload for level progress unlocking and audio persistence (user://save.cfg)
- [x] Player movement particles (Geometry Dash trail puffs when running + impact burst when landing on platforms)
- [x] Ambient environment particles (smoothly pulsating static background stars matching level themes, sporadic lava splashes, and ice mist/glitter)
- [x] Floating Level Complete modal (Geometry Dash style) showing run time, session attempts, personal best attempts persistence, jump counter, and actions: Replay, Next Level, and Level Select
