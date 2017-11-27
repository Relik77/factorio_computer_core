require("logic.computer")

table.insert(computer.apis,{
    name = "lan",
    description = "The LAN API provides functions to communicate using circuit network",
    entities = function(entity)
        if entity.name == "computer-entity" then
            return true
        end
        return false
    end,
    prototype = {
        _readCombinatorSignal = {
            "private function lan:_readCombinatorSignal(combinator, wire)",
            function(self, combinator, wire)
                local signals = {}
                local network

                if wire then
                    network = combinator.get_circuit_network(wire)
                end

                if network then
                    for key, value in pairs(network.signals) do
                        if value.signal and value.signal.name and value.count > 0 then
                            if not signals[value.signal.name] then
                                signals[value.signal.name] = {
                                    signal = value.signal,
                                    count = value.count
                                }
                            else
                                signals[value.signal.name].count = signals[value.signal.name].count + value.count
                            end
                        end
                    end
                else
                    for key, value in pairs(combinator.get_or_create_control_behavior().parameters.parameters) do
                        if value.signal and value.signal.name and value.count > 0 then
                            if not signals[value.signal.name] then
                                signals[value.signal.name] = {
                                    signal = value.signal,
                                    count = value.count
                                }
                            else
                                signals[value.signal.name].count = signals[value.signal.name].count + value.count
                            end
                        end
                    end
                end

                return signals
            end
        },
        _writeCombinatorSignal = {
            "private function lan:_readCombinatorSignal(combinator, signals)",
            function(self, combinator, signals)
                local parameters = {}
                local index = 1;

                if not combinator then return end

                for _, signal_count in pairs(signals) do
                    table.insert(parameters, {
                        index=index,
                        signal=signal_count.signal,
                        count= math.floor(signal_count.count)
                    })
                    index = index + 1
                end
                combinator.get_or_create_control_behavior().parameters = {parameters = parameters}
            end
        },
        readLeftSignals = {
            "lan.readLeftSignals(wire) - Returns left signals",
            function(self, wire)
                local struct = self.__entityStructure
                local signals = {}

                local combinator = struct.sub.left_combinator
                if not combinator then return end

                for key, signal in pairs(self:_readCombinatorSignal(combinator, wire)) do
                    table.insert(signals, signal)
                end

                return signals
            end
        },
        readRightSignals = {
            "lan.readRightSignals(wire) - Returns right signals",
            function(self, wire)
                local struct = self.__entityStructure
                local signals = {}

                local combinator = struct.sub.right_combinator
                if not combinator then return end

                for key, signal in pairs(self:_readCombinatorSignal(combinator, wire)) do
                    table.insert(signals, signal)
                end

                return signals
            end
        },
        writeLeftSignals = {
            "lan.writeLeftSignal(signals) - Write signals on left combinator",
            function(self, signals)
                local struct = self.__entityStructure

                local combinator = struct.sub.left_combinator
                if not combinator then return end

                self:_writeCombinatorSignal(combinator, signals)
            end
        },
        writeRightSignals = {
            "lan.writeRightSignals(signals) - Write signals on right combinator",
            function(self, signals)
                local struct = self.__entityStructure

                local combinator = struct.sub.right_combinator
                if not combinator then return end

                self:_writeCombinatorSignal(combinator, signals)
            end
        }
    }
})
