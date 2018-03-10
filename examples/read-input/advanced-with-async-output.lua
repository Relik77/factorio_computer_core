--[[
-- This program write questions and print the user answer, with time displayed asynchronously.
-- So we need rewrite the screen and the user input, after every screen print.
]]

inputEnable = false
counter = 0

questions = {
    "What is your name?",
    "How old are you?"
}
question = ""
answers = ""
input = ""

function getHour()
    local time = (os.date() % 25000) / 25000 * 24
    local h = math.floor(time)
    local m = math.floor((time - h) * 60)
    local s = math.floor((((time - h) * 60) - m) * 60)

    h = h + 12
    if h >= 24 then
        h = h - 24
    end
    if h < 10 then
        h = '0' .. h
    end
    if m < 10 then
        m = '0' .. m
    end
    if s < 10 then
        s = '0' .. s
    end
    return h .. ':' .. m .. ':' .. s
end

--[[ Each seconds IRL, this function print the in-game time in the screen ]]
function printDate()
    counter = counter + 1

    --[[ We clear the screen for print the date at the beginning ]]
    term.clear()
    term.write("Date: " .. getHour())

    --[[ We print questions and user answers ]]
    if #answers > 0 then
        term.write(answers)
    end
    os.wait(printDate, 1)
end
printDate()

--[[ This function write the next question and enable user input ]]
function nextQuestion()
    input = ""
    question = ""
    term.setInput("")

    if #questions > 0 then
        question = questions[1]
        table.remove(questions, 1);

        answers = answers .. question
        term.write(question)
        inputEnable = true
    else
        answers = answers .. "End"
        term.write("End")
    end
end

term.addInputListener(function(event)
    --[[ If user input is disable, remove the user entry from the screen. ]]
    if not inputEnable then
        return term.setInput("")
    end

    --[[ Get the user input ]]
    input = event.userInput

    --[[ Check if the user has validated his answer by pressing "Enter" ]]
    if input:sub(#input) == "\n" then
        input = input:sub(1, #input - 1)
        term.write("You enter: " .. input)
        answers = answers .. "\nYou enter: " .. input .. "\n"

        --[[ Disable user input and pass to next question ]]
        inputEnable = false
        nextQuestion()
    end
end)
nextQuestion()

--[[ This listener is called after whenever screen print ]]
term.addOutputListener(function(event)
    --[[ We rewrite the user input ]]
    term.setInput(input)
end)
