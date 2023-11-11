--[[
    Made by Monnapse

    Types
--]]

--// Directories
local Flow = script.Parent

--// Packages
local Signal = require(Flow.signal)

local Types = {}

export type Manager = {
    name: string, 
    inputs: {Input},
    type: "Vector3" | "Number" | "Boolean",
    value: Vector3 | number | boolean,
    deadzone: number, --// If the gamepad thumbstick is stuck at like 0.0001232742 or -0.01232742 it will convert to 0 | Defaults to 0.1

    Began: Signal.signal,
    Ended: Signal.signal,

    UpdateInput: (Enum.KeyCode | Enum.UserInputType, Enum.KeyCode | Enum.UserInputType) -> nil,
}

export type Input = {
    Input: Enum.KeyCode | Enum.UserInputType,
    Inverted: boolean,
    Axis: Enum.Axis | "X" | "Y" | "Z",
    InUse: boolean
}

return Types