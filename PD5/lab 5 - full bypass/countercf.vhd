-- Configuration for Counter Exercise

library design_library;
configuration Cfg_CounterTB of CounterTB is
  for Bench
    for G1: Counter
      use entity design_library.counter(rtl);
    end for;
  end for;
end;
