# Disarm Alarm
Verilog Project for Digital Systems Lab (Korea Univ. EE)

## UseCases
- Top Module: DisarmAlarm.v & DisarmAlarm.xdc
- Clock Divider: Divides the clock(50MHz) into 1MHz, 1kHz for different types of displays
- Devils Piezo Alarm: Saves music-note parameters and arrays for each ringtone/sound fx corresponding to each level(LV 1~3) or state(SUCCESS / FAIL)
- Problem Generator: Creates a random math problem using LFSR and modulus
- RGB Controller: Shows colors corresponding to each level or state
- Segment Controller: Shows timer(60 secs)
- Text LCD Controller: Shows math problem generated at 'Problem Generator' module, or success/fail messages
- TFT LCD Display Controller: Shows a picture of 'Devils Alarm'
