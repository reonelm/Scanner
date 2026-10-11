local R, H, D, STEP = 1500, 400, 5, 400
local FOLDERS = {"NPCs", "Enemies"}
local lp = game:GetService("Players").LocalPlayer
local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
if not root then return warn("Karakter belum ke-load") end
local o = root.Position

if workspace.StreamingEnabled then 
    local pending = 0
    for x = -R, R, STEP do
        for z = -R, R, STEP do
            pending = pending + 1
            task.spawn(function()
                pcall(lp.RequestStreamAroundAsync, lp, Vector3.new(o.X + x, o.Y, o.Z + z), 3)
                pending = pending - 1
            end)
        end
    end
    local t = os.clock()
    while pending > 0 and os.clock() - t < 15 do task.wait() end
end

local function scan(f, g)
    for _, m in ipairs(f:GetChildren()) do
        if m:IsA("Folder") then scan(m, g) else
            local p = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
            if p then
                local v = p.Position
                local dx, dz = v.X - o.X, v.Z - o.Z
                if dx*dx + dz*dz <= R*R and math.abs(v.Y - o.Y) <= H then
                    local l, dup = g[m.Name], false
                    if not l then l = {} g[m.Name] = l end
                    for _, w in ipairs(l) do
                        if (w - v).Magnitude < D then dup = true break end
                    end
                    if not dup then l[#l+1] = v end
                end
            end
        end
    end
end

local out, total = {"return {"}, 0
for _, name in ipairs(FOLDERS) do
    local f, g, names = workspace:FindFirstChild(name), {}, {}
    if f then
        scan(f, g)
        for n in pairs(g) do names[#names+1] = n end
        table.sort(names)
        out[#out+1] = "  " .. name .. " = {"
        for _, n in ipairs(names) do
            local l, c = g[n], {}
            table.sort(l, function(a, b) return (a - o).Magnitude < (b - o).Magnitude end)
            for i, v in ipairs(l) do c[i] = string.format("CFrame.new(%.1f, %.1f, %.1f)", v.X, v.Y, v.Z) end
            total = total + #l
            out[#out+1] = string.format("    [%q] = {%s},", n, table.concat(c, ", "))
        end
        out[#out+1] = "  },"
    end
end
out[#out+1] = "}"

local s = table.concat(out, "\n")
if setclipboard then setclipboard(s) print("Tersalin:", total, "posisi") else print(s) end
