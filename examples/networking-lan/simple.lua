--[[ This program read left signal and print to the right connector ]]

function loop()
    --[[ Get the user input ]]
    local inputSignals = lan.getLeftSignals()
    local outputSignals = {}

    --[[ Change values ]]
    for i, signal in pairs(inputSignals) do
        outputSignals[i] = {
            signal = signal.signal,
            count = signal.count + math.random(5)
        }
    end

    --[[ Write output signals ]]
    lan.setRightSignals(outputSignals)
    os.wait(loop, 1)
end
loop()
