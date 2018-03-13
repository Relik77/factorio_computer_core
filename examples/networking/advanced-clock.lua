--[[
-- This program write a clock signal
-- Blueprint: 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
-- For blueprint: Requires to connect right connector to the electric pole with a green wire
]]

local inputSignals = lan.getLeftSignals()

term.write(inputSignals)
if #inputSignals == 0 then
    --[[ Init left signal if empty ]]
    inputSignals = {{signal={type="virtual",name="signal-green"},count=1},{signal={type="virtual",name="signal-yellow"},count=2},{signal={type="virtual",name="signal-white"},count=3},{signal={type="virtual",name="signal-black"},count=4}}
    lan.setLeftSignals(inputSignals)
end
indexes = {}

for i, signal in pairs(inputSignals) do
    --[[ index left signal for allow to change variable on digital connectors ]]
    indexes[signal.count] = signal.signal
end

function loop()
    --[[ get in-game time ]]
    local time = os.time()
    local hours = math.floor(time)
    local minutes = math.floor((time - hours) * 60)
    local outputSignals = {}

    --[[ Write in-game time on console ]]
    term.clear()
    term.write(hours .. ":" .. minutes)

    --[[ Create output signals with custom input variables ]]
    for i, signal in ipairs(indexes) do
        local count = 0
        if i == 1 then
            count = math.floor(hours / 10)
        elseif i == 2 then
            count = hours - math.floor(hours / 10) * 10
        elseif i == 3 then
            count = math.floor(minutes / 10)
        elseif i == 4 then
            count = minutes - math.floor(minutes / 10) * 10
        end

        table.insert(outputSignals, {
            signal = signal,
            count = count
        })
    end
    --[[ Write Output signal ]]
    lan.setRightSignals(outputSignals)
    os.wait(loop, 1)
end
loop()
