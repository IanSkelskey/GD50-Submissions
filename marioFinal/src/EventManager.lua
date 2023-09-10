-- EventManager.lua
EventManager = Class {}

function EventManager:init()
    self.listeners = {}
end

function EventManager:subscribe(event, listener)
    if not self.listeners[event] then
        self.listeners[event] = {}
    end
    table.insert(self.listeners[event], listener)
end

function EventManager:emit(event, ...)
    if self.listeners[event] then
        for _, listener in pairs(self.listeners[event]) do
            listener(...)
        end
    end
end
