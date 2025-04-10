local TweenService = game:GetService("TweenService")
local InputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function DarkenColor(color, factor)
    local h, s, v = color:ToHSV()
    return Color3.fromHSV(h, s, math.max(0, v * factor))
end

local Linux = {
    Theme = {
        Background = DarkenColor(Color3.fromRGB(24, 24, 24), 0.8),
        Element = DarkenColor(Color3.fromRGB(28, 28, 28), 0.8),
        Accent = Color3.fromRGB(80, 120, 255),
        Text = Color3.fromRGB(180, 180, 180),
        Toggle = DarkenColor(Color3.fromRGB(40, 40, 40), 0.8),
        TabInactive = DarkenColor(Color3.fromRGB(28, 28, 28), 0.8),
        DropdownOption = DarkenColor(Color3.fromRGB(30, 30, 30), 0.8),
        Border = Color3.fromRGB(50, 50, 50),
        Shadow = Color3.fromRGB(0, 0, 0),
        Glow = Color3.fromRGB(100, 150, 255)
    }
}

function Linux.Instance(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    return inst
end

function Linux:ApplyShadow(element, shadowColor, offset, transparency)
    local shadow = Linux.Instance("Frame", {
        Parent = element,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0, offset, 0, offset),
        ZIndex = element.ZIndex - 1
    })

    local shadowInner = Linux.Instance("Frame", {
        Parent = shadow,
        BackgroundColor3 = shadowColor or Linux.Theme.Shadow,
        BackgroundTransparency = transparency or 0.5,
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0
    })

    Linux.Instance("UICorner", {
        Parent = shadowInner,
        CornerRadius = UDim.new(0, 5)
    })

    return shadow
end

function Linux:ApplyGradient(element, colorSequence, rotation)
    local gradient = Linux.Instance("UIGradient", {
        Parent = element,
        Color = colorSequence or ColorSequence.new({
            ColorSequenceKeypoint.new(0, Linux.Theme.Element),
            ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.Element, 0.9))
        }),
        Rotation = rotation or 90
    })
    return gradient
end

function Linux:ApplyBorder(element, borderColor, thickness, transparency)
    local stroke = Linux.Instance("UIStroke", {
        Parent = element,
        Color = borderColor or Linux.Theme.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
    return stroke
end

function Linux:ApplyHoverEffect(element, hoverColor, originalColor, scaleIncrease)
    local originalSize = element.Size
    local hoverTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local originalTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

    element.MouseEnter:Connect(function()
        TweenService:Create(element, hoverTweenInfo, {
            BackgroundColor3 = hoverColor or Linux.Theme.Accent,
            Size = UDim2.new(
                originalSize.X.Scale, originalSize.X.Offset + (scaleIncrease or 2),
                originalSize.Y.Scale, originalSize.Y.Offset + (scaleIncrease or 2)
            )
        }):Play()
    end)

    element.MouseLeave:Connect(function()
        TweenService:Create(element, originalTweenInfo, {
            BackgroundColor3 = originalColor or element.BackgroundColor3,
            Size = originalSize
        }):Play()
    end)
end

function Linux:ApplyRippleEffect(element, rippleColor)
    local ripple = Linux.Instance("Frame", {
        Parent = element,
        BackgroundColor3 = rippleColor or Linux.Theme.Glow,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        ZIndex = element.ZIndex + 1,
        ClipsDescendants = true
    })

    Linux.Instance("UICorner", {
        Parent = ripple,
        CornerRadius = UDim.new(1, 0)
    })

    local rippleTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(ripple, rippleTweenInfo, {
        Size = UDim2.new(2, 0, 2, 0),
        BackgroundTransparency = 1
    }):Play()

    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

function Linux:SafeCallback(Function, ...)
    if not Function then
        return
    end

    local Success, Error = pcall(Function, ...)
    if not Success then
        self:Notify({
            Title = "Callback Error",
            Content = tostring(Error),
            Duration = 5
        })
    end
end

function Linux:Notify(config)
    local isMobile = InputService.TouchEnabled and not InputService.KeyboardEnabled
    local notificationWidth = isMobile and 200 or 300
    local notificationHeight = config.SubContent and 80 or 60
    local startPosX = isMobile and 10 or 20

    local NotificationHolder = Linux.Instance("ScreenGui", {
        Name = "NotificationHolder",
        Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui"),
        ResetOnSpawn = false,
        Enabled = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local Notification = Linux.Instance("Frame", {
        Parent = NotificationHolder,
        BackgroundColor3 = Linux.Theme.Background,
        Size = UDim2.new(0, notificationWidth, 0, notificationHeight),
        Position = UDim2.new(1, 10, 1, -notificationHeight - 10),
        ZIndex = 100
    })

    Linux.Instance("UICorner", {
        Parent = Notification,
        CornerRadius = UDim.new(0, 5)
    })

    Linux:ApplyShadow(Notification, Linux.Theme.Shadow, 5, 0.5)
    Linux:ApplyGradient(Notification, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Linux.Theme.Background),
        ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.Background, 0.8))
    }), 45)

    local TitleLabel = Linux.Instance("TextLabel", {
        Parent = Notification,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 0, 5),
        Font = Enum.Font.SourceSansBold,
        Text = config.Title or "Notification",
        TextColor3 = Linux.Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 101
    })

    local ContentLabel = Linux.Instance("TextLabel", {
        Parent = Notification,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 0, 25),
        Font = Enum.Font.SourceSans,
        Text = config.Content or "Content",
        TextColor3 = Linux.Theme.Text,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 101
    })

    if config.SubContent then
        local SubContentLabel = Linux.Instance("TextLabel", {
            Parent = Notification,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 0, 20),
            Position = UDim2.new(0, 5, 0, 45),
            Font = Enum.Font.SourceSans,
            Text = config.SubContent,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 101
        })
    end

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(Notification, tweenInfo, {Position = UDim2.new(0, startPosX, 1, -notificationHeight - 10)}):Play()

    if config.Duration then
        task.delay(config.Duration, function()
            TweenService:Create(Notification, tweenInfo, {Position = UDim2.new(1, 10, 1, -notificationHeight - 10)}):Play()
            task.wait(0.5)
            NotificationHolder:Destroy()
        end)
    end
end

function Linux.Create(config)
    local randomName = "UI_" .. tostring(math.random(100000, 999999))

    for _, v in pairs(game.CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name:match("^UI_%d+$") then
            v:Destroy()
        end
    end

    local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

    local LinuxUI = Linux.Instance("ScreenGui", {
        Name = randomName,
        Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui"),
        ResetOnSpawn = false,
        Enabled = true
    })

    ProtectGui(LinuxUI)

    local FakeUI = Instance.new("ScreenGui", game:GetService("CoreGui"))
    FakeUI.Name = "FakeUI"
    FakeUI.Enabled = false
    FakeUI.ResetOnSpawn = false

    local tabWidth = config.TabWidth or 110

    local isMobile = InputService.TouchEnabled and not InputService.KeyboardEnabled
    local uiSize = isMobile and (config.SizeMobile or UDim2.fromOffset(300, 500)) or (config.SizePC or UDim2.fromOffset(550, 355))

    local Main = Linux.Instance("Frame", {
        Parent = LinuxUI,
        BackgroundColor3 = Linux.Theme.Background,
        Size = uiSize,
        Position = UDim2.new(0.5, -uiSize.X.Offset / 2, 0.5, -uiSize.Y.Offset / 2),
        Active = true,
        Draggable = true,
        ZIndex = 1
    })

    Linux.Instance("UICorner", {
        Parent = Main,
        CornerRadius = UDim.new(0, 5)
    })

    Linux:ApplyShadow(Main, Linux.Theme.Shadow, 5, 0.5)
    Linux:ApplyGradient(Main, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Linux.Theme.Background),
        ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.Background, 0.7))
    }), 45)

    local TopBar = Linux.Instance("Frame", {
        Parent = Main,
        BackgroundColor3 = Linux.Theme.Element,
        Size = UDim2.new(1, 0, 0, 25),
        ZIndex = 2
    })

    Linux.Instance("UICorner", {
        Parent = TopBar,
        CornerRadius = UDim.new(0, 5)
    })

    Linux:ApplyGradient(TopBar, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Linux.Theme.Element),
        ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.Element, 0.9))
    }), 90)
    Linux:ApplyBorder(TopBar, Linux.Theme.Border, 1, 0.2)

    local Title = Linux.Instance("TextLabel", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.8, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        Font = Enum.Font.SourceSansBold,
        Text = config.Name or "Linux UI",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2
    })

    local MinimizeButton = Linux.Instance("TextButton", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -45, 0, 2),
        Text = "",
        ZIndex = 3,
        AutoButtonColor = false
    })

    local MinimizeIcon = Linux.Instance("ImageLabel", {
        Parent = MinimizeButton,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0.5, -8, 0.5, -8),
        Image = "rbxassetid://10734895698",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ZIndex = 3
    })

    Linux:ApplyHoverEffect(MinimizeButton, Linux.Theme.Accent, Linux.Theme.Element, 2)

    local CloseButton = Linux.Instance("TextButton", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -20, 0, 2),
        Text = "",
        ZIndex = 3,
        AutoButtonColor = false
    })

    local CloseIcon = Linux.Instance("ImageLabel", {
        Parent = CloseButton,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0.5, -8, 0.5, -8),
        Image = "rbxassetid://10747384394",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ZIndex = 3
    })

    Linux:ApplyHoverEffect(CloseButton, Linux.Theme.Accent, Linux.Theme.Element, 2)

    local TabsBar = Linux.Instance("Frame", {
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 25),
        Size = UDim2.new(0, tabWidth, 1, -25),
        ZIndex = 2
    })

    local TabHolder = Linux.Instance("ScrollingFrame", {
        Parent = TabsBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        ZIndex = 2
    })

    local TabLayout = Linux.Instance("UIListLayout", {
        Parent = TabHolder,
        Padding = UDim.new(0, 3),
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local TabPadding = Linux.Instance("UIPadding", {
        Parent = TabHolder,
        PaddingLeft = UDim.new(0, 5),
        PaddingTop = UDim.new(0, 5)
    })

    local Content = Linux.Instance("Frame", {
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, tabWidth, 0, 25),
        Size = UDim2.new(1, -tabWidth, 1, -25),
        ZIndex = 1
    })

    local isMinimized = false
    local originalSize = Main.Size
    local originalPos = Main.Position
    local isHidden = false

    MinimizeButton.MouseButton1Click:Connect(function()
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if not isMinimized then
            TweenService:Create(Main, tweenInfo, {Size = UDim2.new(0, 200, 0, 25), Position = UDim2.new(0.5, -100, 0, 0)}):Play()
            TabsBar.Visible = false
            Content.Visible = false
            MinimizeIcon.Image = "rbxassetid://10734886735"
            isMinimized = true
        else
            TweenService:Create(Main, tweenInfo, {Size = originalSize, Position = originalPos}):Play()
            TabsBar.Visible = true
            Content.Visible = true
            MinimizeIcon.Image = "rbxassetid://10734895698"
            isMinimized = false
        end
    end)

    CloseButton.MouseButton1Click:Connect(function()
        LinuxUI:Destroy()
        FakeUI:Destroy()
    end)

    InputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftAlt then
            isHidden = not isHidden
            Main.Visible = not isHidden
        end
    end)

    local LinuxLib = {}
    local Tabs = {}
    local CurrentTab = nil
    local tabOrder = 0

    function LinuxLib.Tab(config)
        tabOrder = tabOrder + 1
        local tabIndex = tabOrder

        local TabBtn = Linux.Instance("TextButton", {
            Parent = TabHolder,
            BackgroundColor3 = Linux.Theme.TabInactive,
            Size = UDim2.new(1, -5, 0, 28),
            Font = Enum.Font.SourceSans,
            Text = "",
            TextColor3 = Linux.Theme.Text,
            TextSize = 14,
            ZIndex = 2,
            AutoButtonColor = false,
            LayoutOrder = tabIndex
        })

        Linux.Instance("UICorner", {
            Parent = TabBtn,
            CornerRadius = UDim.new(0, 4)
        })

        Linux:ApplyShadow(TabBtn, Linux.Theme.Shadow, 3, 0.6)
        Linux:ApplyGradient(TabBtn, ColorSequence.new({
            ColorSequenceKeypoint.new(0, Linux.Theme.TabInactive),
            ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.TabInactive, 0.9))
        }), 90)
        Linux:ApplyBorder(TabBtn, Linux.Theme.Border, 1, 0.3)
        Linux:ApplyHoverEffect(TabBtn, Linux.Theme.Accent, Linux.Theme.TabInactive, 2)

        local TabIcon
        if config.Icon and config.Icon.Enabled then
            TabIcon = Linux.Instance("ImageLabel", {
                Parent = TabBtn,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 5, 0.5, -8),
                Image = config.Icon.Image or "rbxassetid://10747384394",
                ImageColor3 = Color3.fromRGB(150, 150, 150),
                ZIndex = 2
            })
        end

        local TabText = Linux.Instance("TextLabel", {
            Parent = TabBtn,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, config.Icon and config.Icon.Enabled and -26 or -10, 1, 0),
            Position = UDim2.new(0, config.Icon and config.Icon.Enabled and 26 or 5, 0, 0),
            Font = Enum.Font.SourceSans,
            Text = config.Name,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2
        })

        local TabContent = Linux.Instance("ScrollingFrame", {
            Parent = Content,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 0,
            Visible = false,
            ZIndex = 1
        })

        local TabTitle = Linux.Instance("TextLabel", {
            Parent = TabContent,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 0, 30),
            Position = UDim2.new(0, 5, 0, 0),
            Font = Enum.Font.SourceSansBold,
            Text = config.Name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2
        })

        local ElementContainer = Linux.Instance("Frame", {
            Parent = TabContent,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, -30),
            Position = UDim2.new(0, 0, 0, 30),
            ZIndex = 1
        })

        local ContentLayout = Linux.Instance("UIListLayout", {
            Parent = ElementContainer,
            Padding = UDim.new(0, 4),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        local ContentPadding = Linux.Instance("UIPadding", {
            Parent = ElementContainer,
            PaddingLeft = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 5)
        })

        TabBtn.MouseButton1Click:Connect(function()
            for _, tab in pairs(Tabs) do
                tab.Content.Visible = false
                tab.Text.TextColor3 = Color3.fromRGB(150, 150, 150)
                if tab.Icon then
                    tab.Icon.ImageColor3 = Color3.fromRGB(150, 150, 150)
                end
                TweenService:Create(tab.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundColor3 = Linux.Theme.TabInactive}):Play()
            end
            TabContent.Visible = true
            TabText.TextColor3 = Color3.fromRGB(255, 255, 255)
            if TabIcon then
                TabIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
            TweenService:Create(TabBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundColor3 = Linux.Theme.Accent}):Play()
            CurrentTab = tabIndex
        end)

        Tabs[tabIndex] = {
            Name = config.Name,
            Button = TabBtn,
            Text = TabText,
            Icon = TabIcon,
            Content = TabContent
        }

        if not CurrentTab then
            TabContent.Visible = true
            TabText.TextColor3 = Color3.fromRGB(255, 255, 255)
            if TabIcon then
                TabIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
            TweenService:Create(TabBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundColor3 = Linux.Theme.Accent}):Play()
            CurrentTab = tabIndex
        end

        local TabElements = {}
        local elementOrder = 0

        function TabElements.Button(config)
            elementOrder = elementOrder + 1
            local BtnFrame = Linux.Instance("Frame", {
                Parent = ElementContainer,
                BackgroundColor3 = Linux.Theme.Element,
                Size = UDim2.new(1, -5, 0, 30),
                ZIndex = 1,
                LayoutOrder = elementOrder
            })

            Linux.Instance("UICorner", {
                Parent = BtnFrame,
                CornerRadius = UDim.new(0, 4)
            })

            Linux:ApplyShadow(BtnFrame, Linux.Theme.Shadow, 3, 0.6)
            Linux:ApplyGradient(BtnFrame, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Linux.Theme.Element),
                ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.Element, 0.9))
            }), 90)
            Linux:ApplyBorder(BtnFrame, Linux.Theme.Border, 1, 0.3)
            Linux:ApplyHoverEffect(BtnFrame, Linux.Theme.Accent, Linux.Theme.Element, 2)

            local Btn = Linux.Instance("TextButton", {
                Parent = BtnFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 0, 0),
                Font = Enum.Font.SourceSans,
                Text = config.Name,
                TextColor3 = Linux.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 1,
                AutoButtonColor = false
            })

            local BtnPadding = Linux.Instance("UIPadding", {
                Parent = Btn,
                PaddingLeft = UDim.new(0, 5)
            })

            local BtnIcon = Linux.Instance("ImageLabel", {
                Parent = BtnFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, -20, 0.5, -7),
                Image = "rbxassetid://10709791437",
                ImageColor3 = Linux.Theme.Text,
                ZIndex = 1
            })

            Btn.MouseButton1Click:Connect(function()
                Linux:ApplyRippleEffect(BtnFrame)
                TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Linux.Theme.Accent}):Play()
                spawn(function() Linux:SafeCallback(config.Callback) end)
                wait(0.1)
                TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Linux.Theme.Element}):Play()
            end)

            return Btn
        end

        function TabElements.Toggle(config)
            elementOrder = elementOrder + 1
            local Toggle = Linux.Instance("Frame", {
                Parent = ElementContainer,
                BackgroundColor3 = Linux.Theme.Element,
                Size = UDim2.new(1, -5, 0, 30),
                ZIndex = 1,
                LayoutOrder = elementOrder
            })

            Linux.Instance("UICorner", {
                Parent = Toggle,
                CornerRadius = UDim.new(0, 4)
            })

            Linux:ApplyShadow(Toggle, Linux.Theme.Shadow, 3, 0.6)
            Linux:ApplyGradient(Toggle, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Linux.Theme.Element),
                ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.Element, 0.9))
            }), 90)
            Linux:ApplyBorder(Toggle, Linux.Theme.Border, 1, 0.3)
            Linux:ApplyHoverEffect(Toggle, Linux.Theme.Accent, Linux.Theme.Element, 2)

            local Label = Linux.Instance("TextLabel", {
                Parent = Toggle,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.8, 0, 0, 30),
                Position = UDim2.new(0, 5, 0, 0),
                Font = Enum.Font.SourceSans,
                Text = config.Name,
                TextColor3 = Linux.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 1
            })

            local ToggleBox = Linux.Instance("Frame", {
                Parent = Toggle,
                BackgroundColor3 = Linux.Theme.Toggle,
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -45, 0, 5),
                ZIndex = 1
            })

            Linux.Instance("UICorner", {
                Parent = ToggleBox,
                CornerRadius = UDim.new(1, 0)
            })

            Linux:ApplyBorder(ToggleBox, Linux.Theme.Border, 1, 0.3)

            local ToggleFill = Linux.Instance("Frame", {
                Parent = ToggleBox,
                BackgroundColor3 = Linux.Theme.Toggle,
                Size = UDim2.new(0, 0, 1, 0),
                ZIndex = 1
            })

            Linux.Instance("UICorner", {
                Parent = ToggleFill,
                CornerRadius = UDim.new(1, 0)
            })

            Linux:ApplyGradient(ToggleFill, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Linux.Theme.Toggle),
                ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.Toggle, 0.9))
            }), 90)

            local Knob = Linux.Instance("Frame", {
                Parent = ToggleBox,
                BackgroundColor3 = Color3.fromRGB(150, 150, 150),
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 2, 0, 2),
                ZIndex = 2
            })

            Linux.Instance("UICorner", {
                Parent = Knob,
                CornerRadius = UDim.new(1, 0)
            })

            Linux:ApplyShadow(Knob, Linux.Theme.Shadow, 2, 0.7)

            local State = config.Default or false

            local function UpdateToggle()
                local tween = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
                if State then
                    TweenService:Create(ToggleFill, tween, {BackgroundColor3 = Linux.Theme.Accent, Size = UDim2.new(1, 0, 1, 0)}):Play()
                    TweenService:Create(Knob, tween, {Position = UDim2.new(1, -18, 0, 2), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                else
                    TweenService:Create(ToggleFill, tween, {BackgroundColor3 = Linux.Theme.Toggle, Size = UDim2.new(0, 0, 1, 0)}):Play()
                    TweenService:Create(Knob, tween, {Position = UDim2.new(0, 2, 0, 2), BackgroundColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                end
            end

            UpdateToggle()

            Toggle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Linux:ApplyRippleEffect(Toggle)
                    State = not State
                    UpdateToggle()
                    spawn(function() Linux:SafeCallback(config.Callback, State) end)
                end
            end)

            return Toggle
        end

        function TabElements.Dropdown(config)
            elementOrder = elementOrder + 1
            local Dropdown = Linux.Instance("Frame", {
                Parent = ElementContainer,
                BackgroundColor3 = Linux.Theme.Element,
                Size = UDim2.new(1, -5, 0, 30),
                ZIndex = 2,
                LayoutOrder = elementOrder
            })

            Linux.Instance("UICorner", {
                Parent = Dropdown,
                CornerRadius = UDim.new(0, 4)
            })

            Linux:ApplyShadow(Dropdown, Linux.Theme.Shadow, 3, 0.6)
            Linux:ApplyGradient(Dropdown, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Linux.Theme.Element),
                ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.Element, 0.9))
            }), 90)
            Linux:ApplyBorder(Dropdown, Linux.Theme.Border, 1, 0.3)
            Linux:ApplyHoverEffect(Dropdown, Linux.Theme.Accent, Linux.Theme.Element, 2)

            local Label = Linux.Instance("TextLabel", {
                Parent = Dropdown,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.8, 0, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Font = Enum.Font.SourceSans,
                Text = config.Name,
                TextColor3 = Linux.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })

            local Selected = Linux.Instance("TextLabel", {
                Parent = Dropdown,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -40, 1, 0),
                Font = Enum.Font.SourceSans,
                Text = config.Default or (config.Options and config.Options[1]) or "None",
                TextColor3 = Linux.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 2
            })

            local Arrow = Linux.Instance("ImageLabel", {
                Parent = Dropdown,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, -20, 0.5, -7),
                Image = "rbxassetid://10709767827",
                ImageColor3 = Linux.Theme.Text,
                ZIndex = 2
            })

            local DropFrame = Linux.Instance("ScrollingFrame", {
                Parent = ElementContainer,
                BackgroundColor3 = Linux.Theme.Element,
                Size = UDim2.new(1, -5, 0, 0),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 0,
                ClipsDescendants = true,
                ZIndex = 3,
                LayoutOrder = elementOrder + 1
            })

            Linux.Instance("UICorner", {
                Parent = DropFrame,
                CornerRadius = UDim.new(0, 4)
            })

            Linux:ApplyShadow(DropFrame, Linux.Theme.Shadow, 3, 0.6)
            Linux:ApplyGradient(DropFrame, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Linux.Theme.Element),
                ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.Element, 0.9))
            }), 90)
            Linux:ApplyBorder(DropFrame, Linux.Theme.Border, 1, 0.3)

            local DropLayout = Linux.Instance("UIListLayout", {
                Parent = DropFrame,
                Padding = UDim.new(0, 2),
                HorizontalAlignment = Enum.HorizontalAlignment.Left
            })

            local DropPadding = Linux.Instance("UIPadding", {
                Parent = DropFrame,
                PaddingLeft = UDim.new(0, 5),
                PaddingTop = UDim.new(0, 5)
            })

            local Options = config.Options or {}
            local IsOpen = false
            local SelectedValue = config.Default or (Options[1] or "None")

            local function UpdateDropSize()
                local optionHeight = 25
                local paddingBetween = 2
                local paddingTop = 5
                local maxHeight = 150
                local numOptions = #Options
                local calculatedHeight = numOptions * optionHeight + (numOptions - 1) * paddingBetween + paddingTop
                local finalHeight = math.min(calculatedHeight, maxHeight)
                if finalHeight < 0 then finalHeight = 0 end

                local tween = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
                if IsOpen then
                    TweenService:Create(DropFrame, tween, {Size = UDim2.new(1, -5, 0, finalHeight)}):Play()
                    TweenService:Create(Arrow, tween, {Rotation = 180}):Play()
                else
                    TweenService:Create(DropFrame, tween, {Size = UDim2.new(1, -5, 0, 0)}):Play()
                    TweenService:Create(Arrow, tween, {Rotation = 0}):Play()
                end
                task.wait(0.2)
                TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
            end

            local function PopulateOptions()
                for _, child in pairs(DropFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                if IsOpen then
                    for _, opt in pairs(Options) do
                        local OptBtn = Linux.Instance("TextButton", {
                            Parent = DropFrame,
                            BackgroundColor3 = Linux.Theme.DropdownOption,
                            Size = UDim2.new(1, -5, 0, 25),
                            Font = Enum.Font.SourceSans,
                            Text = tostring(opt),
                            TextColor3 = opt == SelectedValue and Linux.Theme.Accent or Linux.Theme.Text,
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 3,
                            AutoButtonColor = false
                        })

                        Linux.Instance("UICorner", {
                            Parent = OptBtn,
                            CornerRadius = UDim.new(0, 4)
                        })

                        Linux:ApplyShadow(OptBtn, Linux.Theme.Shadow, 2, 0.7)
                        Linux:ApplyGradient(OptBtn, ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Linux.Theme.DropdownOption),
                            ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.DropdownOption, 0.9))
                        }), 90)
                        Linux:ApplyBorder(OptBtn, Linux.Theme.Border, 1, 0.3)
                        Linux:ApplyHoverEffect(OptBtn, Linux.Theme.Accent, Linux.Theme.DropdownOption, 2)

                        OptBtn.MouseButton1Click:Connect(function()
                            Linux:ApplyRippleEffect(OptBtn)
                            SelectedValue = opt
                            Selected.Text = tostring(opt)
                            for _, btn in pairs(DropFrame:GetChildren()) do
                                if btn:IsA("TextButton") then
                                    btn.TextColor3 = btn.Text == tostring(opt) and Linux.Theme.Accent or Linux.Theme.Text
                                end
                            end
                            spawn(function() Linux:SafeCallback(config.Callback, opt) end)
                        end)
                    end
                end
                UpdateDropSize()
            end

            if #Options > 0 then
                PopulateOptions()
            end

            Dropdown.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Linux:ApplyRippleEffect(Dropdown)
                    IsOpen = not IsOpen
                    PopulateOptions()
                end
            end)

            local function SetOptions(newOptions)
                Options = newOptions or {}
                SelectedValue = config.Default or (Options[1] or "None")
                Selected.Text = tostring(SelectedValue)
                PopulateOptions()
            end

            local function SetValue(value)
                if table.find(Options, value) then
                    SelectedValue = value
                    Selected.Text = tostring(value)
                    for _, btn in pairs(DropFrame:GetChildren()) do
                        if btn:IsA("TextButton") then
                            btn.TextColor3 = btn.Text == tostring(value) and Linux.Theme.Accent or Linux.Theme.Text
                        end
                    end
                    spawn(function() Linux:SafeCallback(config.Callback, value) end)
                end
            end

            return {
                Instance = Dropdown,
                SetOptions = SetOptions,
                SetValue = SetValue,
                GetValue = function() return SelectedValue end
            }
        end

        function TabElements.MultiDropdown(config)
            elementOrder = elementOrder + 1
            local MultiDropdown = Linux.Instance("Frame", {
                Parent = ElementContainer,
                BackgroundColor3 = Linux.Theme.Element,
                Size = UDim2.new(1, -5, 0, 30),
                ZIndex = 2,
                LayoutOrder = elementOrder
            })

            Linux.Instance("UICorner", {
                Parent = MultiDropdown,
                CornerRadius = UDim.new(0, 4)
            })

            Linux:ApplyShadow(MultiDropdown, Linux.Theme.Shadow, 3, 0.6)
            Linux:ApplyGradient(MultiDropdown, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Linux.Theme.Element),
                ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.Element, 0.9))
            }), 90)
            Linux:ApplyBorder(MultiDropdown, Linux.Theme.Border, 1, 0.3)
            Linux:ApplyHoverEffect(MultiDropdown, Linux.Theme.Accent, Linux.Theme.Element, 2)

            local Label = Linux.Instance("TextLabel", {
                Parent = MultiDropdown,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.8, 0, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Font = Enum.Font.SourceSans,
                Text = config.Name,
                TextColor3 = Linux.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })

            local Selected = Linux.Instance("TextLabel", {
                Parent = MultiDropdown,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -40, 1, 0),
                Font = Enum.Font.SourceSans,
                Text = config.Default and table.concat(config.Default, ", ") or "None",
                TextColor3 = Linux.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 2
            })

            local Arrow = Linux.Instance("ImageLabel", {
                Parent = MultiDropdown,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, -20, 0.5, -7),
                Image = "rbxassetid://10709767827",
                ImageColor3 = Linux.Theme.Text,
                ZIndex = 2
            })

            local DropFrame = Linux.Instance("ScrollingFrame", {
                Parent = ElementContainer,
                BackgroundColor3 = Linux.Theme.Element,
                Size = UDim2.new(1, -5, 0, 0),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 0,
                ClipsDescendants = true,
                ZIndex = 3,
                LayoutOrder = elementOrder + 1
            })

            Linux.Instance("UICorner", {
                Parent = DropFrame,
                CornerRadius = UDim.new(0, 4)
            })

            Linux:ApplyShadow(DropFrame, Linux.Theme.Shadow, 3, 0.6)
            Linux:ApplyGradient(DropFrame, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Linux.Theme.Element),
                ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.Element, 0.9))
            }), 90)
            Linux:ApplyBorder(DropFrame, Linux.Theme.Border, 1, 0.3)

            local DropLayout = Linux.Instance("UIListLayout", {
                Parent = DropFrame,
                Padding = UDim.new(0, 2),
                HorizontalAlignment = Enum.HorizontalAlignment.Left
            })

            local DropPadding = Linux.Instance("UIPadding", {
                Parent = DropFrame,
                PaddingLeft = UDim.new(0, 5),
                PaddingTop = UDim.new(0, 5)
            })

            local Options = config.Options or {}
            local IsOpen = false
            local SelectedValues = config.Default or {}

            local function UpdateDropSize()
                local optionHeight = 25
                local paddingBetween = 2
                local paddingTop = 5
                local maxHeight = 150
                local numOptions = #Options
                local calculatedHeight = numOptions * optionHeight + (numOptions - 1) * paddingBetween + paddingTop
                local finalHeight = math.min(calculatedHeight, maxHeight)
                if finalHeight < 0 then finalHeight = 0 end

                local tween = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
                if IsOpen then
                    TweenService:Create(DropFrame, tween, {Size = UDim2.new(1, -5, 0, finalHeight)}):Play()
                    TweenService:Create(Arrow, tween, {Rotation = 180}):Play()
                else
                    TweenService:Create(DropFrame, tween, {Size = UDim2.new(1, -5, 0, 0)}):Play()
                    TweenService:Create(Arrow, tween, {Rotation = 0}):Play()
                end
                task.wait(0.2)
                TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
            end

            local function UpdateSelectedText()
                if #SelectedValues > 0 then
                    Selected.Text = table.concat(SelectedValues, ", ")
                else
                    Selected.Text = "None"
                end
            end

            local function PopulateOptions()
                for _, child in pairs(DropFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                if IsOpen then
                    for _, opt in pairs(Options) do
                        local OptBtn = Linux.Instance("TextButton", {
                            Parent = DropFrame,
                            BackgroundColor3 = Linux.Theme.DropdownOption,
                            Size = UDim2.new(1, -5, 0, 25),
                            Font = Enum.Font.SourceSans,
                            Text = tostring(opt),
                            TextColor3 = table.find(SelectedValues, opt) and Linux.Theme.Accent or Linux.Theme.Text,
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 3,
                            AutoButtonColor = false
                        })

                        Linux.Instance("UICorner", {
                            Parent = OptBtn,
                            CornerRadius = UDim.new(0, 4)
                        })

                        Linux:ApplyShadow(OptBtn, Linux.Theme.Shadow, 2, 0.7)
                        Linux:ApplyGradient(OptBtn, ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Linux.Theme.DropdownOption),
                            ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.DropdownOption, 0.9))
                        }), 90)
                        Linux:ApplyBorder(OptBtn, Linux.Theme.Border, 1, 0.3)
                        Linux:ApplyHoverEffect(OptBtn, Linux.Theme.Accent, Linux.Theme.DropdownOption, 2)

                        OptBtn.MouseButton1Click:Connect(function()
                            Linux:ApplyRippleEffect(OptBtn)
                            if table.find(SelectedValues, opt) then
                                for i, v in ipairs(SelectedValues) do
                                    if v == opt then
                                        table.remove(SelectedValues, i)
                                        break
                                    end
                                end
                            else
                                table.insert(SelectedValues, opt)
                            end
                            OptBtn.TextColor3 = table.find(SelectedValues, opt) and Linux.Theme.Accent or Linux.Theme.Text
                            UpdateSelectedText()
                            spawn(function() Linux:SafeCallback(config.Callback, SelectedValues) end)
                        end)
                    end
                end
                UpdateDropSize()
            end

            if #Options > 0 then
                PopulateOptions()
            end

            MultiDropdown.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Linux:ApplyRippleEffect(MultiDropdown)
                    IsOpen = not IsOpen
                    PopulateOptions()
                end
            end)

            local function SetOptions(newOptions)
                Options = newOptions or {}
                SelectedValues = {}
                UpdateSelectedText()
                PopulateOptions()
            end

            local function SetValues(values)
                SelectedValues = values or {}
                UpdateSelectedText()
                PopulateOptions()
                spawn(function() Linux:SafeCallback(config.Callback, SelectedValues) end)
            end

            return {
                Instance = MultiDropdown,
                SetOptions = SetOptions,
                SetValues = SetValues,
                GetValues = function() return SelectedValues end
            }
        end

        function TabElements.Slider(config)
            elementOrder = elementOrder + 1
            local Slider = Linux.Instance("Frame", {
                Parent = ElementContainer,
                BackgroundColor3 = Linux.Theme.Element,
                Size = UDim2.new(1, -5, 0, 40),
                ZIndex = 1,
                LayoutOrder = elementOrder
            })

            Linux.Instance("UICorner", {
                Parent = Slider,
                CornerRadius = UDim.new(0, 4)
            })

            Linux:ApplyShadow(Slider, Linux.Theme.Shadow, 3, 0.6)
            Linux:ApplyGradient(Slider, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Linux.Theme.Element),
                ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.Element, 0.9))
            }), 90)
            Linux:ApplyBorder(Slider, Linux.Theme.Border, 1, 0.3)
            Linux:ApplyHoverEffect(Slider, Linux.Theme.Accent, Linux.Theme.Element, 2)

            local Label = Linux.Instance("TextLabel", {
                Parent = Slider,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.6, 0, 0, 20),
                Position = UDim2.new(0, 5, 0, 2),
                Font = Enum.Font.SourceSans,
                Text = config.Name,
                TextColor3 = Linux.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 1
            })

            local ValueLabel = Linux.Instance("TextLabel", {
                Parent = Slider,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.4, -5, 0, 20),
                Position = UDim2.new(0.6, 0, 0, 2),
                Font = Enum.Font.SourceSans,
                Text = tostring(config.Default or config.Min or 0),
                TextColor3 = Linux.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 1
            })

            local SliderBar = Linux.Instance("Frame", {
                Parent = Slider,
                BackgroundColor3 = Linux.Theme.Toggle,
                Size = UDim2.new(1, -10, 0, 6),
                Position = UDim2.new(0, 5, 0, 28),
                ZIndex = 1
            })

            Linux.Instance("UICorner", {
                Parent = SliderBar,
                CornerRadius = UDim.new(1, 0)
            })

            Linux:ApplyBorder(SliderBar, Linux.Theme.Border, 1, 0.3)

            local FillBar = Linux.Instance("Frame", {
                Parent = SliderBar,
                BackgroundColor3 = Linux.Theme.Accent,
                Size = UDim2.new(0, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                ZIndex = 1
            })

            Linux.Instance("UICorner", {
                Parent = FillBar,
                CornerRadius = UDim.new(1, 0)
            })

            Linux:ApplyGradient(FillBar, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Linux.Theme.Accent),
                ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.Accent, 0.9))
            }), 90)

            local Knob = Linux.Instance("Frame", {
                Parent = SliderBar,
                BackgroundColor3 = Color3.fromRGB(255, 255, 250),
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(0, 0, 0, -3),
                ZIndex = 2
            })

            Linux.Instance("UICorner", {
                Parent = Knob,
                CornerRadius = UDim.new(1, 0)
            })

            Linux:ApplyShadow(Knob, Linux.Theme.Shadow, 2, 0.7)

            local Min = config.Min or 0
            local Max = config.Max or 100
            local Default = config.Default or Min
            local Value = Default

            local function UpdateSlider(pos)
                local barSize = SliderBar.AbsoluteSize.X
                local relativePos = math.clamp((pos - SliderBar.AbsolutePosition.X) / barSize, 0, 1)
                Value = Min + (Max - Min) * relativePos
                Value = math.floor(Value + 0.5)
                Knob.Position = UDim2.new(relativePos, -6, 0, -3)
                FillBar.Size = UDim2.new(relativePos, 0, 1, 0)
                ValueLabel.Text = tostring(Value)
                spawn(function() Linux:SafeCallback(config.Callback, Value) end)
            end

            local draggingSlider = false

            Slider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = true
                    UpdateSlider(input.Position.X)
                end
            end)

            Slider.InputChanged:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) and draggingSlider then
                    UpdateSlider(input.Position.X)
                end
            end)

            Slider.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = false
                end
            end)

            local function SetValue(newValue)
                newValue = math.clamp(newValue, Min, Max)
                Value = math.floor(newValue + 0.5)
                local relativePos = (Value - Min) / (Max - Min)
                Knob.Position = UDim2.new(relativePos, -6, 0, -3)
                FillBar.Size = UDim2.new(relativePos, 0, 1, 0)
                ValueLabel.Text = tostring(Value)
                spawn(function() Linux:SafeCallback(config.Callback, Value) end)
            end

            SetValue(Default)

            return {
                Instance = Slider,
                SetValue = SetValue,
                GetValue = function() return Value end
            }
        end

        function TabElements.Input(config)
            elementOrder = elementOrder + 1
            local Input = Linux.Instance("Frame", {
                Parent = ElementContainer,
                BackgroundColor3 = Linux.Theme.Element,
                Size = UDim2.new(1, -5, 0, 30),
                ZIndex = 1,
                LayoutOrder = elementOrder
            })

            Linux.Instance("UICorner", {
                Parent = Input,
                CornerRadius = UDim.new(0, 4)
            })

            Linux:ApplyShadow(Input, Linux.Theme.Shadow, 3, 0.6)
            Linux:ApplyGradient(Input, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Linux.Theme.Element),
                ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.Element, 0.9))
            }), 90)
            Linux:ApplyBorder(Input, Linux.Theme.Border, 1, 0.3)
            Linux:ApplyHoverEffect(Input, Linux.Theme.Accent, Linux.Theme.Element, 2)

            local Label = Linux.Instance("TextLabel", {
                Parent = Input,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Font = Enum.Font.SourceSans,
                Text = config.Name,
                TextColor3 = Linux.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 1
            })

            local TextBox = Linux.Instance("TextBox", {
                Parent = Input,
                BackgroundColor3 = Linux.Theme.Toggle,
                Size = UDim2.new(0.5, -10, 0, 20),
                Position = UDim2.new(0.5, 5, 0.5, -10),
                Font = Enum.Font.SourceSans,
                Text = config.Default or "",
                PlaceholderText = config.Placeholder or "Text Here",
                PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
                TextColor3 = Linux.Theme.Text,
                TextSize = 14,
                TextScaled = false,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                ClipsDescendants = true,
                ZIndex = 2
            })

            Linux.Instance("UICorner", {
                Parent = TextBox,
                CornerRadius = UDim.new(0, 4)
            })

            Linux:ApplyShadow(TextBox, Linux.Theme.Shadow, 2, 0.7)
            Linux:ApplyGradient(TextBox, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Linux.Theme.Toggle),
                ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.Toggle, 0.9))
            }), 90)
            Linux:ApplyBorder(TextBox, Linux.Theme.Border, 1, 0.3)

            local MaxLength = 50

            local function CheckTextBounds()
                if #TextBox.Text > MaxLength then
                    TextBox.Text = string.sub(TextBox.Text, 1, MaxLength)
                end
            end

            TextBox:GetPropertyChangedSignal("Text"):Connect(function()
                CheckTextBounds()
            end)

            local function UpdateInput()
                CheckTextBounds()
                spawn(function() Linux:SafeCallback(config.Callback, TextBox.Text) end)
            end

            TextBox.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    UpdateInput()
                end
            end)

            TextBox.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    TextBox:CaptureFocus()
                end
            end)

            local function SetValue(newValue)
                local text = tostring(newValue)
                if #text > MaxLength then
                    text = string.sub(text, 1, MaxLength)
                end
                TextBox.Text = text
                UpdateInput()
            end

            return {
                Instance = Input,
                SetValue = SetValue,
                GetValue = function() return TextBox.Text end
            }
        end

        function TabElements.Label(config)
            elementOrder = elementOrder + 1
            local LabelFrame = Linux.Instance("Frame", {
                Parent = ElementContainer,
                BackgroundColor3 = Linux.Theme.Element,
                Size = UDim2.new(1, -5, 0, 30),
                ZIndex = 1,
                LayoutOrder = elementOrder
            })

            Linux.Instance("UICorner", {
                Parent = LabelFrame,
                CornerRadius = UDim.new(0, 4)
            })

            Linux:ApplyShadow(LabelFrame, Linux.Theme.Shadow, 3, 0.6)
            Linux:ApplyGradient(LabelFrame, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Linux.Theme.Element),
                ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.Element, 0.9))
            }), 90)
            Linux:ApplyBorder(LabelFrame, Linux.Theme.Border, 1, 0.3)

            local LabelText = Linux.Instance("TextLabel", {
                Parent = LabelFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Font = Enum.Font.SourceSans,
                Text = config.Text or "Label",
                TextColor3 = Linux.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 1
            })

            local function SetText(newText)
                LabelText.Text = tostring(newText)
            end

            return {
                Instance = LabelFrame,
                SetText = SetText,
                GetText = function() return LabelText.Text end
            }
        end

        function TabElements.Section(config)
            elementOrder = elementOrder + 1
            local Section = Linux.Instance("Frame", {
                Parent = ElementContainer,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -5, 0, 24),
                ZIndex = 1,
                LayoutOrder = elementOrder
            })

            local SectionText = Linux.Instance("TextLabel", {
                Parent = Section,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Font = Enum.Font.SourceSansBold,
                Text = config.Name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 18,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 1
            })

            return Section
        end

        function TabElements.Keybind(config)
            elementOrder = elementOrder + 1
            local Keybind = Linux.Instance("Frame", {
                Parent = ElementContainer,
                BackgroundColor3 = Linux.Theme.Element,
                Size = UDim2.new(1, -5, 0, 30),
                ZIndex = 1,
                LayoutOrder = elementOrder
            })

            Linux.Instance("UICorner", {
                Parent = Keybind,
                CornerRadius = UDim.new(0, 4)
            })

            Linux:ApplyShadow(Keybind, Linux.Theme.Shadow, 3, 0.6)
            Linux:ApplyGradient(Keybind, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Linux.Theme.Element),
                ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.Element, 0.9))
            }), 90)
            Linux:ApplyBorder(Keybind, Linux.Theme.Border, 1, 0.3)
            Linux:ApplyHoverEffect(Keybind, Linux.Theme.Accent, Linux.Theme.Element, 2)

            local Label = Linux.Instance("TextLabel", {
                Parent = Keybind,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Font = Enum.Font.SourceSans,
                Text = config.Name,
                TextColor3 = Linux.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 1
            })

            local KeyBox = Linux.Instance("TextButton", {
                Parent = Keybind,
                BackgroundColor3 = Linux.Theme.Toggle,
                Size = UDim2.new(0, 60, 0, 20),
                Position = UDim2.new(1, -65, 0.5, -10),
                Font = Enum.Font.SourceSans,
                Text = config.Default and tostring(config.Default) or "None",
                TextColor3 = Linux.Theme.Text,
                TextSize = 14,
                TextScaled = true,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Center,
                ClipsDescendants = true,
                ZIndex = 2,
                AutoButtonColor = false
            })

            Linux.Instance("UICorner", {
                Parent = KeyBox,
                CornerRadius = UDim.new(0, 4)
            })

            Linux:ApplyShadow(KeyBox, Linux.Theme.Shadow, 2, 0.7)
            Linux:ApplyGradient(KeyBox, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Linux.Theme.Toggle),
                ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.Toggle, 0.9))
            }), 90)
            Linux:ApplyBorder(KeyBox, Linux.Theme.Border, 1, 0.3)

            local Mode = config.Mode or "Hold"
            local CurrentKey = config.Default or nil
            local IsBinding = false
            local ToggleState = false
            local IsHolding = false

            local function UpdateKeyText()
                KeyBox.Text = CurrentKey and tostring(CurrentKey) or "None"
            end

            local function ExecuteCallback(state)
                if Mode == "Hold" then
                    spawn(function() Linux:SafeCallback(config.Callback, state) end)
                elseif Mode == "Toggle" then
                    if state then
                        ToggleState = not ToggleState
                        spawn(function() Linux:SafeCallback(config.Callback, ToggleState) end)
                    end
                elseif Mode == "Always" then
                    if ToggleState then
                        spawn(function() Linux:SafeCallback(config.Callback, true) end)
                    end
                end
            end

            KeyBox.MouseButton1Click:Connect(function()
                Linux:ApplyRippleEffect(KeyBox)
                if not IsBinding then
                    IsBinding = true
                    KeyBox.Text = "..."
                end
            end)

            KeyBox.MouseButton2Click:Connect(function()
                Linux:ApplyRippleEffect(KeyBox)
                CurrentKey = nil
                IsBinding = false
                UpdateKeyText()
            end)

            InputService.InputBegan:Connect(function(input, gameProcessedEvent)
                if gameProcessedEvent then return end

                if IsBinding then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        CurrentKey = input.KeyCode
                        IsBinding = false
                        UpdateKeyText()
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                        CurrentKey = Enum.UserInputType.MouseButton1
                        IsBinding = false
                        UpdateKeyText()
                    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                        CurrentKey = Enum.UserInputType.MouseButton2
                        IsBinding = false
                        UpdateKeyText()
                    elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                        CurrentKey = Enum.UserInputType.MouseButton3
                        IsBinding = false
                        UpdateKeyText()
                    end
                elseif CurrentKey then
                    if (CurrentKey == input.KeyCode or CurrentKey == input.UserInputType) then
                        IsHolding = true
                        ExecuteCallback(true)
                    end
                end
            end)

            InputService.InputEnded:Connect(function(input, gameProcessedEvent)
                if gameProcessedEvent then return end

                if CurrentKey and (CurrentKey == input.KeyCode or CurrentKey == input.UserInputType) then
                    IsHolding = false
                    if Mode == "Hold" then
                        ExecuteCallback(false)
                    end
                end
            end)

            if Mode == "Always" then
                spawn(function()
                    while true do
                        if ToggleState then
                            ExecuteCallback(true)
                        end
                        wait()
                    end
                end)
            end

            local function SetKey(newKey)
                CurrentKey = newKey
                UpdateKeyText()
            end

            local function GetKey()
                return CurrentKey
            end

            local function SetMode(newMode)
                Mode = newMode
                ToggleState = false
                IsHolding = false
            end

            UpdateKeyText()

            return {
                Instance = Keybind,
                SetKey = SetKey,
                GetKey = GetKey,
                SetMode = SetMode
            }
        end

        function TabElements.ColorPicker(config)
            elementOrder = elementOrder + 1
            local ColorPicker = Linux.Instance("Frame", {
                Parent = ElementContainer,
                BackgroundColor3 = Linux.Theme.Element,
                Size = UDim2.new(1, -5, 0, 80),
                ZIndex = 1,
                LayoutOrder = elementOrder
            })

            Linux.Instance("UICorner", {
                Parent = ColorPicker,
                CornerRadius = UDim.new(0, 4)
            })

            Linux:ApplyShadow(ColorPicker, Linux.Theme.Shadow, 3, 0.6)
            Linux:ApplyGradient(ColorPicker, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Linux.Theme.Element),
                ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.Element, 0.9))
            }), 90)
            Linux:ApplyBorder(ColorPicker, Linux.Theme.Border, 1, 0.3)

            local Label = Linux.Instance("TextLabel", {
                Parent = ColorPicker,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 0, 20),
                Position = UDim2.new(0, 5, 0, 5),
                Font = Enum.Font.SourceSans,
                Text = config.Name,
                TextColor3 = Linux.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 1
            })

            local ColorPreview = Linux.Instance("Frame", {
                Parent = ColorPicker,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -25, 0, 5),
                ZIndex = 1
            })

            Linux.Instance("UICorner", {
                Parent = ColorPreview,
                CornerRadius = UDim.new(0, 4)
            })

            Linux:ApplyShadow(ColorPreview, Linux.Theme.Shadow, 2, 0.7)
            Linux:ApplyBorder(ColorPreview, Linux.Theme.Border, 1, 0.3)

            local Palette = Linux.Instance("ImageButton", {
                Parent = ColorPicker,
                BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                Size = UDim2.new(1, -10, 0, 60),
                Position = UDim2.new(0, 5, 0, 25),
                Image = "rbxassetid://698052001",
                ZIndex = 1,
                AutoButtonColor = false
            })

            Linux.Instance("UICorner", {
                Parent = Palette,
                CornerRadius = UDim.new(0, 4)
            })

            Linux:ApplyShadow(Palette, Linux.Theme.Shadow, 2, 0.7)
            Linux:ApplyBorder(Palette, Linux.Theme.Border, 1, 0.3)

            local PaletteKnob = Linux.Instance("Frame", {
                Parent = Palette,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0, 8, 0, 8),
                Position = UDim2.new(1, -4, 1, -4),
                ZIndex = 2
            })

            Linux.Instance("UICorner", {
                Parent = PaletteKnob,
                CornerRadius = UDim.new(1, 0)
            })

            Linux:ApplyShadow(PaletteKnob, Linux.Theme.Shadow, 2, 0.7)

            local Hue = 0
            local Saturation = 1
            local Value = 1

            local function UpdateColor()
                local color = Color3.fromHSV(Hue, Saturation, Value)
                Palette.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
                ColorPreview.BackgroundColor3 = color
                spawn(function() Linux:SafeCallback(config.Callback, color) end)
            end

            local draggingPalette = false
            Palette.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingPalette = true
                    local posX = input.Position.X
                    local posY = input.Position.Y
                    local paletteSize = Palette.AbsoluteSize
                    local relativeX = math.clamp((posX - Palette.AbsolutePosition.X) / paletteSize.X, 0, 1)
                    local relativeY = math.clamp((posY - Palette.AbsolutePosition.Y) / paletteSize.Y, 0, 1)
                    Saturation = relativeX
                    Value = 1 - relativeY
                    PaletteKnob.Position = UDim2.new(relativeX, -4, relativeY, -4)
                    UpdateColor()
                end
            end)

            Palette.InputChanged:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) and draggingPalette then
                    local posX = input.Position.X
                    local posY = input.Position.Y
                    local paletteSize = Palette.AbsoluteSize
                    local relativeX = math.clamp((posX - Palette.AbsolutePosition.X) / paletteSize.X, 0, 1)
                    local relativeY = math.clamp((posY - Palette.AbsolutePosition.Y) / paletteSize.Y, 0, 1)
                    Saturation = relativeX
                    Value = 1 - relativeY
                    PaletteKnob.Position = UDim2.new(relativeX, -4, relativeY, -4)
                    UpdateColor()
                end
            end)

            Palette.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingPalette = false
                end
            end)

            UpdateColor()

            local function SetColor(newColor)
                local h, s, v = newColor:ToHSV()
                Hue = h
                Saturation = s
                Value = v
                PaletteKnob.Position = UDim2.new(Saturation, -4, 1 - Value, -4)
                UpdateColor()
            end

            return {
                Instance = ColorPicker,
                SetColor = SetColor
            }
        end

        function TabElements.Paragraph(config)
            elementOrder = elementOrder + 1
            local ParagraphFrame = Linux.Instance("Frame", {
                Parent = ElementContainer,
                BackgroundColor3 = Linux.Theme.Element,
                Size = UDim2.new(1, -5, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = 1,
                LayoutOrder = elementOrder
            })

            Linux.Instance("UICorner", {
                Parent = ParagraphFrame,
                CornerRadius = UDim.new(0, 4)
            })

            Linux:ApplyShadow(ParagraphFrame, Linux.Theme.Shadow, 3, 0.6)
            Linux:ApplyGradient(ParagraphFrame, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Linux.Theme.Element),
                ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.Element, 0.9))
            }), 90)
            Linux:ApplyBorder(ParagraphFrame, Linux.Theme.Border, 1, 0.3)

            local Title = Linux.Instance("TextLabel", {
                Parent = ParagraphFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 0, 20),
                Position = UDim2.new(0, 5, 0, 5),
                Font = Enum.Font.SourceSansBold,
                Text = config.Title or "Paragraph",
                TextColor3 = Linux.Theme.Text,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 1
            })

            local Content = Linux.Instance("TextLabel", {
                Parent = ParagraphFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 0, 0),
                Position = UDim2.new(0, 5, 0, 25),
                Font = Enum.Font.SourceSans,
                Text = config.Content or "Content",
                TextColor3 = Linux.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = 1
            })

            local ParagraphPadding = Linux.Instance("UIPadding", {
                Parent = ParagraphFrame,
                PaddingBottom = UDim.new(0, 5)
            })

            local function SetTitle(newTitle)
                Title.Text = tostring(newTitle)
            end

            local function SetContent(newContent)
                Content.Text = tostring(newContent)
            end

            return {
                Instance = ParagraphFrame,
                SetTitle = SetTitle,
                SetContent = SetContent
            }
        end

        function TabElements.Notification(config)
            elementOrder = elementOrder + 1
            local NotificationFrame = Linux.Instance("Frame", {
                Parent = ElementContainer,
                BackgroundColor3 = Linux.Theme.Element,
                Size = UDim2.new(1, -5, 0, 30),
                ZIndex = 1,
                LayoutOrder = elementOrder
            })

            Linux.Instance("UICorner", {
                Parent = NotificationFrame,
                CornerRadius = UDim.new(0, 4)
            })

            Linux:ApplyShadow(NotificationFrame, Linux.Theme.Shadow, 3, 0.6)
            Linux:ApplyGradient(NotificationFrame, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Linux.Theme.Element),
                ColorSequenceKeypoint.new(1, DarkenColor(Linux.Theme.Element, 0.9))
            }), 90)
            Linux:ApplyBorder(NotificationFrame, Linux.Theme.Border, 1, 0.3)

            local Label = Linux.Instance("TextLabel", {
                Parent = NotificationFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Font = Enum.Font.SourceSans,
                Text = config.Name,
                TextColor3 = Linux.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 1
            })

            local NotificationText = Linux.Instance("TextLabel", {
                Parent = NotificationFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, -10, 1, 0),
                Position = UDim2.new(0.5, 5, 0, 0),
                Font = Enum.Font.SourceSans,
                Text = config.Default or "No interaction yet",
                TextColor3 = Linux.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 1
            })

            local function SetText(newText)
                NotificationText.Text = tostring(newText)
            end

            return {
                Instance = NotificationFrame,
                SetText = SetText,
                GetText = function() return NotificationText.Text end
            }
        end

        return TabElements
    end

    return LinuxLib
end

return Linux
