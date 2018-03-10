--[[ This program write and question and wait the user answer ]]

term.write("What is your name?")

function loop()
    --[[ Get the user input ]]
    local input = term.getInput()

    --[[ Check if the user has validated his answer by pressing "Enter" ]]
    if input:sub(#input) == "\n" then
        input = input:sub(1, #input - 1)
        term.write("You enter: " .. input)
    else
        --[[ Check user hasn't validated his answer, wait and loop ]]
        os.wait(loop, 1)
    end
end
loop()
