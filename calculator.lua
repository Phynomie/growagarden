-- Services you'll need in Roblox
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- --- CONFIGURATION ---
-- These are the *constant* modifiers you've provided previously for Rainbow mutation
-- and the sum of all 32 modifiers. These are now outdated and replaced by the comprehensive list below.
-- local RAINBOW_MULTIPLIER = 50
-- local SUM_OF_MODIFIERS = 1566
-- local NUMBER_OF_MODIFIERS = 32
-- local COMBINED_MODIFIER_PART = RAINBOW_MULTIPLIER * (1 + SUM_OF_MODIFIERS - NUMBER_OF_MODIFIERS)

-- New and comprehensive mutation multipliers based on your provided list
local MUTATION_MULTIPLIERS = {
    -- "Main Multiplier" mutations (Gm) - only one of these should typically be selected
    ["Rainbow"] = 50,
    ["Gold"] = 20,

    -- "Additional" mutations (Mm) - these contribute to the summed part of the formula
    ["Shocked"] = 100,
    ["Frozen"] = 10,
    ["Wet"] = 2,
    ["Chilled"] = 2,
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
    ["Dawnbound"] = 150,
    ["Heavenly"] = 5,
    ["Cooked"] = 10,
    ["Burnt"] = 4,
    ["Molten"] = 25,
    ["Meteoric"] = 125,
    ["Windstruck"] = 2,
    ["Alienlike"] = 100,
    ["Sundried"] = 85,
    ["Verdant"] = 4,
    ["Paradisal"] = 100,
    ["Twisted"] = 5,
    ["Galactic"] = 120,
    ["Aurora"] = 90,
    ["Cloudtouched"] = 5,
    ["Drenched"] = 5,
    ["Fried"] = 8,
    ["Amber"] = 10,
    ["Oldamber"] = 20,
    ["Ancientamber"] = 50,
    ["Sandy"] = 3,
    ["Clay"] = 5,
    ["Ceramic"] = 30,
    ["Friendbound"] = 70,
    ["Tempestous"] = 12,
    ["Infected"] = 75,
    ["Tranquil"] = 20,
    ["Corrupt"] = 20,
    ["Chakra"] = 15,
    ["Harmonisedchakra"] = 35,
    ["Foxfire"] = 90,
    ["Harmonisedfoxfire"] = 190,
    ["Toxic"] = 12,
    ["Radioactive"] = 80,
    ["Jackpot"] = 15,
    ["Subzero"] = 40,
    ["Blitzshock"] = 50,
    ["Touchdown"] = 105,
    ["Static"] = 8,
}

-- Default values for G (Growth Factor) and M (Minimum Value)
-- These are often specific to each plant type in Grow a Garden.
-- We're using common approximate values for a general calculator.
local DEFAULT_G_VALUE = 64
local DEFAULT_M_VALUE = 18

print("[BaseValueCalculator] Initialized with updated mutation multipliers and formula structure.")

-- --- UI CREATION AND NOTIFICATION ---

-- Notification UI elements (re-used from your previous script)
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
        notificationGui.Name = "BaseValueCalculatorNotificationGui" -- Unique name
        notificationGui.Parent = playerGui
        notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        notificationFrame = Instance.new("Frame")
        notificationFrame.Name = "NotificationFrame"
        notificationFrame.Size = UDim2.new(0.3, 0, 0.1, 0) -- 30% width, 10% height of screen
        notificationFrame.Position = UDim2.new(0.5, 0, 0.9, 0) -- Centered near bottom
        notificationFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        notificationFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        notificationFrame.BackgroundTransparency = 0.1
        notificationFrame.BorderColor3 = Color3.fromRGB(20, 20, 20)
        notificationFrame.BorderSizePixel = 2
        notificationFrame.Parent = notificationGui
        notificationFrame.Visible = false -- Start invisible

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
        titleLabel.ZIndex = 2 -- Ensure labels are above frame

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
        messageLabel.ZIndex = 2 -- Ensure labels are above frame

        -- Add a UI Corner for a smoother look
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 8)
        uiCorner.Parent = notificationFrame
    end

    -- Update text and make visible
    titleLabel.Text = title
    messageLabel.Text = message
    notificationFrame.Visible = true

    -- Tween the notification in (slide up slightly)
    local initialPos = UDim2.new(0.5, 0, 0.9, 0) -- Always show at the bottom center
    notificationFrame.Position = initialPos + UDim2.new(0, 0, 0.05, 0) -- Start slightly lower to slide up
    notificationFrame.BackgroundTransparency = 1
    titleLabel.TextTransparency = 1
    messageLabel.TextTransparency = 1

    -- Fade in and slide up
    TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = initialPos,
        BackgroundTransparency = 0.1
    }):Play()
    TweenService:Create(titleLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    TweenService:Create(messageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()

    task.delay(4, function() -- Display for 4 seconds
        -- Fade out and slide down
        TweenService:Create(notificationFrame, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = initialPos + UDim2.new(0, 0, 0.05, 0), -- Slide back down
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(titleLabel, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        TweenService:Create(messageLabel, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()

        task.delay(0.7, function() -- Wait for fade out to complete before making invisible
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
    calculatorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- Important for layering

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "CalculatorFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 500) -- Increased size to accommodate mutation checkboxes
    mainFrame.Position = UDim2.new(0.5, -140, 0.2, 0) -- Centered top part of screen
    mainFrame.AnchorPoint = Vector2.new(0, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 2
    mainFrame.Draggable = true -- Make it draggable
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
    titleBar.Text = "Base Value Calculator (Grow a Garden)"
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
    weightInput.Text = "147" -- Default value
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
    valueInput.Text = "45643009995436" -- Default value
    valueInput.Font = Enum.Font.SourceSans
    valueInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    valueInput.BackgroundTransparency = 0.2
    valueInput.Parent = mainFrame
    valueInput.ClearTextOnFocus = false
    valueInput.TextScaled = true

    -- Container for mutation checkboxes
    local mutationScrollFrame = Instance.new("ScrollingFrame")
    mutationScrollFrame.Name = "MutationScrollFrame"
    mutationScrollFrame.Size = UDim2.new(0.9, 0, 0.5, 0) -- Adjusted size to fit in new frame
    mutationScrollFrame.Position = UDim2.new(0.05, 0, 0, 160) -- Position below value input
    mutationScrollFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    mutationScrollFrame.BackgroundTransparency = 0.8
    mutationScrollFrame.BorderSizePixel = 0
    mutationScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated by UILayout
    mutationScrollFrame.ScrollBarThickness = 6
    mutationScrollFrame.Parent = mainFrame

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Name = "MutationListLayout"
    uiListLayout.FillDirection = Enum.FillDirection.Vertical
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    uiListLayout.Padding = UDim.new(0, 5)
    uiListLayout.Parent = mutationScrollFrame

    local uiPadding = Instance.new("UIPadding")
    uiPadding.PaddingTop = UDim.new(0, 5)
    uiPadding.PaddingBottom = UDim.new(0, 5)
    uiPadding.PaddingLeft = UDim.new(0, 5)
    uiPadding.PaddingRight = UDim.new(0, 5)
    uiPadding.Parent = mutationScrollFrame

    -- Store selected mutations
    local selectedMutations = {}
    local mutationCheckboxes = {}

    local function createMutationCheckbox(mutationName, parentFrame, isGmMutation)
        local checkboxFrame = Instance.new("Frame")
        checkboxFrame.Name = mutationName .. "CheckboxFrame"
        checkboxFrame.Size = UDim2.new(1, 0, 0, 25)
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
                    -- Check if it's a GM mutation and not the current one being toggled
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

        mutationCheckboxes[mutationName] = {frame = checkboxFrame, button = checkboxButton, label = checkboxLabel, isChecked = false}

        return checkboxFrame
    end

    -- Separate Gm and Mm mutations for checkbox display
    local gmMutationNames = {"Rainbow", "Gold"}
    local mmMutationNames = {}
    for name, _ in pairs(MUTATION_MULTIPLIERS) do
        local isGm = false
        for _, gmName in ipairs(gmMutationNames) do
            if name == gmName then
                isGm = true
                break
            end
        end
        if not isGm then
            table.insert(mmMutationNames, name)
        end
    end
    table.sort(mmMutationNames) -- Sort alphabetically for better UI

    -- Group for Main Multiplier Mutations (Rainbow/Gold)
    local gmMutationsFrame = Instance.new("Frame")
    gmMutationsFrame.Name = "GmMutationsGroup"
    gmMutationsFrame.Size = UDim2.new(1, 0, 0, 20) -- Will adjust height with content
    gmMutationsFrame.BackgroundTransparency = 1
    gmMutationsFrame.Parent = mutationScrollFrame

    local gmListLayout = Instance.new("UIListLayout")
    gmListLayout.FillDirection = Enum.FillDirection.Vertical
    gmListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    gmListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    gmListLayout.Padding = UDim.new(0, 5)
    gmListLayout.Parent = gmMutationsFrame

    local gmLabel = Instance.new("TextLabel")
    gmLabel.Name = "GmLabel"
    gmLabel.Size = UDim2.new(1, 0, 0, 20)
    gmLabel.Text = "Main Multiplier (select one):"
    gmLabel.TextXAlignment = Enum.TextXAlignment.Left
    gmLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- Yellow for emphasis
    gmLabel.BackgroundTransparency = 1
    gmLabel.Font = Enum.Font.SourceSansBold
    gmLabel.TextScaled = true
    gmLabel.Parent = gmMutationsFrame

    for _, name in ipairs(gmMutationNames) do
        createMutationCheckbox(name, gmMutationsFrame, true)
    end
    gmMutationsFrame.Size = UDim2.new(1, 0, 0, gmListLayout.AbsoluteContentSize.Y) -- Adjust height after adding children

    -- Separator
    local separator = Instance.new("Frame")
    separator.Name = "Separator"
    separator.Size = UDim2.new(1, 0, 0, 2)
    separator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    separator.BackgroundTransparency = 0.5
    separator.Parent = mutationScrollFrame

    -- Group for Additional Mutations
    local mmMutationsFrame = Instance.new("Frame")
    mmMutationsFrame.Name = "MmMutationsGroup"
    mmMutationsFrame.Size = UDim2.new(1, 0, 0, 20) -- Will adjust height with content
    mmMutationsFrame.BackgroundTransparency = 1
    mmMutationsFrame.Parent = mutationScrollFrame

    local mmListLayout = Instance.new("UIListLayout")
    mmListLayout.FillDirection = Enum.FillDirection.Vertical
    mmListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    mmListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    mmListLayout.Padding = UDim.new(0, 5)
    mmListLayout.Parent = mmMutationsFrame

    local mmLabel = Instance.new("TextLabel")
    mmLabel.Name = "MmLabel"
    mmLabel.Size = UDim2.new(1, 0, 0, 20)
    mmLabel.Text = "Additional Mutations (select all that apply):"
    mmLabel.TextXAlignment = Enum.TextXAlignment.Left
    mmLabel.TextColor3 = Color3.fromRGB(150, 255, 255) -- Cyan for emphasis
    mmLabel.BackgroundTransparency = 1
    mmLabel.Font = Enum.Font.SourceSansBold
    mmLabel.TextScaled = true
    mmLabel.Parent = mmMutationsFrame

    for _, name in ipairs(mmMutationNames) do
        createMutationCheckbox(name, mmMutationsFrame, false)
    end
    mmMutationsFrame.Size = UDim2.new(1, 0, 0, mmListLayout.AbsoluteContentSize.Y) -- Adjust height after adding children

    -- Update CanvasSize after all elements are added
    -- This ensures the scroll frame can scroll to all checkboxes
    mutationScrollFrame.CanvasSize = UDim2.new(0, 0, 0, gmMutationsFrame.AbsoluteContentSize.Y + mmMutationsFrame.AbsoluteContentSize.Y + separator.Size.Y.Offset + uiPadding.PaddingTop.Offset + uiPadding.PaddingBottom.Offset + 10) -- Add some buffer


    local calculateButton = Instance.new("TextButton")
    calculateButton.Name = "CalculateButton"
    calculateButton.Size = UDim2.new(0.8, 0, 0, 30)
    calculateButton.Position = UDim2.new(0.1, 0, 1, -40) -- Position at bottom, offset from total height
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

        print(string.format("[BaseValueCalculator] Received Weight: %.5f kg", plantWeight))
        print(string.format("[BaseValueCalculator] Received Sold Value: %.0f", plantSoldValue))

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
            createNotification("Input Warning", "No main multiplier (Rainbow/Gold) selected. Using 1x multiplier.")
        end

        -- Calculate Mm (Mutation Multiplier)
        local sumOfMmMultipliers = 0
        local numberOfMmMultipliers = 0
        for name, isChecked in pairs(selectedMutations) do
            if isChecked and not (name == "Rainbow" or name == "Gold") then -- Exclude Gm mutations from Mm sum
                sumOfMmMultipliers = sumOfMmMultipliers + MUTATION_MULTIPLIERS[name]
                numberOfMmMultipliers = numberOfMmMultipliers + 1
            end
        end
        
        local mmFactor = 1 + sumOfMmMultipliers - numberOfMmMultipliers
        if mmFactor < 1 then mmFactor = 1 end -- Ensure MmFactor is at least 1

        print(string.format("[BaseValueCalculator] Selected Gm: %s (%dx)", gmChosenName, gmMultiplier))
        print(string.format("[BaseValueCalculator] Sum of other (Mm) multipliers: %d", sumOfMmMultipliers))
        print(string.format("[BaseValueCalculator] Number of other (Mm) multipliers: %d", numberOfMmMultipliers))
        print(string.format("[BaseValueCalculator] Calculated Mm_Factor (1 + Sum - Number): %d", mmFactor))

        local totalMultiplier = gmMultiplier * mmFactor
        if totalMultiplier == 0 then
            createNotification("Calculation Error", "Total multiplier became zero. Check selected mutations and inputs.")
            return
        end

        -- --- Reversing Formula 2 to find Base Value ---
        -- Formula 2: value = base_value * weight^2 * (Gm * (1 + Sum_of_Mm_Multipliers - Number_of_Mm_Multipliers))
        -- Rearranged: base_value = value / (weight^2 * Gm * Mm_Factor)

        local denominator = (plantWeight ^ 2) * totalMultiplier
        if denominator == 0 then
            createNotification("Calculation Error", "Denominator became zero during calculation. Cannot divide.")
            return
        end

        local calculatedBaseValue = plantSoldValue / denominator

        print(string.format("[BaseValueCalculator] Calculated Base Value: %.15f", calculatedBaseValue))
        createNotification(
            "Calculated Base Value!",
            string.format("For %.3fkg, sold for $%.0f:\nBase Value: %.15f",
                          plantWeight, plantSoldValue, calculatedBaseValue)
        )
    end)

    -- Initial notification that the UI is ready
    createNotification("Base Value Calculator UI", "Window open! Enter values and select mutations.")
end)
