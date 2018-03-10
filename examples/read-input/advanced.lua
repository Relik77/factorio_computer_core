--[[ This program write questions and print the user answer ]]

inputEnable = false

questions = {
    "What is your name?",
    "How old are you?"
}

--[[ This function write the next question and enable user input ]]
function nextQuestion()
    if #questions > 0 then
        local question = questions[1]
        table.remove(questions, 1);

        term.write(question)
        inputEnable = true
    end
end

term.addInputListener(function(event)
    --[[ If user input is disable, remove the user entry from the screen. ]]
    if not inputEnable then
        return term.setInput("")
    end

    --[[ Get the user input ]]
    local input = event.userInput

    --[[ Check if the user has validated his answer by pressing "Enter" ]]
    if input:sub(#input) == "\n" then
        input = input:sub(1, #input - 1)
        term.write("You enter: " .. input)

        --[[ Disable user input and pass to next question ]]
        inputEnable = false
        nextQuestion()
    end
end)
nextQuestion()
