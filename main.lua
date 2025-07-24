local WindowMan = require("WindowMan")
local partname = "Light Rect 1x1"
local lightBehaviour = "Light"
local lightBrightness = "Brightness"
local screenheight = 50
local screenwidth = 50
local screen = {}

local function weldparts( parta, partb)
    local Player = LocalPlayer.Value
    if parta == partb then
        MessagePopupShow.Raise( 'Part A equals Part B' )
        return false
    end
    if parta == nil then
        MessagePopupShow.Raise( 'No Part A' )
        return false
    end
    if partb == nil then
        MessagePopupShow.Raise( 'No Part B' )
        return false
    end
    if parta.Attachments.IsAttached( partb ) or partb.Attachments.IsAttached( parta ) then
		MessagePopupShow.Raise( 'Parts already attached!' )
        return false
	elseif parta.ParentConstruction.IsFrozen ~= partb.ParentConstruction.IsFrozen then
		MessagePopupShow.Raise( 'Parts must be either both frozen or both unfrozen!' )
        return false
	else
		local attachType = attachType_Fixed
		local searchPosition = Player.Targeter.TargetedPosition * 0.5
		local searchNormal = Vector3.Normalize( partb.Position - parta.Position )
		AttachmentOps.CreateAttachment( attachType, parta, partb, searchPosition, searchNormal )
        return true
	end
end

function SpawnPart(AssetName, position, rotation, size)
    local parts = {  }
    local p = nil
    for part in Parts.Instances do
        parts[part.ID] = part
    end
    PopConstructions.SpawnPart( AssetName, position, rotation )
    for part in Parts.Instances do
        if not parts[part.ID] then
            p = part
        end
    end
    if p then
        if size then
            p.SetSize( size )
        end
        return p
    end
end

local function SpawnScreen(L, W)
    local Player = LocalPlayer.Value
    local Pos = Player.Aim.Position
    local Aim = Quaternion.__new(0,0,0,0)
    local n = 0
    local lastpart = nil
    local RealX = Vector3.__new(0,0,0)
    local AddX = Vector3.__new(-0.1,0,0)
    local AddY = Vector3.__new(0,-0.1,0)
    for y=1, L do
        local row = {}
        RealX = Vector3.__new(0,RealX.Y,0)
        for x=1, W do
            RealX = RealX + AddX
            print(n)
            n=n+1
            row[x] = SpawnPart(partname, Pos+RealX, Aim)
            row[x].Behaviours[1].GetTweakable(lightBrightness).Value = 0.1
            if lastpart then
                weldparts(row[x], lastpart)
                lastpart = row[x]
            else
                lastpart = row[x]
            end
        end
        RealX = RealX+AddY
        screen[y] = row
    end
end

local function SpawnScreenIntermediate ()
    SpawnScreen(screenheight, screenwidth)
end

local buttonwidth = 80
local buttonheight = 30
local buttons = 5
local Idx = 0
local WindowWidth = buttonwidth
local WindowHeight = buttonheight + buttons + 1 

local w = WindowMan.CreateWindow(WindowHeight, WindowWidth, WindowMan.GenericOnWindowClose)

local spawmScreenButton = WindowMan.CreateButton(0,Idx*buttonheight, buttonwidth, buttonheight, "Spawn Screen", w, SpawnScreenIntermediate)

function Update()
    local canvas = loadfile("canvas.lua")()
    if not screen[1] then
        return
    end
    if not canvas then
        return
    end
    for y=1, screenheight do
        for x=1, screenwidth do
            if not (screen[y][x].Behaviours[1].IsActivated == canvas[y][x]) then
                PartBehaviourOps.ToggleActivated( screen[y][x] )
            end
        end
    end
end