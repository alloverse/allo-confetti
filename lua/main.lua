local vec3 = require'allo.deps.alloui.lib.cpml.modules.vec3'
local mat4 = require'allo.deps.alloui.lib.cpml.modules.mat4'
local pl = {
    class = require('pl.class')
}

local client = Client(
    arg[2], 
    "confetti"
)
local app = ui.App(client)

assets = {
    quit = ui.Asset.File("images/quit.png"),
}
app.assetManager:add(assets)

Flake = pl.class(ui.Surface)
function Flake:_init(x,y,z)
    local s = 0.1
    self:super(ui.Bounds(x or 0, y or 0, z or 0, s, s, s))
    self:reset()
end

function Flake:reset()
    self.r = math.random()
    self.axis = vec3(math.random(), math.random(), math.random()):normalize()
    self.v = vec3(math.random()-0.5, math.random()*3, math.random()-0.5)
    self.p = vec3(math.random()-0.5, 0, math.random()-0.5)
    self.material.color = { math.random(), math.random(), math.random()}
    self.material.metalness = math.random()
    self.material.roughness = math.random()
end

function Flake:animate()
    if self.p.y < 0 then self:reset() end
    self.r = self.r + 1
    local m = mat4.identity()
    m:rotate(m, self.r, self.axis)
    self.p = self.p + self.v * 0.1
    self.v = self.v - vec3(0, 1, 0) * 0.1
    m:translate(m, self.p)

    self:setTransform(m)
end

Confetti = pl.class(ui.View)
function Confetti:_init(bounds)
    self:super(bounds or ui.Bounds(0,1,0,1,1,1))
    self.flakes = {}
    for i = 0, 50 do
        table.insert(self.flakes, Flake())
    end

    for _, view in ipairs(self.flakes) do
        view.material.roughness = 0
        view.material.metalness = 0
        self:addSubview(view)
    end
end
function Confetti:animate()
    for _, view in ipairs(self.flakes) do
        view:animate()
    end
end

local confetti = Confetti()

app.mainView:addSubview(confetti)
confetti.grabbable = true

local quitButton = app.mainView:addSubview(ui.Button(
    ui.Bounds{size=ui.Size(0.12,0.12,0.05)}
        :move( app.mainView.bounds.size:getEdge("bottom", "right", "front") )
))
quitButton:setDefaultTexture(assets.quit)
quitButton.onActivated = function()
    app:quit()
end


-- run the animation
app:scheduleAction(0.05, true, function ()
    confetti:animate()
end)

if app:connect() then app:run() end
