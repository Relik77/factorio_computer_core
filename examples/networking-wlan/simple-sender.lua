--[[
-- This program communicate with another computer and send a value
-- Blueprint: 0eNqdlt2uoyAQgN+Fa90I9a+92BfZnBiq05YEwQA22zS++wGtnlrpVvemFZFvfpmZOzryFhrFhEGHO2KlFBod/tyRZmdBuXtnbg2gA2IGahQgQWu3UpRx1AWIiQr+ogPuvgIEwjDDYDjfL26FaOsjKPvBdNLYoyLURjaW1khtj0jh5FhMiKMA3dx/bNkVU1AOu2mAtKHDM7JyF3wy8ctWXaEKewU9ApKHAPwiwMPcTUztlD5fzFvqqDaZU4mHGq/U9I2iOw8ymYUlfITOo+b+14NqH+ZY7MGm6+3PB2w+h2YeaLYaSrxMn6L5Svujt+bbUNvMN0ry4ggXemVSuUMlU2XLTFFyqaEYr8SJcg3BtKmAVtOeUS10PUwMbO042P0oqJ5vBrMrG9yvrvNYtF+ZJAQPBq2IpsvRNcyJ6GP8XOMaKtbWIXArU7EybCSHJSwePZ70Hl/plvyNV/DTLZd10xpQoS1coE60hHD4eKnDlPTYy3y65TXlPOS09lQmnEyU0ZL32SJFNZ09MaVNsaimV6ZM2yfpKLz/IoQrqJu5MHFGgxRb9lxpjoLeZKqoccLQb7fd2qQsJZdKPxLPZ1/8Pz4j0b+dlmzLz908PWMfMt2Sni/AxAd8qjTtcewensD2wNhrZr61AqYr9Npva1X7zzWVRJt6yv5zkyJ4Y5lOP3cpQra2qey1THuN322s/guqL0ok3tr8cbTCrcmmMWgxTsynIDty9UPZ4WmGC5AtIHoYafKM4DgmOc667htfwUZx
-- For blueprint: Requires to connect left connector on left computer to the electric pole with a red wire, and connect the lamp to the left connector on right computer
-- This program run on left computer (blueprint)
-- Left computer is named "Computer-Left" and other computer is named "Computer-Right" (run command "label set Computer-Left" on left computer console)
]]

function loop()
    --[[ Read signals on red wire ]]
    local inputSignals = lan.getLeftSignals("red")

    --[[ print signal on terminal (debug) ]]
    term.write(inputSignals)

    --[[ Send values to other computer ]]
    wlan.emit("Computer-Right", "RailSignal", inputSignals)
    os.wait(loop, 1)
end
loop()
