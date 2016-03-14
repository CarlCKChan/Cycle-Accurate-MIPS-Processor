--  Up down counter

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_std.all;

entity Counter is
  port (Clock, Reset, Enable, Load, UpDn: in Std_logic;
        Data: in Std_logic_vector(7 downto 0);
        Q:   out Std_logic_vector(7 downto 0));
end;

architecture RTL of Counter is
  signal Cnt: Unsigned(7 downto 0);
begin
  process (Clock, Reset)
  begin
    if Reset = '1' then
      Cnt <= "00000000";
    elsif Rising_edge(Clock) then
      if Enable = '0' then
        null;
      elsif Load = '1' then
        Cnt <= Unsigned(Data);
      else
        if UpDn = '1' then
          Cnt <= Cnt + 1;
        else
          Cnt <= Cnt - 1;
        end if; 
      end if;
    end if;
  end process;
  
  Q <= Std_logic_vector(Cnt);
end;
