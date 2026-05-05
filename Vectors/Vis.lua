-- High level fixes applied:
-- 1) Fix removal while iterating Jobs (was skipping entries).
-- 2) Fix global leak: highlight in Vis.Show.
-- 3) Fix pool exhaustion: do not create Vectors_Point_0 or reuse same name when pool is full.
-- 4) Defensive nil checks where the original code could explode.

local Vis = {}
Vectors.Vis = Vis

local Point      = Frame:Subclass("Vectors_Point")
local Point_Hook = Frame:Subclass("Vectors_Invis")

local ipairs = ipairs
local math   = math

local WindowGetAlpha              = WindowGetAlpha
local WindowStartPositionAnimation= WindowStartPositionAnimation
local WindowGetScale              = WindowGetScale
local WindowSetScale              = WindowSetScale
local WindowSetShowing            = WindowSetShowing
local WindowSetTintColor          = WindowSetTintColor
local WindowGetAnchorCount        = WindowGetAnchorCount
local WindowGetAnchor             = WindowGetAnchor
local WindowClearAnchors          = WindowClearAnchors
local WindowAddAnchor             = WindowAddAnchor
local WindowForceProcessAnchors   = WindowForceProcessAnchors
local WindowGetScreenPosition     = WindowGetScreenPosition
local DoesWindowExist             = DoesWindowExist

local ti = table.insert
local tr = table.remove
local math_min = math.min
local math_max = math.max
local math_abs = math.abs

local Jobs = {}
local pool = {}

function Vis.Shutdown()
    for i = #Jobs, 1, -1 do
        local job = Jobs[i]
        if job then
            if job.newpoint and job.newpoint.Shutdown then
                job.newpoint:Shutdown()
            end
            for j = 1, #job do
                local p = job[j]
                if p and p.Shutdown then
                    p:Shutdown()
                end
            end
        end
        Jobs[i] = nil
    end
end

function Vis.Update(e)
    -- Iterate backwards so removals are safe
    for i = #Jobs, 1, -1 do
        local job = Jobs[i]
        if job and Vis.UpdateJob(job, e) then
            tr(Jobs, i)
        end
    end
end

function Vis.UpdateJob(j, e)
    if not j then return true end

    if j.newpoint then
        if j.newpoint.GetAlpha and j.newpoint:GetAlpha() == 1 then
            j.newpoint:Start(
                j.startX, j.startY, j.endX, j.endY,
                math_min(3, 0.6 * (math_max(#j, j.last or 0) / 2) + 0.8)
            )
            ti(j, 1, j.newpoint)
            j.newpoint = nil
        end
    else
        if j.active then
            j.e = (j.e or 0) + e
            local threshold = math_max(0.1, 0.01 + 0.01 * (math_max(#j, j.last or 0) / 2))
            if j.e > threshold then
                local p = Point:Create(j.startX, j.startY, j.highlight, j.scale)
                if p then
                    j.newpoint = p
                else
                    -- Pool exhausted, stop trying to spawn more points for this job
                    j.active = false
                end
                j.e = 0
            end
        end
    end

    -- Cleanup tail points that have stopped fading
    while true do
        local tmp = j[#j]
        if not tmp then break end

        local alpha = tmp.GetAlpha and tmp:GetAlpha() or 0
        if alpha < 1 and alpha == (tmp.lastalpha or 1) then
            if tmp.Destroy then tmp:Destroy() end
            j[#j] = nil
        else
            tmp.lastalpha = alpha
            break
        end
    end

    return not (j.active or j.newpoint or #j > 0)
end

function Vis.Show(name, h)
    if not name or name == "" or name == "Root" then return end
    if not DoesWindowExist(name) then return end

    local c = WindowGetAnchorCount(name)
    if not c or c <= 0 then return end

    local highlight = 1
    if type(h) == "number" and h ~= 0 then
        highlight = h
    end

    for i = 1, #Jobs do
        Jobs[i].active = false
    end

    for i = 1, c do
        Vis.AddJob(name, i, highlight == i)
    end
end

function Vis.AddJob(name, n, highlight)
    local pp, p, pw, x, y = WindowGetAnchor(name, n)
    if not pp or not p or not pw then return end

    local job = {
        active    = true,
        n         = n,
        name      = name,
        e         = 1,
        highlight = highlight
    }

    for i = 1, #Jobs do
        local k = Jobs[i]
        if k and k.name == name and k.n == n then
            job.last = #k
            break
        end
    end

    job.endX, job.endY   = Vis.GetCoordsFromAnchor(name, p)
    job.startX, job.startY = Vis.GetCoordsFromAnchor(pw, pp)

    if not job.endX or not job.startX then
        job.active = false
        return
    end

    job.scale = math_max(math_abs(job.startX - job.endX), math_abs(job.startY - job.endY)) / 30
    ti(Jobs, 1, job)
end

function Vis.GetCoordsFromAnchor(name, point)
    if not DoesWindowExist(name) then return nil, nil end
    WindowClearAnchors("Vectors_Invis")
    WindowAddAnchor("Vectors_Invis", point, name, "topleft", 0, 0)
    WindowForceProcessAnchors("Vectors_Invis")
    return WindowGetScreenPosition("Vectors_Invis")
end

local fadingout = {}

local function onshutdown(windowname, visible)
    local p = fadingout[windowname]
    if (not visible) and p then
        if p.Destroy then p:Destroy() end
        fadingout[windowname] = nil
    end
end

function Point:Create(startX, startY, highlight, scale)
    local num

    for i = 1, 150 do
        if pool[i] == nil then
            pool[i] = true
            num = i
            break
        end
    end

    -- Pool exhausted: refuse to create (prevents Vectors_Point_0 and name collisions)
    if not num then
        return nil
    end

    local windowname = "Vectors_Point_" .. num
    local newPoint   = self:CreateFromTemplate(windowname, "Root")
    if not newPoint then
        pool[num] = nil
        return nil
    end

    newPoint.windowname = windowname
    newPoint.num        = num
    newPoint._Destroy   = newPoint.Destroy
    newPoint.Destroy    = newPoint.DestroyH

    local Hookname = windowname .. "_Hook"
    newPoint.Hook  = Point_Hook:CreateFromTemplate(Hookname, "Root")
    if not newPoint.Hook then
        pool[num] = nil
        if newPoint._Destroy then newPoint:_Destroy() end
        return nil
    end

    newPoint.Hook.windowname = Hookname
    WindowAddAnchor(windowname, "center", Hookname, "center", 0, 0)

    if not highlight then
        WindowSetTintColor(windowname, 50, 255, 255)
    end

    if scale and scale > 0.01 then
        WindowSetScale(windowname, WindowGetScale(windowname) * math.min(1, scale))
        WindowStartPositionAnimation(
            Hookname,
            Window.AnimationType.SINGLE_NO_RESET,
            startX + math.random(-10, 10),
            startY + math.random(-10, 10),
            startX, startY,
            0.5, false, 0, 0
        )
        WindowSetShowing(windowname .. "_Scope", false)
    else
        WindowStartPositionAnimation(
            Hookname,
            Window.AnimationType.SINGLE_NO_RESET,
            startX, startY, startX, startY,
            0.5, false, 0, 0
        )
        WindowSetShowing(windowname .. "_Icon", false)
    end

    Fader.Register(windowname, nil, nil, onshutdown)
    Fader.FadeTo(windowname, 1, 0.4, 0, 0)

    newPoint.Hook:Show(true)
    newPoint:Show(true)

    return newPoint
end

function Point:Start(startX, startY, endX, endY, duration)
    WindowStartPositionAnimation(
        self.Hook.windowname,
        Window.AnimationType.SINGLE_NO_RESET,
        startX, startY, endX, endY,
        duration, false, 0, 0
    )
    Fader.FadeTo(self.windowname, 0, 0.3, 0.3 + duration)
end

function Point:DestroyH()
    Fader.Unregister(self.windowname)
    if self.Hook and self.Hook.Destroy then
        self.Hook:Destroy()
    end
    if self._Destroy then
        self:_Destroy()
    end
    pool[self.num] = nil
end

function Point:GetAlpha()
    return WindowGetAlpha(self.windowname)
end

function Point:Shutdown()
    fadingout[self.windowname] = self
    Fader.FadeTo(self.windowname, 0, 0.6)
end
