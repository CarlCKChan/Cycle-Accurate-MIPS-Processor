-- Test bench for Counter Exercise

entity CounterTB is
end;

library design_library;
library IEEE;
use IEEE.Std_logic_1164.all;

architecture Bench of CounterTB is

  component Counter
    port (Clock, Reset, Enable, Load, UpDn: in Std_logic;
          Data: in Std_logic_vector(7 downto 0);
          Q:   out Std_logic_vector(7 downto 0));
  end component;

  signal Clock, Reset, Enable, Load, UpDn: Std_logic;
  signal Data, Q: Std_logic_vector(7 downto 0);

  signal OK: Boolean := True;

begin

  Clk: process
  begin
    while now <= 3000 NS loop
      Clock <= '0';
      wait for 5 NS;
      Clock <= '1';
      wait for 5 NS;
    end loop;
    wait;
  end process;

  Stim: process
  begin
    Enable <= '0';
    Load <= '0';
    UpDn <= '1';
    Reset <= '1';
    wait for 10 ns; -- Should be reset
    Reset <= '0';
    wait for 10 ns; -- Should do nothing - not enabled
    Enable <= '1';
    wait for 20 ns; -- Should count up to 2
    UpDn <= '0';
    wait for 40 ns; -- Should count downto 254
    UpDn <= '1';
    wait for 40 ns; -- Should count up to 2
    Reset <= '1';
    wait for 10 ns; -- Should be reset, overriding enable
    Reset <= '0';
    wait for 30 ns; -- Should count up to 3
    Enable <= '0';
    wait for 10 ns; -- Should do nothing - not enabled
    Data <= "01111111";
    Load <= '1';
    wait for 10 ns; -- Should do nothing - not enabled
    Load <= '0';
    Enable <= '1';
    wait for 10 ns; -- Should count from 3 to 4
    Load <= '1';
    wait for 10 ns; -- Should load 127
    Load <= '0';
    wait for 20 ns; -- Should count from 127 to 129
    Enable <= '0';
    wait for 10 ns; -- Should do nothing - not enabled
    UpDn <= '0';
    wait for 10 ns; -- Should do nothing - not enabled
    Enable <= '1';
    wait for 20 ns; -- Should count down from 129 to 127
    Data <= "11110000";
    Load <= '1';
    wait for 10 ns; -- Should load
    Reset <= '1';
    wait for 10 ns; -- Should be reset, overriding load
    Load <= '0';
    UpDn <= '1';
    wait for 10 ns; -- Should stay at 0 - still reset
    Reset <= '0';
    wait for 2560 ns; -- Should count from 0 round to 0
    Enable <= '0';
    wait;   
  end process;

  G1: Counter port map (Clock, Reset, Enable, Load, UpDn, Data, Q);

  Check: process
  begin
    wait for 9 ns;
    if Q /= "00000000" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000000"  then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000001" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000010" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000001" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000000" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "11111111" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "11111110" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "11111111" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000000" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000001" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000010" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000000" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000001" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000010" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000011" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000011" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000011" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000100" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "01111111" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "10000000" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "10000001" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "10000001" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "10000001" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "10000000" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "01111111" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "11110000" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000000" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000000" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000001" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000010" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000011" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000100" then
      OK <= False;
    end if;
    wait for 2500 ns;
    if Q /= "11111110" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "11111111" then
      OK <= False;
    end if;
    wait for 10 ns;
    if Q /= "00000000" then
      OK <= False;
    end if;
    wait;   
  end process;

end;

