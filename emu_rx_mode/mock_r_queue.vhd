--Emulator of receiving queue in RX mode
-- it reads 10 predefined values.
--Author: F. Moll
--Version 0.9 1/11/2026

library ieee;
use ieee.std_logic_1164.all;

entity mock_r_queue is
	generic(MBITS : integer :=8);
	port(
		clk_i, nrst_i : in std_logic;
		wr_req_i : in std_logic;
		save_point_i : in std_logic;
		rest_point_i : in std_logic;
		ptr_o : out integer range 0 to 15
		--data_o : out std_logic_vector(MBITS-1 downto 0)
	);
end mock_r_queue;

architecture main of mock_r_queue is

constant ACK : std_logic_vector(7 downto 0):= X"06";
constant NAK : std_logic_vector(7 downto 0):= X"15";
constant STX : std_logic_vector(7 downto 0):= X"02";
constant EOT : std_logic_vector(7 downto 0):= X"04";

signal ptr : integer range 0 to 15;   
signal saved_pt : integer range 0 to 15; 
signal val0, val1, val2, val3, val4, val5, val6, val7, val8, val9 : std_logic_vector(MBITS-1 downto 0);

begin

pointer : process(clk_i, nrst_i) begin
if nrst_i = '0' then
	ptr <= 0;
elsif rising_edge(clk_i) then
	if (wr_req_i = '1') then
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
ptr_o <= ptr;

end;
