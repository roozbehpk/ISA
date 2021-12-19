-- our version of data_sink, with a ERROR signal when the oputput is not the same of the prod file, and -- he write a results file 
-- Lab 2, group 26 Latella, Nikzadi, Zangeneh
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity data_sink is
  port (
    CLK   : in std_logic;
    RST_n : in std_logic;
    FP_Z  : in std_logic_vector (31 downto 0);
	EN    : in std_logic;
	ERR   : out std_logic);
end data_sink;

architecture beh of data_sink is

begin  -- beh

	write_file: process (CLK, RST_n)
	    file res_fp : text open WRITE_MODE is "./results/fpmul_results.txt";
	    variable line_out : line;    
	
		file fp_in : text open READ_MODE is "../tb/fp_prod.hex";
		variable line_in : line;
		variable x : std_logic_vector(31 downto 0);

	begin  -- process
	    if RST_n = '0' then                 -- asynchronous reset (active low)
	       ERR <= '0'; 
		elsif CLK'event and CLK = '1' then  -- rising clock edge
	        if EN = '1'  then
	        	hwrite(line_out,FP_Z);
	        	writeline(res_fp, line_out);
				-- reading datas by file				
				if not endfile(fp_in) then
					readline(fp_in, line_in);
					hread(line_in, x);
					-- start compare the output and file 
					if (x /= FP_Z)then
						ERR<= '1';
					end if; 	      
				end if;
	        end if;
		end if;
	end process write_file;

end beh;
