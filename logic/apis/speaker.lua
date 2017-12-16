require("logic.computer")

table.insert(computer.apis, {
    name = "speaker",
    description = "The Speaker API makes it possible to issue map alerts",
    entities = function(entity)
        return entity.name == "computer-interface-entity"
    end,
    events = {
        on_script_kill = function(self)
            self:mute()
        end
    },
    prototype = {
        mute = {
            "speaker.mute() - Remove alert et mute speaker",
            function(self)
                local struct = self.__entityStructure

                local speaker = struct.sub.speaker
                if not speaker then
                    return
                end

                speaker.alert_parameters = {
                    show_alert = false,
                    show_on_map = false,
                    icon_signal_id = speaker.alert_parameters.icon_signal_id,
                    alert_message = speaker.alert_parameters.alert_message
                }
                speaker.get_or_create_control_behavior().circuit_condition = {
                    condition = {
                        comparator = "=",
                        first_signal = { type = "virtual", name = "signal-everything" },
                        constant = 1
                    },
                    fulfilled = false
                }
                speaker.disconnect_neighbour(defines.wire_type.red)
            end
        },
        setAlert = {
            "speaker.setAlert(text, signal, sound) - Issue a map alert",
            function(self, text, signal, sound)
                local struct = self.__entityStructure

                local speaker = struct.sub.speaker
                if not speaker then
                    return
                end

                if type(sound) == "string" then
                    sound = table.searchIndex(speaker.prototype.instruments[1].notes, sound)
                end

                speaker.parameters = {
                    playback_volume = 1,
                    playback_globally = true,
                    allow_polyphony = false
                }
                speaker.alert_parameters = {
                    show_alert = true,
                    show_on_map = true,
                    icon_signal_id = signal,
                    alert_message = text
                }
                speaker.get_or_create_control_behavior().circuit_parameters = {
                    signal_value_is_pitch = false,
                    instrument_id = 0,
                    note_id = sound
                }
                speaker.get_or_create_control_behavior().circuit_condition = {
                    condition = {
                        comparator = "=",
                        first_signal = { type = "virtual", name = "signal-everything" },
                        constant = 0
                    },
                    fulfilled = true
                }

                if not struct.sub.speaker_combinator then
                    return
                end
                struct.sub.speaker_combinator.connect_neighbour({
                    target_entity = speaker,
                    wire = defines.wire_type.red
                })
                struct.sub.speaker_combinator.get_or_create_control_behavior().parameters = {parameters = {}}
            end
        },
        playNote = {
            "speaker.playNote(note, instrument, volume, allow_polyphony) - Play a musical note",
            function(self, note, instrument, volume, allow_polyphony)
                local struct = self.__entityStructure

                local speaker = struct.sub.speaker
                if not speaker then
                    return
                end

                local instruments = speaker.prototype.instruments
                if type(instrument) == "string" then
                    instrument = table.searchIndex(instruments, instrument, "name")
                end
                if type(note) == "string" then
                    note = table.searchIndex(instruments[instrument].notes, note)
                end

                speaker.parameters = {
                    playback_volume = volume,
                    playback_globally = false,
                    allow_polyphony = not not allow_polyphony
                }
                speaker.get_or_create_control_behavior().circuit_parameters = {
                    signal_value_is_pitch = true,
                    instrument_id = instrument - 1,
                    note_id = 1
                }
                speaker.get_or_create_control_behavior().circuit_condition = {
                    condition = {
                        first_signal = {
                            type = "virtual",
                            name = "signal-music-note"
                        }
                    }
                }

                if not struct.sub.speaker_combinator then
                    return
                end
                struct.sub.speaker_combinator.connect_neighbour({
                    target_entity = speaker,
                    wire = defines.wire_type.red
                })
                struct.sub.speaker_combinator.get_or_create_control_behavior().parameters = {parameters = {{
                    index = 1,
                    signal = {
                        type = "virtual",
                        name = "signal-music-note"
                    },
                    count = note
                }}}
            end
        },
        getInstruments = {
            "speaker.getInstruments() - Return available instruments",
            function(self)
                local struct = self.__entityStructure

                local speaker = struct.sub.speaker
                if not speaker then
                    return
                end
                return speaker.prototype.instruments
            end
        }
    }
})
