--Emulator of sending queue in TX mode
-- it reads 10 predefined values.
--Author: F. Moll
--Version 0.9 1/11/2026

library ieee;
use ieee.std_logic_1164.all;

entity mock_s_queue is
	generic(MBITS : integer :=8);
	port(
		clk_i, nrst_i : in std_logic;
		rd_req_i : in std_logic;
		save_point_i : in std_logic;
		rest_point_i : in std_logic;
		data_o : out std_logic_vector(MBITS-1 downto 0)
	);
end mock_s_queue;

architecture main of mock_s_queue is

constant ACK : std_logic_vector(7 downto 0):= X"06";
constant NAK : std_logic_vector(7 downto 0):= X"15";
constant STX : std_logic_vector(7 downto 0):= X"02";
constant EOT : std_logic_vector(7 downto 0):= X"04";

signal ptr : integer range 0 to 15;   
signal saved_pt : integer range 0 to 15; 
signal val0, val1, val2, val3, val4, val5, val6, val7, val8, val9 : std_logic_vector(MBITS-1 downto 0);

begin

-- 9 values and EOT ; change to experiment other frame structures
val0 <= X"41";
val1 <= X"42";
val2 <= X"43";
val3 <= X"44";
val4 <= X"45";
val5 <= X"46";
val6 <= X"47";
val7 <= X"48";
val8 <= X"49";
val9 <= EOT;

pointer : process(clk_i, nrst_i) begin
if nrst_i = '0' then
	ptr <= 0;
elsif rising_edge(clk_i) then
	if (rd_req_i = '1') then
		if (ptr /= 10) then
		-- if more rd_req keep coming, 
		-- ptr is stuck and output is NAK
			ptr <= ptr +1;
		end if;
	elsif (rest_point_i='1') then
		ptr <= saved_pt;
	end if;
end if;
end process pointer;

point_reg: process(clk_i, nrst_i) begin
if nrst_i = '0' then
	saved_pt <= 0;
elsif rising_edge(clk_i) then
	if (save_point_i = '1') then
		saved_pt <= ptr;
	end if;
end if;
end process point_reg;



-- Output functions
-- ACK is the correct value; chamge to emulate wrong reception
data_o <= 
	val0 when ptr=0 else
	val1 when ptr=1 else
	val2 when ptr=2 else
	val3 when ptr=3 else
	val4 when ptr=4 else
	val5 when ptr=5 else
	val6 when ptr=6 else
	val7 when ptr=7 else
	val8 when ptr=8 else
	val9 when ptr=9 else
	NAK;

end;
