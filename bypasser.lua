-- Decompiled with modifications to work on any farm
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local Remove_Item = GameEvents:WaitForChild("Remove_Item")
local LocalPlayer = game.Players.LocalPlayer
local ShovelPrompt = LocalPlayer.PlayerGui:WaitForChild("ShovelPrompt")
local ConfirmFrame = ShovelPrompt:WaitForChild("ConfirmFrame")

local TargetData = {
    Instance = nil,
    IsPlaceableObject = false
}

local ProtectedPlants = {"Carrot"}
local ValuablePlants = {"Carrot", "Strawberry", "Blueberry", "Orange Tulip", "Tomato", "Corn", "Daffodil", "Chocolate Carrot", 
    "Red Lollipop", "Blue Lollipop", "Nightshade", "Glowshroom", "Mint", "Rose", "Foxglove", "Crocus", "Delphinium", 
    "Manuka Flower", "Lavender", "Nectarshade", "Peace Lily", "Wild Carrot", "Pear", "Horsetail", "Monoblooma", "Dezen"}

local function CheckIfValuable(plantName)
    for _, v in ValuablePlants do
        if string.find(string.lower(plantName), string.lower(v)) then
            return false
        end
    end
    return true
end

local function CheckIfProtected(plantName)
    for _, v in ProtectedPlants do
        if string.find(string.lower(plantName), string.lower(v)) then
            return true
        end
    end
    if string.find(string.lower(plantName), "sprinkler") then
        return true
    end
    return false
end

local CurrentCamera = workspace.CurrentCamera
local Highlight = script.Highlight
local TweenService = game:GetService("TweenService")

local function RaycastToPosition(mousePosition)
    local ray = CurrentCamera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {CollectionService:GetTagged("ShovelIgnore")}
    return workspace:Raycast(ray.Origin, ray.Direction * 500, raycastParams)
end

-- Highlight target objects
RunService.RenderStepped:Connect(function()
    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Shovel [Destroy Plants]") then
        local raycastResult = RaycastToPosition(UserInputService:GetMouseLocation())
        
        if not raycastResult then
            Highlight.Adornee = nil
        else
            local targetModel = raycastResult.Instance:FindFirstAncestorWhichIsA("Model")
            if targetModel and (CollectionService:HasTag(targetModel, "Growable") or CollectionService:HasTag(targetModel, "PlaceableObject")) then
                if Highlight.Adornee ~= targetModel then
                    Highlight.FillTransparency = 1
                    TweenService:Create(Highlight, TweenInfo.new(0.25), {
                        FillTransparency = 0.65
                    }):Play()
                end
                Highlight.Adornee = targetModel
                return
            end
            Highlight.Adornee = nil
        end
    end
    Highlight.Adornee = nil
end)

local Notification = require(ReplicatedStorage.Modules.Notification)
local FruitName = ConfirmFrame:WaitForChild("FruitName")
local DeleteObject = GameEvents:WaitForChild("DeleteObject")

local function handleShovelInput(inputPosition, isTap)
    if isTap then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Shovel [Destroy Plants]") then return end
    
    local raycastResult = RaycastToPosition(inputPosition)
    if not raycastResult then return end
    
    local targetModel = raycastResult.Instance:FindFirstAncestorWhichIsA("Model")
    if not targetModel then return end
    
    -- REMOVED THE FARM OWNERSHIP CHECK HERE
    local plantName = targetModel.Name
    if CheckIfProtected(plantName) then
        Notification:CreateNotification(`You cannot shovel {plantName}!`)
        return
    end
    
    FruitName.Text = plantName
    TargetData.Instance = targetModel
    TargetData.IsPlaceableObject = true
    ShovelPrompt.Enabled = true
end

-- Confirm button actions
ConfirmFrame:WaitForChild("Confirm").MouseButton1Click:Connect(function()
    if TargetData.Instance then
        if TargetData.IsPlaceableObject then
            DeleteObject:FireServer(TargetData.Instance)
        else
            Remove_Item:FireServer(TargetData.Instance)
        end
    end
    TargetData.Instance = nil
    TargetData.IsPlaceableObject = false
    ShovelPrompt.Enabled = false
end)

-- Cancel/exit buttons
local function cancelShovel()
    TargetData.Instance = nil
    TargetData.IsPlaceableObject = false
    ShovelPrompt.Enabled = false
end

ConfirmFrame:WaitForChild("Cancel").MouseButton1Click:Connect(cancelShovel)
ConfirmFrame:WaitForChild("ExitButton").MouseButton1Click:Connect(cancelShovel)

-- Input handling
local inputConnection
local function updateInput()
    if inputConnection then
        inputConnection:Disconnect()
    end
    
    if UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
        inputConnection = UserInputService.TouchTapInWorld:Connect(handleShovelInput)
    else
        inputConnection = LocalPlayer:GetMouse().Button1Down:Connect(function()
            handleShovelInput(UserInputService:GetMouseLocation(), false)
        end)
    end
end

UserInputService.LastInputTypeChanged:Connect(updateInput)
task.spawn(updateInput)
