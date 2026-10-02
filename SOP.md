# Standard Operating Procedure (SOP): Touching Stars Development

## Execution Rule
**CRITICAL:** Do not jump to the next phase until the current phase is fully implemented, tested by the user, and explicitly approved. Ask the user for confirmation after each step.

## Phase 1: Core Foundation (The Movement)
1. Configure Project Settings: Setup 2D pixel-art scaling (viewport stretch mode, nearest neighbor filtering) and define Input Map actions (`move_left`, `move_right`, `jump`).
2. Create Player Entity: Build `entities/player.tscn` using `CharacterBody2D`. Implement basic platformer physics (gravity, acceleration, friction, jump).
3. Create Star Entity: Build `entities/star.tscn` using `Area2D`. Emits a `level_completed` signal upon player collision.
4. Basic Tilemap: Create a simple terrain collision layer to serve as the floor.

## Phase 2: Game Loop & Management
1. Level Base Template: Create a base level scene containing a `TileMap`, `Player` instance, `Star` instance, and a `Camera2D` (static view).
2. Game Manager / Global Singleton: Create an AutoLoad script (`Global.gd` or `GameManager.gd`) to track the current level and handle scene transitions (loading `level_02.tscn` when `level_01.tscn` is beaten).
3. Death Mechanic: Implement an instant reload of the current scene when the player dies (hit-kill).

## Phase 3: Hazards & Gimmicks Architecture
1. Base Hazard: Create `entities/hazard.tscn` (Area2D) that triggers player death on `body_entered`.
2. Expand Hazards: Create specific instances like Spikes, Lava, and Moving Platforms using `Path2D` and `AnimatableBody2D`.

## Phase 4: Level Design (Days 1 to 30)
*Reference the file `.notes/00-gemini-new-fase-ideas.txt` for the exact list of the 30 phases.*
Implement levels sequentially starting from Day 1. Only code the specific gimmick required for that current level.