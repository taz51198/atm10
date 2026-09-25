# ATM10 Reactor Controller

Fresh controller for Extreme Reactors 2.4.28 / ATM10.

## Hardware
- Reactor ComputerCraft computer: ID 11
- Reactor peripheral: back
- Reactor modem: left
- Matrix ComputerCraft computer: ID 9
- Matrix peripheral: back
- Matrix modem: left

## Control
- Reactor target temperature: 1300 C
- Temperature operating band: 1200-1400 C
- Rod control gain: 0.03
- Maximum rod adjustment per 2-second cycle: 2 percentage points
- Startup rod insertion: 100%
- Matrix hysteresis: reactor ON below 20%, reactor OFF at/above 40%
- Matrix data is sent wirelessly from computer 9 to computer 11.

The controller is written from scratch for the current reactor computer and is not copied from the previous controller.
