# Cycle-Accurate-MIPS-Processor
A synthesizeable Verilog definition of a MIPs processor


Final project component includes features:
  - Implements all basic MIPS processor instructions.
  - Multi-stage pipeline to improve throughput.
  - Stalling used for data dependencies only when absolutely necessary.
    - Data forwarding between pipeline stages used to remove need to stall for most dependencies.
    - Also used register file forwarding by reading and writing on rising and falling clock edges, respectively.
