require("logic.computer")
local utf8 = require("logic.utf8")

computer.guis["editor"] = {
    prefix = "computer_computerEditorGui_",

    new = function (player, os)
        local obj = {
            valid = true,

            player = player,
            file = nil,

            children = {
                parent = player.gui.center
            },

            os = nil
        }

        for index, value in pairs(computer.guis["editor"]) do
            obj[index] = value
        end

        obj.os = os

        obj:buildGui()

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
        elseif name == self.prefix .. "backbtn" then
            self.os:openGui("console")
        elseif name == self.prefix .. "runbtn" then
            self.os:exec("run", self.file, unpack(self.children.input.text:split("%s", nil, true)))
        end
    end,

    OnGuiTextChanged = function(self, event)
        local gui = event.element

        if gui.name == self.prefix .. "textArea" then
            self.file.mtime = game.tick;
            self.file.text = gui.text
        end
    end,

    loadFile = function(self, file)
        self.file = file
        self.children.textArea.text = file.text
    end,

    buildGui = function(self)
        local elts = self.children

        if elts.parent[self.prefix .. "rootFrame"] and elts.parent[self.prefix .. "rootFrame"].valid then
            elts.parent[self.prefix .. "rootFrame"].destroy()
        end
        elts.root = elts.parent.add({
            type = "frame",
            name = self.prefix .. "rootFrame",
            caption = "File Editor",
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

        elts.textArea = elts.buttonFlow.add({
            type = "text-box",
            name = self.prefix .. "textArea"
        })
        elts.textArea.style.minimal_width = 800
        elts.textArea.style.maximal_width = 800
        elts.textArea.style.minimal_height = 400
        elts.textArea.style.maximal_height = 400

        elts.footer = elts.root.add({
            type = "table",
            name = self.prefix .. "footer",
            column_count = 3
        })

        elts.input = elts.footer.add({
            type = "text-box",
            name = self.prefix .. "input"
        })
        elts.input.style.minimal_width = 600
        elts.input.style.maximal_width = 600
        elts.input.style.minimal_height = 40
        elts.input.style.maximal_height = 40

        elts.runbtn = elts.footer.add({
            type = "button",
            name = self.prefix .. "runbtn",
            caption="Run"
        })
        elts.runbtn.style.minimal_width = 85
        elts.runbtn.style.maximal_width = 85

        elts.backbtn = elts.footer.add({
            type = "button",
            name = self.prefix .. "backbtn",
            caption="Back"
        })
        elts.backbtn.style.minimal_width = 85
        elts.backbtn.style.maximal_width = 85
    end
}
