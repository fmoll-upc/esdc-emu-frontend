--Timer 
--Author: F. Moll
--Version 1.0 1/11/2026

library ieee;
use ieee.std_logic_1164.all;

entity timer is
	generic(TIMEOUT : integer range 0 to 127 := 8);
	port(clk_i, nrst_i : in std_logic;
	   start_i : in std_logic;
	   stop_i : in std_logic;
	   timeout_o  : out std_logic
	);
end timer;

architecture main of timer is

signal cntdown : integer range 0 to TIMEOUT;  
signal count_flag : std_logic; 

begin

cnt_flag : process(clk_i, nrst_i) begin
if nrst_i = '0' then
	count_flag <= '0';
elsif rising_edge(clk_i) then
	if (start_i ='1') then
		count_flag <= '1';
	elsif (stop_i = '1') then
		count_flag <= '0';
	end if;
end if;
end process cnt_flag;


main_timer : process(clk_i, nrst_i) begin
if nrst_i = '0' then
	cntdown <= TIMEOUT;
elsif rising_edge(clk_i) then
	if (start_i ='1') then
		cntdown <= TIMEOUT;
	elsif (count_flag = '1' and (cntdown /= 0)) then
		cntdown <= cntdown - 1;
	end if;
end if;
end process main_timer;


-- Output functions
timeout_o <= '1' when (cntdown = 0) else '0';

end;
