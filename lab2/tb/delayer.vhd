-- DELAYER
-- delays the input signala using a shift counter 
-- Lab 2, group 26 Latella, Nikzadi, Zangeneh

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity delayer is
	generic (N: integer := 4);
	port(	
			CLK   : in std_logic;
			RST_n : in std_logic; 
			DIN   : in std_logic;
			DOUT  : out std_logic); 
	end delayer;

architecture beh of delayer is
	signal delay_i : std_logic_vector (0 to N-1);

begin
	shift_count : process(clk, RST_n)
	begin	
		if RST_n = '0' then
			delay_i <= (others => '0');
		elsif CLK'event and CLK = '1' then
			delay_i(0) <= DIN;
			delay_i (1 to N-1) <= delay_i (0 to N-2);
		end if;
	end process shift_count;
	
	DOUT <= delay_i (N-1);

end beh;
