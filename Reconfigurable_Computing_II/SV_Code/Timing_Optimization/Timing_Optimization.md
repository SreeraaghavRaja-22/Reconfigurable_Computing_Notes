# FPGA Timing Optimization

## Background Information

- Pick Constraints based on Situation
  1) FPGA provides fixed clock frequency
       - achieved clock >= board's clock frequency
  2) Design has Real-Time Requirements
       - signal processing at a specific clock frequency
       - must have a clock cycle that matches the audio
  3) Design has bandwidth requirements
       - has a specific input bandwidth requirement
  4) Maximize Performance
       - pick an aggressive constraint like using max clock frequency
- Clock Frequency
  - Tclk = Tdeadline, Tff2ff <= Tdeadline
- FF-to-FF Delays
  - Tc = Cell Delays
  - Tic = Interconnect Delays
  - Tff2ff = Tc + Tic
  - Fmax = 1/Tff2ff
- Maximum Clock Frequency
  - Max Clock Frequency (Fmax) is defined as the longest delay between FFs
  - Critical Path - slower path between FF to FF
- Setup Times
  - Tsetup = window of time before rising clock edge
  - changing input causes metastable output
  - Data has to arrive at destination FF before the setup window of next clock
  - Tff2ff <= Tdeadline where Tdeadline = Tclk - Tsetup
- Clock Skew
  - Clocks are high-fanout signals
  - Not possible to deliver clock to every FF at the same time
  - Difference in clock arrival times = clock skew
  - Clock Skew affects available time before setup violation
- Tff2ff <= Tdeadline, Tdeadline = Tclk + Tskew - Tsetup
- Setup Slack
  - time between setum deadline and data arrival
  - Ssetup = Tclk + Tskew - Tsetup  - (Tc + Tic) = Tdeadline - Tff2ff
  - A path with Ssetup < 0 has a setup violation, so it must be optimized
  - Large positive slack can help with optimizing other paths
- Hold Time
  - Thold = time after rising edge after rising edge
  - input changing during hold window causes metastable FF output
  - New data must not arrive at FF during hold window
    - Tc + Tic >= Thold + Tskew
    - Tff2ff must exceed skew and hold times
- Hold Slack
  - Shold = time between data arrival and hold violation
  - Shold = Tc + Tic - (Tskew + Thold)
  - Shold < 0 is a hold violation
  - Hold violation is usually uncommon and it caused by large amount of clock skew
  - FPGAs minimize clock skew using **PLLs** or **Clock Distribution Networks**

- Timing Optimization Preview
  - focus primarily on setup_violations
  - To avoid setup violations, ensure that
  - Tc + Tic <= Tclk + Tskew - Tsetup
  - Tff2ff <= Tdeadline
  - Tdeadline is out of the control of the engineer for the most part
  - Timing Optimization focuses on reducing Tff2ff
    - Two Options:
      - Reduce cell/logic delays (Tc)
      - Reduce Interconnect delays (Tic)

## Intel Quartus Timing Analyzer

- Quartus Terminology:
  - Data Arrival Time: time signal takes to arrive at destination FF
  - Data Required Time: time when signal is required to have arrived at destination FF
  - Timing Violations Occur when Data Arrival Time > Data Required Time
- Data Arrival Time:
  - Launch Edge + Source Clock Delay + ut_co + Register-to-Register delay
    - Launch Edge: time of clock edge of source register (usually 0 ns)
    - Source Clock Delay: delay from clock source to clock input of source register
    - ut_co: clock-to-output delay (aka clk-to-Q)
      - time between clock edge and output to FF
      - ignore the u symbol, time usually < 1ns
- Data Required Time:
  - Latch Edge + Dest Clock Delay + ut_su (Kevin)
  - Latch Edge: time of clock edge to destination register (usually 1 clock period)
  - Dest Clock Delay: delay from clock source to clock input of dest register
  - ut_su: setup time of destination register
    - ignore the u symbol, time < 1ns

## Optimization Strategies

- Methodology:
  - Set constraints
  - Compile design, run timing analyzer
  - Identify **Total Negative Slack** (TNS)
    - summation of slack on all failing paths
    - estimate of how much effort will be involved for timing optimization
  - Sort failing paths based on negative slack
  - Identify bottlenecks on path with worst negative slack
    - look for both logic/cell and interconnect bottlenecks
  - Apply relevant timing optimizations based on bottlenecks
  - Repeat from 5 for next most-negative path until no more failing paths
    - occasionally restart from 2 to make sure bottlenecks haven't changed
  