# lab05
CMPEN331 - lab05

# 5 Stage Pipelined MIPS R-type & I-type Processor



### First 10 addresses of Data Memory Initialized to 

- A00000AA
- 10000011
- 20000022
- 30000033
- 40000044
- 50000055
- 60000066
- 70000077
- 80000088
- 90000099

### Instructions preprogrammed into the IF Register

- lw $2, 00($1)
- lw $3, 04($1)
- lw $4, 08($1)
- lw $5, 12($1)
- add $6, $2, $10



#### Capture.png shows the simulated waveform of the program, I/O naming is based closely on the 5StageMIPS.png diagram

Mostly a proof of concept, other than add no ALU operations have been tested/debugged yet.
ALU control unit is an intermediate module between the main Control unit and the ALU, not featured in the diagram

UI coming soon
