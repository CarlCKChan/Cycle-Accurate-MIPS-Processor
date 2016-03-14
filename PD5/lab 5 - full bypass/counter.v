// Up down counter example

module COUNTER (Clock, Reset, Enable, Load, UpDn, Data, Q);
  input Clock, Reset, Enable, Load, UpDn;
  input  [7:0] Data;
  output [7:0] Q;
  reg    [7:0] Q;

  always @(posedge Clock or posedge Reset)
    if (Reset)
      Q <= 0;
    else
      if (Enable)
        if (Load)
          Q <= Data;
        else
          if (UpDn)
            Q <= Q + 1;
          else
            Q <= Q - 1;
endmodule
