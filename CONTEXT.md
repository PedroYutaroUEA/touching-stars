# CONTEXT.md — Game Design Document & Specs

## 0. Dice elements picked & Central Metaphor
- **Element 1:** Foot (The act of walking, leaving the room, stepping onto a surface, planting one's feet).
- **Element 2:** Comet / Shooting Star (Dynamic objective, breaking orbit).
- **Premise:** A parody of the *"Go outside and touch some grass"* meme. A sedentary teenage alien lives in his room on the moon. His mother threatens to confiscate his spaceship unless he forms the habit of leaving the house and stepping onto a star or comet at least once a day for 30 consecutive days.

## 1. Game Premises & Identity
- **Title:** Touching Stars
- **Genre:** 2D Precision Platformer (Try-hard / Rage Game, Hit-kill, no mid-level checkpoints).
- **Pitch:** A satire of the phrase "Go outside and touch some grass." You are a sedentary alien living in a room at a lunar base. Your alien mom threatens to confiscate your flying saucer unless you go outside and touch a shooting star every day.
- **References:** *I Wanna Be The Guy*, *Geometry Dash 2.2 Platformer Mode (e.g. Give Up II)*, *Alien Escape*.
- **Camera:** Static 2D single-screen camera. The entire level is visible without scrolling. Base viewport resolution: 1920x1080 (or 640x360 scale with `canvas_items` stretch mode).
- **Style:** 2D pixel art with a retro sci-fi aesthetic (Alien Escape / IWBTG style).
- **Core Loop:** The player (Alien) starts at point A and must touch a moving shooting star (Point B) to clear the level.
- **Progression:** 30 micro-levels (Days). Each level introduces a new trolling mechanic or gimmick (e.g., reversed gravity, fake walls, invisible layers).
- **Control Scheme:** W/Space (Jump), A/Left (Move Left), D/Right (Move Right).

## 2. CONTROLS AND INPUT MAP (Godot Project Settings)
- `move_left`: `A` and `Left Arrow`
- `move_right`: `D` and `Right Arrow`
- `jump`: `W`, `Space`, and `Up Arrow`
- `restart_level`: `R` (instantly reloads the room — critical for "try-hard" games)

## 3. COLLISION MATRIX (2D Physics Layers)
- **Layer 1: `World`** — Floors, solid walls, and static blocks.
- **Layer 2: `Player`** — The playable alien.
- **Layer 3: `Hazards`** — Spikes, lava, projectiles (kill on contact).
- **Layer 4: `Stars`** — Comets/shooting stars (victory area/next-level trigger).
- **Layer 5: `Interactables`** — Pushable boxes, portals, keys, and springs.

## 4. Project Architecture & Standards
The project uses a strict folder structure. Do not create files outside of these directories:
- `/entities/`: Reusable packed scenes (e.g., `player.tscn`, `star.tscn`, `spikes.tscn`).
- `/scenes/`: Game levels and UI screens (e.g., `main_menu.tscn`, `level_01.tscn`).
- `/scripts/`: GDScript files (`.gd`). 
- `/sprites/`: 2D textures and `.png` files.
- `/tiles/`: Tilemap resources and tilesets.

## 5. Coding & Godot Guidelines
- **Typing:** Use strict static typing in GDScript (e.g., `var speed: float = 300.0`, `func move() -> void:`).
- **Signals:** Prefer Godot's Signal system for loose coupling (e.g., Player emits `died`, GameManager listens to restart the scene).
- **Physics:** Use `CharacterBody2D` for the Player and `Area2D` for hit-kill obstacles (spikes, lava).
- **UI:** Keep UI (like the level title "I have to step on stars, but...") in a separate CanvasLayer node to avoid camera scaling issues.

---

## 6. LEVEL SCHEDULE (30 DAYS)

| Day | Level Title | Mechanic / Unique Twist |
|:---|:---|:---|
| **01** | *I have to step on stars, but the floor is lava* | Deadly lava floor; fixed platforms. |
| **02** | *I have to step on stars, but I'm on the moon* | Reduced gravity (40%); floaty jumps. |
| **03** | *I have to step on stars, but there's moving platforms* | Platforms moving along X and Y axes. |
| **04** | *I have to step on stars, but the floor is ice* | Zero floor friction; inertial sliding. |
| **05** | *I have to step on stars, but there's spikes everywhere* | Fixed spikes on primary paths. |
| **06** | *I have to step on stars, but I'm on Saturn* | Heavy gravity (250%); extremely short jumps. |
| **07** | *I have to step on stars, but the gravity is reversed* | Negative gravity pulling toward the ceiling. |
| **08** | *I have to step on stars, but I'm the star* | Roles reversed: control the comet moving toward the stationary alien. |
| **09** | *I have to step on stars, but there is a solar windstorm* | Continuous horizontal force pushing to the left. |
| **10** | *I have to step on stars, but I'm in Portal 2* | Blue/Orange portals preserving entry velocity. |
| **11** | *I have to step on stars, but my jump is on a 3-second cooldown* | Visible cooldown between successive jumps. |
| **12** | *I have to step on stars, but the lights are completely off* | Vision obscured; illumination provided only by the alien's flashlight beam. |
| **13** | *I have to step on stars, but I drank the liquid from inside the thermometer* | Chromatic aberration shader and psychedelic colors. |
| **14** | *I have to step on stars, but the screen wraps around like Pac-Man* | No side walls: exiting to the right causes the player to reappear on the left. |
| **16** | *I have to step on stars, but the moon is invisible* | Hidden wall sprites; only silhouettes are visible. |
| **17** | *I have to step on stars, but idk where the stars even are* | Star locked behind fake walls; key is hidden. |
| **18** | *I have to step on stars, but I fell asleep along the way* | Level with no obvious exit; dying inside the dream wakes you up at the goal. |
| **19** | *I have to step on stars, but there's EVEN MORE spikes everywhere* | Dense spike maze (1-tile clearance). |
| **20** | *I have to step on stars, but everything is a trap* | Fake falling blocks and flying fake spikes. |
| **21** | *I have to step on stars, but I'm being chased by jucimar_lowpolly.png* | Relentless floating sprite chasing the player's position. |
| **22** | *I have to step on stars, but time moves only when I move* | SUPERHOT mechanic: time scales with input speed. |
| **23** | *I have to step on stars, but I'm haunted by my yesterday's ghost* | Ghost trail replicates movements with a 1.5s delay (fatal touch). |
| **24** | *I have to step on stars, but it's a rhythm game* | Platforms and barriers toggle on/off to the beat of the audio. |
| **25** | *I have to step on stars, but I only have 5 seconds before my oxygen runs out* | Strict 5.0-second countdown timer. |
| **26** | *I have to step on stars, but I have to solve a CAPTCHA* | Pop-up windows visually obscure the arena during the jump. |
| **27** | *I have to step on stars, but we are in presidential election season* | Hazard zones featuring political factions; requires collecting camouflage. |
| **28** | *I have to step on stars, but my ship's Wi-Fi is lagging* | Rubberbanding: periodic teleportation back to the state from 0.8 seconds ago. |
| **29** | *I have to step on stars, but I'm John Lennon* | Enemy sniper at the edge of the screen firing predictive bursts. |
| **30** | *I have to step on stars, but I'm on a genocide route* | Final boss fight à la Sans: dense projectile columns and lasers. |