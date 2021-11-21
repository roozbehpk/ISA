 

 ------ J-LOOK-AHEAD J=1 --------------- GROUP 26 - ISA2021 ---------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY IIR_LH IS
PORT (CLK,RST_n : IN STD_LOGIC;
		VIN: IN STD_LOGIC;
		VOUT: OUT STD_LOGIC;
		a0,a1,a2,b1,b2: IN SIGNED (7 DOWNTO 0); 
		DIN: IN SIGNED (7 DOWNTO 0);
		DOUT: OUT SIGNED (7 DOWNTO 0));
END IIR_LH;


ARCHITECTURE Behavioral OF IIR_LH IS

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


-- coefficients
SIGNAL A0_COEFF,A1_COEFF,A2_COEFF,B1_COEFF,B2_COEFF: SIGNED (7 DOWNTO 0);
SIGNAL H0: SIGNED (7 DOWNTO 0) := (others => '0'); -- 8 
SIGNAL H1,H2,H3,H4,H5: SIGNED (7 DOWNTO 0) := (others => '0'); 
SIGNAL HH1,HH2,HH3,HH4,HH5: SIGNED (8 DOWNTO 0) := (others => '0'); 
SIGNAL HH1_i,HH2_i,HH3_i,HH4_i,HH5_i: SIGNED (15 DOWNTO 0) := (others => '0'); 

-- input control signal
SIGNAL INPUT_SAMPLE, DIN_DELAY: SIGNED (7 DOWNTO 0) := (others => '0');
SIGNAL VIN_S, EN: STD_LOGIC;

-- internal register signal
SIGNAL T1,TT1,TT6,T10,TT10: SIGNED (9 DOWNTO 0) := (others => '0'); 
SIGNAL TT9: SIGNED (8 DOWNTO 0) := (others => '0');
SIGNAL T2,TT2,T3,TT3,T4,TT4,T5,TT5,T7,TT7,T8,TT8: SIGNED (7 DOWNTO 0) := (others => '0');-- 8

SIGNAL D2,D3,D4,D5,D7,D8: SIGNED (17 DOWNTO 0) := (others => '0');

SIGNAL TS1: SIGNED (8 DOWNTO 0) := (others => '0'); -- 9
SIGNAL TS2: SIGNED (8 DOWNTO 0) := (others => '0');

-- output signal
SIGNAL Y_OUT: SIGNED (10 DOWNTO 0) := (others => '0'); -- 11
SIGNAL Y,OUT_REG: SIGNED (7 DOWNTO 0) := (others => '0');

-- parallelism signal
SIGNAL zeros12: SIGNED (7 DOWNTO 0) := (others => '0');
SIGNAL zeros13: SIGNED (8 DOWNTO 0) := (others => '0');
SIGNAL zeros14: SIGNED (9 DOWNTO 0) := (others => '0');

-- output control signal
SIGNAL V_OUT,OUTPUT,OUTPUT_DELAY: STD_LOGIC;
SIGNAL VOUT_S,VOUT_T,VOUT_U: STD_LOGIC := '0';

BEGIN

PROCESS (CLK,RST_n)
	BEGIN
		IF (RST_n = '0') THEN
			VOUT <= '0';
			DOUT <= (others => '0');
			EN <= '0';	
			ELSIF (CLK='1' AND CLK'EVENT) THEN
				EN <=  '1';
				IF VIN_S = '1' THEN
					DOUT<= OUT_REG;
					VOUT<= V_OUT;
					OUTPUT_DELAY<='1';
					VOUT_S<='1';
					
				ELSE
					OUTPUT_DELAY <= '0'; 	
					VOUT_S<='0';
					DOUT<= OUT_REG;	
					VOUT<= V_OUT;
				END IF;
			END IF;
	
END PROCESS;

-- COEFFICIENTS
H0 <= A0_COEFF; -- 8

HH1_i <= B1_COEFF*A0_COEFF; -- 16
HH1 <= zeros13 + A1_COEFF - HH1_i(14 DOWNTO 7); -- 9

HH2_i <= B1_COEFF*A1_COEFF;
HH2 <= zeros13 + A2_COEFF - HH2_i(14 DOWNTO 7);

HH3_i <= B1_COEFF*A2_COEFF;
HH3 <= zeros13 - HH3_i(14 DOWNTO 7);

HH4_i <= B1_COEFF*B1_COEFF;
HH4 <= zeros13 + B2_COEFF - HH4_i(14 DOWNTO 7);

HH5_i <= B1_COEFF*B2_COEFF;
HH5 <= zeros13 + HH5_i(14 DOWNTO 7);

H1 <= HH1(7 DOWNTO 0);
H2 <= HH2(7 DOWNTO 0);
H3 <= HH3(7 DOWNTO 0);
H4 <= HH4(7 DOWNTO 0);
H5 <= HH5(7 DOWNTO 0);

T1 <= zeros14 + INPUT_SAMPLE - TS1; -- 10

D2 <= TT1 * H0; -- 18
T2 <= D2(14 DOWNTO 7);

D3 <= TT1 * H1; -- 18
T3 <= D3(14 DOWNTO 7);

D4 <= TT1 * H2; -- 18
T4 <= D4(14 DOWNTO 7);

D5 <= TT1 * H4; -- 18
T5 <= D5(14 DOWNTO 7);

D7 <= TT6 * H5; -- 18
T7 <= D7(14 DOWNTO 7);

D8 <= TT6 * H3; --18
T8 <= D8(14 DOWNTO 7);

TS1 <= zeros13 + TT5 - TT7; -- 9

TS2 <= zeros13 + TT8 + TT4; -- 9

T10 <= zeros14 + TT9 + TT3; -- 10

Y_OUT <= '0' & zeros14 + TT2 + TT10; -- 11

Y <= Y_OUT(7 DOWNTO 0);


-- INPUT REGISTER
REG_IN_DELAY: myregister  GENERIC MAP (N=>8) 
			 PORT MAP (DIN,'1',CLK,RST_n,DIN_DELAY); 
REG_DATA_IN:  myregister GENERIC MAP (N=>8) 
			 PORT MAP (DIN_DELAY,VIN_S,CLK,RST_n,INPUT_SAMPLE);
REG_VIN:      reg 	 GENERIC MAP(N=>1) 
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

-- INTERNAL REGISTER
REG_Z1:       myregister GENERIC MAP (N=>10)
			 PORT MAP (T1,OUTPUT,CLK,RST_n,TT1); 
REG_Z2:       myregister GENERIC MAP (N=>8)
			 PORT MAP (T2,OUTPUT,CLK,RST_n,TT2);
REG_Z3:       myregister GENERIC MAP (N=>8)
			 PORT MAP (T3,OUTPUT,CLK,RST_n,TT3);
REG_Z4:       myregister GENERIC MAP (N=>8)
			 PORT MAP (T4,OUTPUT,CLK,RST_n,TT4);
REG_Z5:       myregister GENERIC MAP (N=>8)
			 PORT MAP (T5,OUTPUT,CLK,RST_n,TT5);
REG_Z6:       myregister GENERIC MAP (N=>10)
			 PORT MAP (TT1,OUTPUT,CLK,RST_n,TT6);
REG_Z7:       myregister GENERIC MAP (N=>8)
			 PORT MAP (T7,OUTPUT,CLK,RST_n,TT7);
REG_Z8:       myregister GENERIC MAP (N=>8)
			 PORT MAP (T8,OUTPUT,CLK,RST_n,TT8);
REG_Z9:       myregister GENERIC MAP (N=>9)
			 PORT MAP (TS2,OUTPUT,CLK,RST_n,TT9);							 
REG_Z10:      myregister GENERIC MAP (N=>10)
			 PORT MAP (T10,OUTPUT,CLK,RST_n,TT10);
						 
-- OUTPUT REGISTER	
REG_DATA_OUT: myregister GENERIC MAP(N=>8) 
			 PORT MAP (Y,VOUT_U,CLK,RST_n,OUT_REG); 	 	
REG_VOUT_1: 	reg 	 GENERIC MAP(N=>8) 
			 PORT MAP (VOUT_S,EN,CLK,RST_n,VOUT_T); 	 
REG_VOUT_2:     reg 	 GENERIC MAP(N=>1) 
			 PORT MAP (VOUT_T,EN,CLK,RST_n,VOUT_U);
REG_VOUT_3:     reg 	 GENERIC MAP(N=>1) 
			 PORT MAP (VOUT_U,EN,CLK,RST_n,V_OUT); 

REG_OUTPUT_DELAY:  reg 	 GENERIC MAP(N=>1) 
			 PORT MAP (OUTPUT_DELAY,EN,CLK,RST_n,OUTPUT); 
END Behavioral;
