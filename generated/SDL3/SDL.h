#pragma once
// Minimal stub for SDL3 — BionicSX2 iOS port uses GameController.framework
#include <stdint.h>
typedef uint8_t Uint8;
typedef uint16_t Uint16;
typedef uint32_t Uint32;
typedef int32_t Sint32;
typedef uint64_t Uint64;
typedef Sint32 SDL_JoystickID;
struct SDL_Joystick;
struct SDL_Gamepad;
struct SDL_Haptic;
struct SDL_Event {};
struct SDL_GamepadAxisEvent { Uint8 which; };
struct SDL_GamepadButtonEvent { Uint8 which; };
struct SDL_JoyAxisEvent { SDL_JoystickID which; };
struct SDL_JoyButtonEvent { SDL_JoystickID which; };
struct SDL_JoyHatEvent { SDL_JoystickID which; };
#define SDL_JOYSTICK_TYPE_GAMEPAD 0
#define SDL_GAMEPAD_AXIS_LEFTX 0
#define SDL_GAMEPAD_BUTTON_A 0
#define SDL_INIT_GAMEPAD 0
#define SDL_INIT_HAPTIC 0
#define SDL_HAPTIC_LEFTRIGHT 0
#define SDL_HAPTIC_POLAR 0
#define SDL_BUTTON_LMASK 1
#define SDL_BUTTON_MMASK 2
#define SDL_BUTTON_RMASK 4
#define SDL_BUTTON_X1MASK 8
#define SDL_BUTTON_X2MASK 16
inline int SDL_Init(Uint32) { return 0; }
inline void SDL_Quit() {}
inline const char* SDL_GetError() { return ""; }
