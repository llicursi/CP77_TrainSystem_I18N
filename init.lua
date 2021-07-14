local debug = require("debug/logic/debug")

ts = {
    runtimeData = {
        cetOpen = false,
        inMenu = false,
        inGame = false,
        noTrains = false
    },

    defaultSettings = {
        fallProtection = true,
        camDist = 20,
        defaultSeat = "seat_front_right"
    },

    settings = {},
	CPS = require("CPStyling"),
    input = require("modules/utils/input"),
    observers = require("modules/utils/observers"),
    hud = require("modules/ui/hud"),
    Cron = require("modules/utils/Cron"),
    GameUI = require("modules/utils/GameUI")
}

function ts:new()
    registerForEvent("onInit", function()
        ts.entrySys = require("modules/entrySystem"):new(ts)
        ts.stationSys = require("modules/stationSystem"):new(ts)
        ts.trackSys = require("modules/trackSystem"):new(ts)

        ts.trackSys:load()
        ts.entrySys:load()
        ts.stationSys:load()

        ts.observers.start(ts)
        ts.input.startInputObserver()

        Observe('RadialWheelController', 'OnIsInMenuChanged', function(_, isInMenu) -- Setup observer and GameUI to detect inGame / inMenu
            ts.runtimeData.inMenu = isInMenu
        end)

        ts.GameUI.OnSessionStart(function()
            ts.runtimeData.inGame = true
        end)

        ts.GameUI.OnSessionEnd(function()
            ts.runtimeData.inGame = false
        end)

        ts.runtimeData.inGame = not ts.GameUI.IsDetached() -- Required to check if ingame after reloading all mods

        config.tryCreateConfig("data/config.json", ts.defaultSettings)
        ts.settings = config.loadFile("data/config.json")
    end)

    registerForEvent("onUpdate", function(deltaTime)
        if (not ts.runtimeData.inMenu) and ts.runtimeData.inGame then
            debug.run(ts)
            ts.observers.update()
            ts.entrySys:update()
            ts.stationSys:update(deltaTime)
        end
        ts.Cron.Update(deltaTime)
    end)

    registerForEvent("onDraw", function()

    end)

    registerForEvent("onOverlayOpen", function()
        ts.runtimeData.cetOpen = true
    end)

    registerForEvent("onOverlayClose", function()
        ts.runtimeData.cetOpen = false
    end)

    return ts

end

return ts:new()