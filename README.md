# Flow V2
## Example

```
--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Directories
local packages = ReplicatedStorage:WaitForChild("packages")

--// Packages
local flow = require(packages.Flow)

--// Inputs
local movementInputs = {
    flow.NewInput(Enum.KeyCode.Thumbstick1), 
    flow.NewInput(Enum.KeyCode.W, false, "Y"), 
    flow.NewInput(Enum.KeyCode.S, true, "Y"), 
    flow.NewInput(Enum.KeyCode.A, false, "X"), 
    flow.NewInput(Enum.KeyCode.D, true, "X")
}

--// Input Managers
local movementManager = flow.NewManager("Movement", movementInputs, "Vector3")

movementManager.Began:Connect(function(value)
    print("Input Began: ", value)
end)
movementManager.Ended:Connect(function(value)
    print("Input Ended: ", value)
end)
```