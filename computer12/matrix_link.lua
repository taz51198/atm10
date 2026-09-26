-- ATM10 Matrix Link
-- Computer 12 -> Reactor computer 11
-- Sends the live induction-matrix charge percentage once per second.

local MATRIX = peripheral.wrap("back")
local REACTOR_COMPUTER = 11

rednet.open("left")

while true do
    local percent = MATRIX.getEnergyFilledPercentage()

    rednet.send(REACTOR_COMPUTER, {
        type = "matrix",
        percent = percent
    })

    sleep(1)
end
