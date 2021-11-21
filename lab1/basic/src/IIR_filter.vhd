
 --IIR-FILTER order 2,8-bits ----GROUP 26 - ISA2021 (Lorenzo Latella,Roozbeh Nikzadi,Kiyanoosh zangeneh)
 
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use IEEE.math_real.all;

ENTITY IIR_filter IS
	PORT (CLK,RST_n : IN STD_LOGIC;
			VIN: IN STD_LOGIC;
			VOUT: OUT STD_LOGIC;
			a0,a1,a2,b1,b2: IN SIGNED (7 DOWNTO 0); 
			DIN: IN SIGNED (7 DOWNTO 0); --sample
			DOUT: OUT SIGNED (7 DOWNTO 0));
END IIR_filter;

ARCHITECTURE Behavioural OF IIR_filter IS

COMPONENT myregister IS
	GENERIC (N: INTEGER:=8);
	PORT(DATA_IN: IN SIGNED (N-1 DOWNTO 0);
		  EN: IN STD_LOGIC;
		  CLK, RST_n: IN STD_LOGIC;
		  DATA_OUT: OUT SIGNED (N-1 DOWNTO 0));
END COMPONENT;

COMPONENT reg IS
	GENERIC (N: INTEGER:=1);
	PORT(DATA_IN: IN STD_LOGIC;
		  EN: IN STD_LOGIC;
		  CLK, RST_n: IN STD_LOGIC;
		  DATA_OUT: OUT STD_LOGIC);
END COMPONENT;
--SIGNAL DECLARATION

-- in few signals we put more bits than 8 to avoid the overflow

-- input
SIGNAL INPUT_SAMPLE,DIN_DELAY: SIGNED (7 DOWNTO 0); 
SIGNAL A0_COEFF, A1_COEFF, A2_COEFF: SIGNED (7 DOWNTO 0);
SIGNAL B1_COEFF, B2_COEFF: SIGNED (7 DOWNTO 0);

SIGNAL N: INTEGER;
SIGNAL OUTPUT,V_OUT, VOUT_S, VIN_S, EN: STD_LOGIC := '0';

-- internal 
SIGNAL T0: SIGNED (7 DOWNTO 0) := (others=>'0');
SIGNAL T1: SIGNED (8 DOWNTO 0) := (others=>'0');
SIGNAL T2: SIGNED (7 DOWNTO 0) := (others=>'0');
SIGNAL D1,D2,D3,D4,D5: SIGNED (6 DOWNTO 0):= (others=>'0');
SIGNAL zeros: SIGNED (7 DOWNTO 0) := (others=>'0');
SIGNAL FF: SIGNED (8 DOWNTO 0) := (others=>'0'); 

-- out 
SIGNAL Z1_OUT, Z2_OUT: SIGNED (8 DOWNTO 0):= (others=>'0');
SIGNAL M1,M2,M3,M4,M5: SIGNED (16 DOWNTO 0):= (others=>'0');
SIGNAL OUT_REG: SIGNED (7 DOWNTO 0);
SIGNAL Y: SIGNED (7 DOWNTO 0):= (others=>'0');

BEGIN	

PROCESS (CLK,RST_n)
	BEGIN
		IF (RST_n = '0') THEN
			VOUT<='0';
			DOUT<=(others=>'0');
			EN <= '0';
			ELSIF (CLK='1' AND CLK'EVENT) THEN
				EN <= '1';
				IF VIN_S = '1' THEN
					DOUT<= OUT_REG;
					VOUT<= V_OUT;
					OUTPUT<='1';
					VOUT_S<='1';
				ELSE
					OUTPUT<='0';
					VOUT_S<='0';
					DOUT<= OUT_REG;	
					VOUT<= V_OUT;
				END IF;
			END IF;
END PROCESS;


M1 <= Z1_OUT * (-B1_COEFF);
D1 <= M1(13 DOWNTO 7);

M2 <= Z2_OUT * (-B2_COEFF);
D2 <= M2(13 DOWNTO 7);

T0 <= zeros + D1 + D2;--8

M3 <= Z1_OUT * A1_COEFF;
D3 <= M3(13 DOWNTO 7);

M4 <= Z2_OUT * A2_COEFF;
D4 <= M4(13 DOWNTO 7);

T2 <= zeros + D3 + D4;--8

T1 <= ('0' & zeros) + INPUT_SAMPLE + T0;--9

M5 <= T1 * A0_COEFF;
D5 <= M5(13 DOWNTO 7); --7

FF <= ('0' & zeros) + D5 + T2;--9

Y  <= FF(7 DOWNTO 0);    
									
-- INPUT REGISTER

REG_IN_DELAY: myregister GENERIC MAP(N=>8) 
			 PORT MAP (DIN,'1',CLK,RST_n,DIN_DELAY);
REG_DATA_IN: myregister GENERIC MAP(N=>8) 
								PORT MAP (DIN_DELAY,VIN_S,CLK,RST_n,INPUT_SAMPLE);
REG_VIN: reg GENERIC MAP(N=>1) 
								PORT MAP (VIN,EN,CLK,RST_n,VIN_S);
REG_COEFF_A0: myregister GENERIC MAP (N=>8)
								 PORT MAP (a0,EN,CLK,RST_n,A0_COEFF);
REG_COEFF_A1: myregister GENERIC MAP (N=>8)
								 PORT MAP (a1,EN,CLK,RST_n,A1_COEFF);
REG_COEFF_A2: myregister GENERIC MAP (N=>8)
								 PORT MAP (a2,EN,CLK,RST_n,A2_COEFF);								
REG_COEFF_B1: myregister GENERIC MAP (N=>8)
								 PORT MAP (b1,EN,CLK,RST_n,B1_COEFF);								
REG_COEFF_B2: myregister GENERIC MAP (N=>8)
								 PORT MAP (b2,EN,CLK,RST_n,B2_COEFF);
REG_DATA_OUT: myregister GENERIC MAP(N=>8) 
								 PORT MAP (Y,VOUT_S,CLK,RST_n,OUT_REG);
REG_VOUT: reg GENERIC MAP(N=>1) 
								 PORT MAP (VOUT_S,EN,CLK,RST_n,V_OUT);
-- INTERNAL REGISTER
REG_Z1: myregister GENERIC MAP (N=>9)
						 PORT MAP (T1,OUTPUT,CLK,RST_n,Z1_OUT);
REG_Z2: myregister GENERIC MAP (N=>9)
						 PORT MAP (Z1_OUT,OUTPUT,CLK,RST_n,Z2_OUT);				
	
END Behavioural; 

