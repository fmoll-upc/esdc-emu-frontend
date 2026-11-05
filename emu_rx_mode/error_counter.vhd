--Simple counter for errors in communication 
--Author: F. Moll
--Version 1.0 1/11/2026

library ieee;
use ieee.std_logic_1164.all;

entity error_counter is
	generic(MAX_COUNT : integer range 0 to 7 := 3);
	port(clk_i, nrst_i : in std_logic;
	   ce_i : in std_logic;
	   clear_i : in std_logic;
	   count_o : out integer range 0 to MAX_COUNT
	);
end error_counter;

architecture main of error_counter is

signal cnt : integer range 0 to MAX_COUNT;  

begin

cntr : process(clk_i, nrst_i) begin
if nrst_i = '0' then
	cnt <= 0;
elsif rising_edge(clk_i) then
	if (clear_i ='1') then
		cnt <= 0;
	elsif (ce_i='1' and (cnt /= MAX_COUNT)) then
		cnt <= cnt + 1;
	end if;
end if;
end process cntr;


-- Output functions
count_o <= cnt;

end;
