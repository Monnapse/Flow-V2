--[[
    Made by Monnapse

    Flow V2

    Flow is an input manager to handle all of your game inputs.
--]]

--// Directories

--// Roblox Packages
local UserInputService = game:GetService("UserInputService")

--// Packages
local Types = require(script.types)
local Signal = require(script.signal)

local Functions = {}

function Functions:UpdateInput(input: Enum.KeyCode | Enum.UserInputType, newinput: Enum.KeyCode | Enum.UserInputType)
    for index, Input: Types.Input in pairs(self.Inputs) do
        if Input.Input == input then
            --// Change Input
            Input.Input = newinput or input
            return
        end
    end

    --// Could not find input
    print("Error: Could not find input:",input.Name)
end

function GetValueFixed(beganValue: Vector3 | number | boolean , endValue: Vector3 | number | boolean, inputState: Enum.UserInputState)
    if inputState == Enum.UserInputState.Begin or inputState == Enum.UserInputState.Change then
        return beganValue
    elseif inputState == Enum.UserInputState.End then
        return endValue
    end

    print("Invalid Input State")
    return endValue
end

local function getAxis(axis: Enum.Axis | "X" | "Y" | "Z")
    if type(axis) == "string" then return axis
    else
        return axis.Name
    end
end

function getMinMax(value: number, min: number, max: number)
    if value < min then return min
    elseif value > max then return max end
end

function GetPosition(input: InputObject): Vector3
    if UserInputService.GamepadConnected and input.Position then 
        local Position = input.Position
        local X = getMinMax(Position.X, -1, 1)
        local Y = getMinMax(Position.Y, -1, 1)
        local Z = getMinMax(Position.Z, -1, 1)
        return Vector3.new(X,Y,Z)
    end
    return Vector3.new(1,1,1) --// If no position then return vector of 1
end

--// Checks if inputobject is gamepad stick
function isStickInput(input: InputObject)
    if input.Position.X > 1 or input.Position.Y > 1 or input.Position.Z > 1 then
        return false
    end
    return true
end

function Functions:BuildVector3(input: InputObject): Vector3
    --// Check if gamepad stick, if true then return the position
    if isStickInput(input) then return input.Position end

    local InputData = self:GetInputData(input)
    if not InputData then return end --// Input not found

    local X = self.value.X
    local Y = self.value.Y
    local Z = self.value.Z

    if getAxis(InputData.Axis) == "X" then
        if InputData.InUse then
            X = GetPosition(input).X or 1
        else
            X = 0
        end
        if InputData.Inverted then X = invertValue(X) end --// If Input Invert then Invert Number
    elseif getAxis(InputData.Axis) == "Y" then
        if InputData.InUse then
            Y = GetPosition(input).Y or 1
        else
            Y = 0
        end
        if InputData.Inverted then Y = invertValue(Y) end --// If Input Invert then Invert Number
    elseif getAxis(InputData.Axis) == "Z" then
        if InputData.InUse then
            Z = GetPosition(input).Z or 1
        else
            Z = 0
        end
        if InputData.Inverted then Z = invertValue(Z) end --// If Input Invert then Invert Number
    end
    
    return Vector3.new(X,Y,Z)
end

function Functions:BuildVector3End(): Vector3
    local X = 0
    local Y = 0
    local Z = 0

    for index, Input: Types.Input in pairs(self.inputs) do
        if Input.InUse then
            if getAxis(Input.Axis) == "X" then
                X = 1
                if Input.Inverted then X = invertValue(X) end --// If Input Invert then Invert Number
            elseif getAxis(Input.Axis) == "Y" then
                Y = 1
                if Input.Inverted then Y = invertValue(Y) end --// If Input Invert then Invert Number
            elseif getAxis(Input.Axis) == "Z" then
                Z = 1
                if Input.Inverted then Z = invertValue(Z) end --// If Input Invert then Invert Number
            end
        end
    end

    return Vector3.new(X,Y,Z)
end

function invertNumber(number: number)
    return number * -1
end
function invertValue(value: Vector3 | number | boolean)
    if type(value) == "vector" then
        return Vector3.new(invertNumber(value.X),invertNumber(value.Y),invertNumber(value.Z))
    elseif type(value) == "number" then
        return invertNumber(value)
    elseif type(value) == "boolean" then
        return not value
    end
end

function addDeadzone(number: number, deadzone: number)
    if number > 0 and number < deadzone then return 0 --// Positive
    elseif number < 0 and number > -deadzone then return 0 --// Negative
    else return number end
end

function addDeadzoneToVector(vector: Vector3, deadzone: number): Vector3
    return Vector3.new(addDeadzone(vector.X, deadzone),addDeadzone(vector.Y, deadzone),addDeadzone(vector.Z, deadzone))
end

function Functions:GetValue(input: InputObject, inputState: Enum.UserInputState): Vector3 | number | boolean
    local InputData = self:GetInputData(input)
    if not InputData then return end --// Input not found
    local Value = nil
    
    if self.type == "Vector3" then
        Value = GetValueFixed(self:BuildVector3(input),self:BuildVector3End(), inputState)
        Value = addDeadzoneToVector(Value, self.deadzone)
    elseif self.type == "Number" then
        local v = 1
        if input.Position ~= nil then
            v = input.Position
        end
        Value = GetValueFixed(v,0,inputState)
        if InputData.Inverted then Value = invertValue(Value) end
    elseif self.type == "Boolean" then
        Value = GetValueFixed(true,false,inputState)
        if InputData.Inverted then Value = invertValue(Value) end
    end

    return Value
end

function Functions:GetInputData(input: InputObject): Types.Input
    for index, InputData: Types.Input in pairs(self.inputs) do
        if InputData.Input == input.KeyCode or InputData.Input == input.UserInputType then
            return InputData
        end
    end

    return false
end

function Functions:InputChanged(input: InputObject, inputState: Enum.UserInputState)
    if not input then return end
    local InputData = self:GetInputData(input)
    if not InputData then return end --// Input not found

    --// Check if the input is in use
    if inputState == Enum.UserInputState.Begin then
        InputData.InUse = true
    else
        InputData.InUse = false
    end

    local Value = self:GetValue(input, inputState)
    if Value == nil then print ("Could not get value") return end
    self.value = Value

    --// Send Signal
    if inputState == Enum.UserInputState.Begin then
        self.Began:Fire(self.value)
    else
        self.Ended:Fire(self.value)
    end
end

local Flow = {}
Flow.Types = {
    Vector3 = "Vector3",
    Number = "Number",
    Boolean = "Boolean"
}

function Flow.NewManager(name: string, inputs: {Types.Input}, type: "Vector3" | "Number" | "Boolean", deadzone: number | nil ?): Types.Manager
    local self = table.clone(Functions)
    
    --// Set Defaults
    self.name = name
    self.inputs = inputs
    self.type = type
    self.value = nil
    self.deadzone = deadzone or 0.1
    
    --// Signals
    self.Began = Signal.new()
    self.Ended = Signal.new()

    --// Set Value Default
    if type == "Vector3" then
        self.value = Vector3.new(0,0,0)
    elseif type == "Number" then
        self.value = 0
    elseif type == "Boolean" then
        self.value = false
    end

    UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent)
        if gameProcessedEvent then return end
        self:InputChanged(input, Enum.UserInputState.Begin)
    end)
    UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent)
        if gameProcessedEvent then return end
        self:InputChanged(input, Enum.UserInputState.End)
    end)
    UserInputService.InputChanged:Connect(function(input: InputObject, gameProcessedEvent)
        if gameProcessedEvent then return end
        self:InputChanged(input, Enum.UserInputState.Begin)
    end)

    return self
end

function Flow.NewInput(input: Enum.KeyCode | Enum.UserInputType, inverted: boolean ?, axis: Enum.Axis | "X" | "Y" | "Z" ?): Types.Input
    return {
        Input = input,
        Inverted = inverted or false,
        Axis = axis or Enum.Axis.X,
        InUse = false
    }
end

return Flow