require("logic.computer")

computer.guis["console"] = {
    prefix = "computer_computerConsoleGui_",

    new = function (player, os)
        local obj = {
            valid = true,

            player = player,

            children = {
                parent = player.gui.center
            },

            os = nil
        }

        for index, value in pairs(computer.guis["console"]) do
            obj[index] = value
        end

        obj.os = os

        obj:buildGui()
        obj:print(obj.os.history)

        return obj
    end,

    destroy = function(self)
        self.valid = false

        if self.children.root and self.children.root.valid then
            self.children.root.destroy()
        end
    end,

    OnGuiClick = function(self, event)
        local name = event.element.name

        if name == self.prefix .. "rootFrame" and event.button == defines.mouse_button_type.right then
            self.os:closeGui()
        end
    end,

    OnGuiTextChanged = function(self, event)
        local gui = event.element

        if not self.valid then return end
        if gui.name == self.prefix .. "input" then
            if not gui.text:startsWith(self.os.history) then
                return self:print(self.os.history)
            end

            local input = gui.text:sub(#self.os.history + 1);

            if input:sub(#input) == "\n" then
                local cmd = input:sub(1, #input - 1)
                self.os.history = self.os.history .. cmd .. "\n"

                local result = self.os:exec(cmd)
                if type(result) == "string" then
                    self.os.history = self.os.history .. result:ensureRight('\n')
                end
                if self.os.history ~= "> " and not self.os.history:endWith("\n> ") then
                    self.os.history = self.os.history:ensureRight("\n"):ensureRight(self.os:exec("pwd") .. "> ")
                end
                self:print(self.os.history)
            end
        end
    end,

    print = function(self, text)
        if self.valid then
            self.children.input.text = text
        end
    end,

    buildGui = function(self)
        local elts = self.children

        if elts.parent[self.prefix .. "rootFrame"] and elts.parent[self.prefix .. "rootFrame"].valid then
            elts.parent[self.prefix .. "rootFrame"].destroy()
        end
        elts.root = elts.parent.add({
            type = "frame",
            name = self.prefix .. "rootFrame",
            caption = "Computer console",
            direction = "vertical",
        })
        elts.root.style.minimal_width = 800
        elts.root.style.maximal_width = 800
        elts.root.style.minimal_height = 400
        elts.root.style.maximal_height = 700

        elts.buttonFlow = elts.root.add({
            type = "flow",
            name = self.prefix .. "btnFlow",
        })

        elts.input = elts.buttonFlow.add({
            type = "text-box",
            name = self.prefix .. "input"
        })
        elts.input.style.minimal_width = 800
        elts.input.style.maximal_width = 800
        elts.input.style.minimal_height = 400
        elts.input.style.maximal_height = 400
    end
}
