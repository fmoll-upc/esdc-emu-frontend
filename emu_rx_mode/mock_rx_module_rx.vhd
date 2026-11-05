--Emulator of RX module in TX mode
-- It emulates a reception lasting for RX_TIME cycles
-- after receiving a trigger signal and additional delay 
-- of RX_DELAY cycles.
-- Emulated reception of 10 valuess (RCVD_DAT)
--Author: F. Moll
--Version 0.9 1/11/2026

library ieee;
use ieee.std_logic_1164.all;

entity mock_rx_module_rx is
	generic(
		RX_DELAY : integer range 0 to 31 := 4;
		RX_TIME : integer range 0 to 31 := 15;
		BIT_SIZE : integer := 8);
	port(clk_i, nrst_i : in std_logic;
	   trigger_rx_i : in std_logic;
	   read_clear_i : in std_logic;
	   rx_data_o : out std_logic_vector(BIT_SIZE-1 downto 0);  
	   rx_new_o : out std_logic; 
	   busy_o  : out std_logic 
	);
end mock_rx_module_rx;

architecture main of mock_rx_module_rx is

constant ACK : std_logic_vector(7 downto 0):= X"06";
constant NAK : std_logic_vector(7 downto 0):= X"15";
constant STX : std_logic_vector(7 downto 0):= X"02";
constant EOT : std_logic_vector(7 downto 0):= X"04";

type dat_array is array (0 to 9) of std_logic_vector(7 downto 0);
constant RCVD_DAT : dat_array := (
	X"00", --initial value, to be discarded 
	X"02", --STX
	X"41",
	X"42",
	X"43",
	X"44",
	X"45",
	X"46",
	X"47",
	X"04" --EOT
);

type state_type is (rx_idle, rx_wait, rx_count, new_val);
signal state : state_type;

signal del_cnt : integer range 0 to RX_DELAY;   
signal rcvd_index : integer range 0 to 9;   
signal del_ce   : std_logic;
signal rx_cnt : integer range 0 to RX_TIME; 
signal rx_ce   : std_logic;
signal ce_recep   : std_logic;

begin

del_ce <= '1' when (trigger_rx_i = '1' and state = rx_idle)
	or (state = rx_wait) else '0';

del_counter : process(clk_i, nrst_i) begin
if nrst_i = '0' then
	del_cnt <= 0;
elsif rising_edge(clk_i) then
	if (del_ce = '1') then
		if (del_cnt = RX_DELAY) then
			del_cnt <= 0;
		else
			del_cnt <= del_cnt +1;
		end if;
	end if;
end if;
end process del_counter;

rx_ce <= '1' when ((del_cnt = RX_DELAY) and (state = rx_wait))
	or (state = rx_count) else '0';
---------RX time counter
rx_counter : process(clk_i, nrst_i) begin
if nrst_i = '0' then
	rx_cnt <= 0;
elsif rising_edge(clk_i) then
	if (rx_ce = '1') then
		if (rx_cnt = RX_TIME) then
			rx_cnt <= 0;
		else
			rx_cnt <= rx_cnt +1;
		end if;
	else
		rx_cnt <= 0;
	end if;
end if;
end process rx_counter;

--------- MOCK RECEIVER FSM ---------
TX_FSM: process(clk_i, nrst_i) begin
if nrst_i = '0' then
	state <= rx_idle;

elsif clk_i'event and clk_i = '1' then
	case state is
	when rx_idle => 
		if trigger_rx_i = '1' then
			state <= rx_wait;
		end if;
	when rx_wait => 
		if (del_cnt = RX_DELAY) then
			state <= rx_count;
		end if;
	when rx_count => 
		if (rx_cnt = RX_TIME) then
			state <= new_val;
		end if;
	when new_val => 
		if (read_clear_i = '1') then
			state <= rx_idle;
		end if;
	when others => 
		state <= rx_idle;
	end case;
end if;
end process;

ce_recep <= '1' when rx_cnt = RX_TIME and state = rx_count
	else '0';
-- receptions counter
recep_counter : process(clk_i, nrst_i) begin
if nrst_i = '0' then
	rcvd_index <= 0;
elsif rising_edge(clk_i) then
	if (ce_recep = '1') then
		if (rcvd_index = 9) then
			rcvd_index <= 0;
		else
			rcvd_index <= rcvd_index + 1;
		end if;
	end if;
end if;
end process recep_counter;


-- Output functions
busy_o <= '1' when (state = rx_count) else '0';
rx_new_o <= '1' when (state = new_val) else '0';
rx_data_o <= RCVD_DAT(rcvd_index);

end;
