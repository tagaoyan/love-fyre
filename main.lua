local canvas
local CW, CH = 320, 240
local DJ = {
    a = -0.895,
    b = 2.62,
    c = 0.29,
    d = -4.185,
    x = 1,
    y = 1,
    step = 500,
    alpha = 0.22,
    counter = {},
}

local grid

local redraw = true

local function roundp(x)
    --return x
    return math.floor(x) + 0.5
end

local function fix3(x)
    return math.floor(x*200 + 0.5) / 200
end

local function scale(x, fmin, fmax, tmin, tmax)
    return (x - fmin) / (fmax - fmin) * (tmax - tmin) + tmin
end

local function cv_coord(x, y)
    return roundp(scale(x, -2, 2, 0.5, CW - 0.5)), roundp(scale(y, -2, 2, CH - 0.5, 0.5))
end

local DJPARAMS = {'a', 'b', 'c', 'd', 'step', 'alpha'}
local djpi = 1
local running = true
local showparam = true
local showgrid = true

local fn = love.graphics.newFont('ter-u12n.pcf', 12)
local function showDetails()
    local msg = string.format([[
a=%g
b=%g
c=%g
d=%g
step=%d
alpha=%g

editing [%s]
dps=%d
A: redraw
S-A: pause/resume
B: randomize
S-B: try init
↑↓: select param
←→: adjust
    with X: fine adjust
Y: toggle param
S-Y: toggle grid]], DJ.a, DJ.b, DJ.c, DJ.d, DJ.step, DJ.alpha, DJPARAMS[djpi], DJ.step * love.timer.getFPS())
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(msg, fn, 1, 1)
    love.graphics.setColor(1, 1, 0)
    love.graphics.print(msg, fn, 0, 0)
end

local function updateGrid()
    local i = 0
    love.graphics.setCanvas(grid)
    love.graphics.clear()
    for x = -2,2,1 do
        for y = -2,2,1 do
            local tx = math.sin(DJ.a * y) - math.cos(DJ.b * x)
            local ty = math.sin(DJ.c * x) - math.cos(DJ.d * y)
            local ox, oy
            tx, ty = cv_coord(tx, ty)
            ox, oy = cv_coord(x, y)
            love.graphics.setColor(0, 0, 1, 0.5)
            love.graphics.line(ox, oy, tx, ty)
            love.graphics.setColor(0, 0.5, 1)
            love.graphics.points(tx, ty)
        end
    end
    love.graphics.setCanvas()
end

local function updateCanvas()
    local x, y
    x = math.sin(DJ.a * DJ.y) - math.cos(DJ.b * DJ.x)
    y = math.sin(DJ.c * DJ.x) - math.cos(DJ.d * DJ.y)
    DJ.x, DJ.y = x, y
    if redraw then
        updateGrid()
    end
    canvas:renderTo(function()
        if redraw then
            love.graphics.clear()
            redraw = false
        end
        love.graphics.setColor(0, 0, 0, DJ.alpha)
        love.graphics.points(cv_coord(x, y))
    end)
end

function love.load()
    canvas = love.graphics.newCanvas(CW, CH)
    grid = love.graphics.newCanvas(CW, CH)
    love.keyboard.setKeyRepeat(true)
end

function love.keypressed(key, scancode)
    if key == 'escape' then
        love.event.quit()
    end
    if key == 'i' then -- Y
        showparam = not showparam
    end
    if key == 'o' then -- S-Y
        showgrid = not showgrid
    end
    if key == 'up' then
        djpi = (djpi - 2) % #DJPARAMS + 1
    end
    if key == 'down' then
        djpi = djpi % #DJPARAMS + 1
    end
    local inc
    if DJPARAMS[djpi] == 'step' then
        inc = 100
    else
        if love.keyboard.isDown('u') then
            inc = 0.005
        else
            inc = 0.05
        end
    end
    if key == 'left' then
        DJ[DJPARAMS[djpi]] = DJ[DJPARAMS[djpi]] - inc
        redraw = true
    end
    if key == 'right' then
        DJ[DJPARAMS[djpi]] = DJ[DJPARAMS[djpi]] + inc
        redraw = true
    end
    if DJPARAMS[djpi] == 'step' then
        redraw = false
    end
    if DJ.step < 100 then
        DJ.step = 100
    end
    if DJ.alpha <= 0.01 then
        DJ.alpha = 0.01
    elseif DJ.alpha > 1 then
        DJ.alpha = 1
    end
    if key == 'j' then -- A
        redraw = true
    end
    if key == 'h' then -- S-A
        running = not running
    end
    if key == 'k' then -- B
        DJ.a = fix3(love.math.random() * 10 - 5)
        DJ.b = fix3(love.math.random() * 5 + math.pi / 3)
        DJ.c = fix3(love.math.random() * 10 - 5)
        DJ.d = fix3(love.math.random() * 5 + math.pi / 3)
        DJ.x = 1
        DJ.y = 1
        redraw = true
    end
    if key == 'l' then -- S-B
        DJ.x = love.math.random() * 4 - 2
        DJ.y = love.math.random() * 4 - 2
    end
end

function love.draw()
    if running then
        for i = 1,DJ.step do
            updateCanvas()
        end
    end
    love.graphics.clear(1, 1, 1)
    love.graphics.setColor(1,1,1)
    love.graphics.draw(canvas, 0, 0)
    if showgrid then
        love.graphics.draw(grid)
    end
    if showparam then
        showDetails()
    end
end

love.graphics.setColor(0.5, 0.5, 0.5)
print(love.graphics.getColor())