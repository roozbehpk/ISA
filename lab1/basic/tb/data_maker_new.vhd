library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity data_maker is  
  port (
    CLK     : in  std_logic;
    RST_n   : in  std_logic;
    VOUT    : out std_logic;
    DOUT    : out std_logic_vector(7 downto 0);
    a0      : out std_logic_vector(7 downto 0);
    a1      : out std_logic_vector(7 downto 0);
    a2      : out std_logic_vector(7 downto 0);
    b1      : out std_logic_vector(7 downto 0);
    b2      : out std_logic_vector(7 downto 0);
    END_SIM : out std_logic);
end data_maker;

architecture beh of data_maker is

  constant tco : time := 1 ns;
  --constant tc : time := 25 ns;

  
  signal sEndSim : std_logic;
  signal END_SIM_i : std_logic_vector(0 to 10);  

begin  -- beh

  a0 <= conv_std_logic_vector(26,8);
  a1 <= conv_std_logic_vector(52,8);
  a2 <= conv_std_logic_vector(26,8);
  b1 <= conv_std_logic_vector(-48,8);  
  b2 <= conv_std_logic_vector(25,8);
  
  process (CLK, RST_n)
    file fp_in : text open READ_MODE is "../samples.txt";
    variable line_in : line;
    variable x, temp : integer;
  begin  -- process
    if RST_n = '0' then                 -- asynchronous reset (active low)
      DOUT <= (others => '0') after tco;      
      VOUT <= '0' after tco;
      sEndSim <= '0' after tco;
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      if not endfile(fp_in) then
        readline(fp_in, line_in);
        read(line_in, x);
	if x = temp THEN
		VOUT <= '0' after tco; 
		DOUT <= conv_std_logic_vector(x, 8) after tco; 
	else
	 	temp := x;
       		DOUT <= conv_std_logic_vector(x, 8) after tco;
       	 	VOUT <= '1' after tco;
       		sEndSim <= '0' after tco;
	end if;
      else
        VOUT <= '0' after tco;        
        sEndSim <= '1' after tco;
      end if;
    end if;
  end process;

  process (CLK, RST_n)
  begin  -- process
    if RST_n = '0' then                 -- asynchronous reset (active low)
      END_SIM_i <= (others => '0') after tco;
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      END_SIM_i(0) <= sEndSim after tco;
      END_SIM_i(1 to 6) <= END_SIM_i(0 to 5) after tco;
    end if;
  end process;

  END_SIM <= END_SIM_i(6);  

end beh;
