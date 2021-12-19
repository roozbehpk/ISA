-- data_maker modified for work with signals of rst and end of simulation, and add a shift counter to 
--managed the simulation time
--Lab 2, group 26 Latella, Nikzadi, Zangeneh
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity data_maker is
  port (
	RST_n   : in std_logic; 
    CLK     : in std_logic;
    DATA    : out std_logic_vector(31 downto 0);
	END_SIM : out std_logic;
	D_IN    : out std_logic);
end data_maker;

architecture beh of data_maker is

	signal sign_end_prc :std_logic;
	signal End_prc_i :std_logic_vector(0 to 10);

begin  -- beh


	read_file: process (CLK)
		file fp : text open read_mode is "../tb/fp_samples.hex";
		variable ptr : line;
	    variable val : std_logic_vector(31 downto 0);

	begin  -- process

		if RST_n ='0' then	
			sign_end_prc <= '0';
			D_IN         <= '0';
	    
		elsif CLK'event and CLK = '1' then  -- rising clock edge
	        if (not(endfile(fp))) then
	    	    readline(fp, ptr);
	        	hread(ptr, val);
				DATA <= val;
				sign_end_prc <='0';
				D_IN <= '1';
		    else
				sign_end_prc <= '1';
				D_IN <= '0';    
	        end if;
		end if;
	end process read_file;

-- shift counter that works 10 clk cycles after the EOF of input file, adn give the stop signal at the --end.

	shift_count: process (CLK, RST_n)
	
	begin --process
		if RST_n= '0' then                 -- asynchronous reset (active low)
			End_prc_i <= (others => '0');
		elsif CLK'event and CLK = '1' then  -- rising clock edge
			End_prc_i(0) <= sign_end_prc;
			End_prc_i(1 to 10) <= End_prc_i(0 to 9);
		end if;
	end process shift_count;

  	END_SIM <= End_prc_i(10);
end beh;
