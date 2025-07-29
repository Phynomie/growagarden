-- Services you'll need in Roblox
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- --- CONFIGURATION ---
-- New and comprehensive mutation multipliers based on your provided list
local MUTATION_MULTIPLIERS = {
    -- "Main Multiplier" mutations (Gm) - only one of these should typically be selected
    ["Rainbow"] = 50,
    ["Gold"] = 20,

    -- "Additional" mutations (Mm) - these contribute to the summed part of the formula
    ["Shocked"] = 100,
    ["Frozen"] = 10,
    ["Choc"] = 2,
    ["Moonlit"] = 2,
    ["Bloodlit"] = 4,
    ["Celestial"] = 120,
    ["Disco"] = 125,
    ["Zombified"] = 25,
    ["Plasma"] = 5,
    ["Voidtouched"] = 135,
    ["Pollinated"] = 3,
    ["Honeyglazed"] = 5,
    ["Heavenly"] = 5,
    ["Cooked"] = 10,
    ["Molten"] = 25,
    ["Meteoric"] = 125,
    ["Alienlike"] = 100,
    ["Paradisal"] = 100,
    ["Galactic"] = 120,
    ["Aurora"] = 90,
    ["Cloudtouched"] = 5,
    ["Fried"] = 8,
    ["Ceramic"] = 30,
    ["Ancientamber"] = 50,
    ["Sandy"] = 3,
    ["Tempestous"] = 12,
    ["Friendbound"] = 70,
    ["Infected"] = 75,
    ["Tranquil"] = 20,
    ["Toxic"] = 12,
    ["Radioactive"] = 80,
    ["Corrupt"] = 20,
    ["Subzero"] = 40,
    ["Blitzshock"] = 50,
    ["Jackpot"] = 15,
    ["Touchdown"] = 105,
    ["Static"] = 8,
    ["Harmonisedfoxfire"] = 190,
    ["Harmonisedchakra"] = 35,
}

print("[BaseValueCalculator] Initialized with updated mutation multipliers and formula structure.")

-- --- UI CREATION AND NOTIFICATION ---

-- Notification UI elements
local notificationFrame
local titleLabel
local messageLabel

-- Function to create and manage the sliding notification UI
local function createNotification(title, message)
    -- Initialize UI elements if they don't exist
    if not notificationFrame then
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then
            warn("PlayerGui not found! Cannot create UI notification.")
            warn("--- Notification: " .. title .. " ---")
            warn(message)
            return
        end

        local notificationGui = Instance.new("ScreenGui")
        notificationGui.Name = "BaseValueCalculatorNotificationGui"
        notificationGui.Parent = playerGui
        notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        notificationFrame = Instance.new("Frame")
        notificationFrame.Name = "NotificationFrame"
        notificationFrame.Size = UDim2.new(0.3, 0, 0.1, 0)
        notificationFrame.Position = UDim2.new(0.5, 0, 0.9, 0)
        notificationFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        notificationFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        notificationFrame.BackgroundTransparency = 0.1
        notificationFrame.BorderColor3 = Color3.fromRGB(20, 20, 20)
        notificationFrame.BorderSizePixel = 2
        notificationFrame.Parent = notificationGui
        notificationFrame.Visible = false

        titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "TitleLabel"
        titleLabel.Size = UDim2.new(1, 0, 0.3, 0)
        titleLabel.Position = UDim2.new(0, 0, 0, 0)
        titleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        titleLabel.BackgroundTransparency = 0.2
        titleLabel.TextScaled = true
        titleLabel.Font = Enum.Font.SourceSansBold
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextXAlignment = Enum.TextXAlignment.Center
        titleLabel.TextYAlignment = Enum.TextYAlignment.Center
        titleLabel.Parent = notificationFrame
        titleLabel.ZIndex = 2

        messageLabel = Instance.new("TextLabel")
        messageLabel.Name = "MessageLabel"
        messageLabel.Size = UDim2.new(1, 0, 0.7, 0)
        messageLabel.Position = UDim2.new(0, 0, 0.3, 0)
        messageLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        messageLabel.BackgroundTransparency = 0.5
        messageLabel.TextScaled = true
        messageLabel.Font = Enum.Font.SourceSans
        messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        messageLabel.TextWrapped = true
        messageLabel.TextXAlignment = Enum.TextXAlignment.Center
        messageLabel.TextYAlignment = Enum.TextYAlignment.Center
        messageLabel.Parent = notificationFrame
        messageLabel.ZIndex = 2

        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 8)
        uiCorner.Parent = notificationFrame
    end

    -- Update text and make visible
    titleLabel.Text = title
    messageLabel.Text = message
    notificationFrame.Visible = true

    -- Tween the notification in
    local initialPos = UDim2.new(0.5, 0, 0.9, 0)
    notificationFrame.Position = initialPos + UDim2.new(0, 0, 0.05, 0)
    notificationFrame.BackgroundTransparency = 1
    titleLabel.TextTransparency = 1
    messageLabel.TextTransparency = 1

    TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = initialPos,
        BackgroundTransparency = 0.1
    }):Play()
    TweenService:Create(titleLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    TweenService:Create(messageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()

    task.delay(4, function()
        TweenService:Create(notificationFrame, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = initialPos + UDim2.new(0, 0, 0.05, 0),
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(titleLabel, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        TweenService:Create(messageLabel, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()

        task.delay(0.7, function()
            notificationFrame.Visible = false
        end)
    end)
end

---
--- MAIN CALCULATOR UI
---

-- Ensure the PlayerGui is ready before creating UI
task.spawn(function()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")

    local calculatorGui = Instance.new("ScreenGui")
    calculatorGui.Name = "BaseValueCalculatorUI"
    calculatorGui.Parent = playerGui
    calculatorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "CalculatorFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -150, 0.2, 0)
    mainFrame.AnchorPoint = Vector2.new(0, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 2
    mainFrame.Draggable = true
    mainFrame.Parent = calculatorGui

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = mainFrame

    local titleBar = Instance.new("TextLabel")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    titleBar.BackgroundTransparency = 0.2
    titleBar.Text = "Base Value Calculator (Updated)"
    titleBar.Font = Enum.Font.SourceSansBold
    titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleBar.TextScaled = true
    titleBar.TextWrapped = true
    titleBar.TextXAlignment = Enum.TextXAlignment.Center
    titleBar.TextYAlignment = Enum.TextYAlignment.Center
    titleBar.Parent = mainFrame
    
    local weightLabel = Instance.new("TextLabel")
    weightLabel.Name = "WeightLabel"
    weightLabel.Size = UDim2.new(0.9, 0, 0, 20)
    weightLabel.Position = UDim2.new(0.05, 0, 0, 40)
    weightLabel.Text = "Plant Weight (kg):"
    weightLabel.Font = Enum.Font.SourceSans
    weightLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    weightLabel.BackgroundTransparency = 1
    weightLabel.TextXAlignment = Enum.TextXAlignment.Left
    weightLabel.TextScaled = true
    weightLabel.Parent = mainFrame

    local weightInput = Instance.new("TextBox")
    weightInput.Name = "WeightInput"
    weightInput.Size = UDim2.new(0.9, 0, 0, 30)
    weightInput.Position = UDim2.new(0.05, 0, 0, 65)
    weightInput.PlaceholderText = "e.g., 147"
    weightInput.Text = "147"
    weightInput.Font = Enum.Font.SourceSans
    weightInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    weightInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    weightInput.BackgroundTransparency = 0.2
    weightInput.Parent = mainFrame
    weightInput.ClearTextOnFocus = false
    weightInput.TextScaled = true

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(0.9, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.05, 0, 0, 100)
    valueLabel.Text = "Plant Sold Value ($):"
    valueLabel.Font = Enum.Font.SourceSans
    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.TextScaled = true
    valueLabel.Parent = mainFrame

    local valueInput = Instance.new("TextBox")
    valueInput.Name = "ValueInput"
    valueInput.Size = UDim2.new(0.9, 0, 0, 30)
    valueInput.Position = UDim2.new(0.05, 0, 0, 125)
    valueInput.PlaceholderText = "e.g., 45643009995436"
    valueInput.Text = "45643009995436"
    valueInput.Font = Enum.Font.SourceSans
    valueInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    valueInput.BackgroundTransparency = 0.2
    valueInput.Parent = mainFrame
    valueInput.ClearTextOnFocus = false
    valueInput.TextScaled = true

    -- Container for mutation checkboxes with proper scrolling
    local mutationScrollFrame = Instance.new("ScrollingFrame")
    mutationScrollFrame.Name = "MutationScrollFrame"
    mutationScrollFrame.Size = UDim2.new(0.9, 0, 0, 250) -- Fixed height with scrolling
    mutationScrollFrame.Position = UDim2.new(0.05, 0, 0, 160)
    mutationScrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mutationScrollFrame.BackgroundTransparency = 0.8
    mutationScrollFrame.BorderSizePixel = 0
    mutationScrollFrame.ScrollBarThickness = 8
    mutationScrollFrame.Parent = mainFrame

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Name = "MutationListLayout"
    uiListLayout.FillDirection = Enum.FillDirection.Vertical
    uiListLayout.Padding = UDim.new(0, 5)
    uiListLayout.Parent = mutationScrollFrame

    local uiPadding = Instance.new("UIPadding")
    uiPadding.PaddingTop = UDim.new(0, 5)
    uiPadding.PaddingLeft = UDim.new(0, 5)
    uiPadding.PaddingRight = UDim.new(0, 5)
    uiPadding.Parent = mutationScrollFrame

    -- Store selected mutations
    local selectedMutations = {}
    local mutationCheckboxes = {}

    local function createMutationCheckbox(mutationName, parentFrame, isGmMutation)
        local checkboxFrame = Instance.new("Frame")
        checkboxFrame.Name = mutationName .. "CheckboxFrame"
        checkboxFrame.Size = UDim2.new(1, -10, 0, 25) -- Account for padding
        checkboxFrame.BackgroundTransparency = 1
        checkboxFrame.Parent = parentFrame

        local checkboxButton = Instance.new("TextButton")
        checkboxButton.Name = "Checkbox"
        checkboxButton.Size = UDim2.new(0, 20, 0, 20)
        checkboxButton.Position = UDim2.new(0, 0, 0.5, -10)
        checkboxButton.AnchorPoint = Vector2.new(0, 0.5)
        checkboxButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        checkboxButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
        checkboxButton.BorderSizePixel = 1
        checkboxButton.Text = ""
        checkboxButton.Parent = checkboxFrame

        local checkboxLabel = Instance.new("TextLabel")
        checkboxLabel.Name = "Label"
        checkboxLabel.Size = UDim2.new(1, -25, 1, 0)
        checkboxLabel.Position = UDim2.new(0, 25, 0, 0)
        checkboxLabel.Text = mutationName .. " (" .. MUTATION_MULTIPLIERS[mutationName] .. "x)"
        checkboxLabel.TextXAlignment = Enum.TextXAlignment.Left
        checkboxLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        checkboxLabel.BackgroundTransparency = 1
        checkboxLabel.Font = Enum.Font.SourceSans
        checkboxLabel.TextScaled = true
        checkboxLabel.Parent = checkboxFrame

        local isChecked = false
        checkboxButton.MouseButton1Click:Connect(function()
            -- Handle exclusive selection for Gm mutations (Rainbow/Gold)
            if isGmMutation then
                for gmName, cbData in pairs(mutationCheckboxes) do
                    if (gmName == "Rainbow" or gmName == "Gold") and gmName ~= mutationName then
                        cbData.isChecked = false
                        cbData.button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                        selectedMutations[gmName] = false
                    end
                end
            end

            isChecked = not isChecked
            selectedMutations[mutationName] = isChecked
            checkboxButton.BackgroundColor3 = isChecked and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(80, 80, 80)
            mutationCheckboxes[mutationName].isChecked = isChecked
        end)

        mutationCheckboxes[mutationName] = {
            frame = checkboxFrame, 
            button = checkboxButton, 
            label = checkboxLabel, 
            isChecked = false
        }

        return checkboxFrame
    end

    -- Separate Gm and Mm mutations for checkbox display
    local gmMutationNames = {"Rainbow", "Gold"}
    local mmMutationNames = {}
    for name, _ in pairs(MUTATION_MULTIPLIERS) do
        if name ~= "Rainbow" and name ~= "Gold" then
            table.insert(mmMutationNames, name)
        end
    end
    table.sort(mmMutationNames)

    -- Group for Main Multiplier Mutations (Rainbow/Gold)
    local gmLabel = Instance.new("TextLabel")
    gmLabel.Name = "GmLabel"
    gmLabel.Size = UDim2.new(1, -10, 0, 20)
    gmLabel.Text = "Main Multiplier (select one):"
    gmLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    gmLabel.BackgroundTransparency = 1
    gmLabel.Font = Enum.Font.SourceSansBold
    gmLabel.TextXAlignment = Enum.TextXAlignment.Left
    gmLabel.Parent = mutationScrollFrame

    for _, name in ipairs(gmMutationNames) do
        createMutationCheckbox(name, mutationScrollFrame, true)
    end

    -- Separator
    local separator = Instance.new("Frame")
    separator.Name = "Separator"
    separator.Size = UDim2.new(1, -10, 0, 2)
    separator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    separator.BackgroundTransparency = 0.5
    separator.Parent = mutationScrollFrame

    -- Group for Additional Mutations
    local mmLabel = Instance.new("TextLabel")
    mmLabel.Name = "MmLabel"
    mmLabel.Size = UDim2.new(1, -10, 0, 20)
    mmLabel.Text = "Additional Mutations:"
    mmLabel.TextColor3 = Color3.fromRGB(150, 255, 255)
    mmLabel.BackgroundTransparency = 1
    mmLabel.Font = Enum.Font.SourceSansBold
    mmLabel.TextXAlignment = Enum.TextXAlignment.Left
    mmLabel.Parent = mutationScrollFrame

    for _, name in ipairs(mmMutationNames) do
        createMutationCheckbox(name, mutationScrollFrame, false)
    end

    -- Update CanvasSize when layout changes
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        mutationScrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
    end)

    local calculateButton = Instance.new("TextButton")
    calculateButton.Name = "CalculateButton"
    calculateButton.Size = UDim2.new(0.8, 0, 0, 30)
    calculateButton.Position = UDim2.new(0.1, 0, 1, -40)
    calculateButton.Text = "Calculate Base Value"
    calculateButton.Font = Enum.Font.SourceSansBold
    calculateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    calculateButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    calculateButton.BackgroundTransparency = 0.1
    calculateButton.Parent = mainFrame

    -- Button click logic
    calculateButton.MouseButton1Click:Connect(function()
        local plantWeight = tonumber(weightInput.Text)
        local plantSoldValue = tonumber(valueInput.Text)

        if not plantWeight or not plantSoldValue then
            createNotification("Input Error", "Please enter valid numbers for both weight and value.")
            return
        end

        if plantWeight <= 0 then
            createNotification("Calculation Error", "Weight must be greater than zero.")
            return
        end
        
        -- Determine Gm (Growth Mutation Multiplier)
        local gmMultiplier = 1
        local selectedGmCount = 0
        local gmChosenName = "None"
        for _, name in ipairs(gmMutationNames) do
            if selectedMutations[name] then
                selectedGmCount = selectedGmCount + 1
                gmMultiplier = MUTATION_MULTIPLIERS[name]
                gmChosenName = name
            end
        end

        if selectedGmCount > 1 then
            createNotification("Input Error", "Please select only ONE main multiplier mutation (Rainbow/Gold).")
            return
        elseif selectedGmCount == 0 then
            createNotification("Input Warning", "No main multiplier selected. Using 1x multiplier.")
        end

        -- Calculate Mm (Mutation Multiplier)
        local sumOfMmMultipliers = 0
        local numberOfMmMultipliers = 0
        for name, isChecked in pairs(selectedMutations) do
            if isChecked and not (name == "Rainbow" or name == "Gold") then
                sumOfMmMultipliers = sumOfMmMultipliers + MUTATION_MULTIPLIERS[name]
                numberOfMmMultipliers = numberOfMmMultipliers + 1
            end
        end
        
        local mmFactor = 1 + sumOfMmMultipliers - numberOfMmMultipliers
        if mmFactor < 1 then mmFactor = 1 end

        local totalMultiplier = gmMultiplier * mmFactor
        if totalMultiplier == 0 then
            createNotification("Calculation Error", "Total multiplier became zero. Check selected mutations.")
            return
        end

        local denominator = (plantWeight ^ 2) * totalMultiplier
        if denominator == 0 then
            createNotification("Calculation Error", "Denominator became zero during calculation.")
            return
        end

        local calculatedBaseValue = plantSoldValue / denominator

        createNotification(
            "Calculated Base Value!",
            string.format("For %.3fkg (%s + %d modifiers), sold for $%.0f:\nBase Value: %.15f",
                          plantWeight, gmChosenName, numberOfMmMultipliers, 
                          plantSoldValue, calculatedBaseValue)
        )
    end)

    -- Initial notification
    createNotification("Base Value Calculator", "Window open! Select mutations and enter values.")
end)
