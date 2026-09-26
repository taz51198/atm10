-- ATM10 Reactor Controller
-- Fresh controller for Reactor Computer 11
-- Extreme Reactors 2.4.28

local REACTOR = peripheral.wrap("back")
local MATRIX_COMPUTER = 12

local TARGET_TEMP = 1300
local GAIN = 0.03
local MAX_ROD_STEP = 2
local CONTROL_INTERVAL = 2

local MATRIX_ON = 0.20
local MATRIX_OFF = 0.40
local MATRIX_TIMEOUT = 5

rednet.open("left")

local rodCount = REACTOR.getNumberOfControlRods()

-- Safe startup state: all rods inserted and reactor off.
for i = 0, rodCount - 1 do
    REACTOR.setControlRodLevel(i, 100)
end
REACTOR.setActive(false)

local matrixPercent = 1
local lastMatrixUpdate = os.clock()
local timer = os.startTimer(CONTROL_INTERVAL)

local function setAllRods(level)
    level = math.max(0, math.min(100, level))

    for i = 0, rodCount - 1 do
        REACTOR.setControlRodLevel(i, level)
    end
end

local function averageRodLevel()
    local total = 0

    for i = 0, rodCount - 1 do
        total = total + REACTOR.getControlRodLevel(i)
    end

    return total / rodCount
end

local function controlRods()
    local temperature = REACTOR.getFuelTemperature()
    local current = averageRodLevel()

    local adjustment = (temperature - TARGET_TEMP) * GAIN
    adjustment = math.max(-MAX_ROD_STEP, math.min(MAX_ROD_STEP, adjustment))

    setAllRods(current + adjustment)
end

term.clear()
term.setCursorPos(1, 1)
print("ATM10 Reactor Controller")
print("Reactor computer: 11")
print("Matrix computer: 12")
print("Rods: " .. rodCount)
print("Target: " .. TARGET_TEMP .. " C")
print("Waiting for matrix control...")

while true do
    local event, sender, message = os.pullEvent()

    if event == "rednet_message"
        and sender == MATRIX_COMPUTER
        and type(message) == "table"
        and message.type == "matrix"
        and type(message.percent) == "number" then

        matrixPercent = message.percent
        lastMatrixUpdate = os.clock()

    elseif event == "timer" and sender == timer then

        local linkAlive = (os.clock() - lastMatrixUpdate) <= MATRIX_TIMEOUT

        if not linkAlive then
            -- Lost matrix telemetry: fail safe.
            REACTOR.setActive(false)
        else
            -- Matrix hysteresis.
            if matrixPercent < MATRIX_ON then
                REACTOR.setActive(true)
            elseif matrixPercent >= MATRIX_OFF then
                REACTOR.setActive(false)
            end

            if REACTOR.getActive() then
                controlRods()
            end
        end

        term.clear()
        term.setCursorPos(1, 1)
        print("ATM10 Reactor Controller")
        print("Matrix: " .. string.format("%.1f", matrixPercent * 100) .. "%")
        print("Reactor: " .. (REACTOR.getActive() and "ON" or "OFF"))
        print("Fuel: " .. string.format("%.1f", REACTOR.getFuelTemperature()) .. " C")
        print("Rods: " .. string.format("%.1f", averageRodLevel()) .. "%")
        print("Matrix link: " .. (linkAlive and "OK" or "LOST"))

        timer = os.startTimer(CONTROL_INTERVAL)
    end
end
