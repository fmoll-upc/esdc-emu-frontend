--Emulator of TX module in TX mode
-- When data is sent, it triggers special signal
-- to activate mock_RX module emulating a data reception
-- Each transmission lasts for TX_TIME cycles.
--Author: F. Moll
--Version 0.9 1/11/2026

library ieee;
use ieee.std_logic_1164.all;

entity mock_tx_module_rx is
	generic(TX_TIME : integer range 0 to 31 := 15;
		BIT_SIZE : integer := 8);
	port(clk_i, nrst_i : in std_logic;
	   tx_data_i : in std_logic_vector(BIT_SIZE-1 downto 0);  
	   send_i   : in std_logic;
	   trigger_rx_o : out std_logic;
	   busy_o : out std_logic	
	);
end mock_tx_module_rx;

architecture main of mock_tx_module_rx is

constant ACK : std_logic_vector(7 downto 0):= X"06";
constant NAK : std_logic_vector(7 downto 0):= X"15";
constant STX : std_logic_vector(7 downto 0):= X"02";
constant EOT : std_logic_vector(7 downto 0):= X"04";

type state_type is (tx_idle, tx_count, tx_trigger);
signal state : state_type;

signal bit_count : integer range 0 to BIT_SIZE-1;   -- bit count within the received data word
signal txcnt : integer range 0 to TX_TIME; -- tx counter at the baud rate
signal txcnt_ce   : std_logic;


begin

txcnt_ce <= '1' when ((send_i = '1') and (state = tx_idle))
	or (state = tx_count) else '0';

tx_counter : process(clk_i, nrst_i) begin
if nrst_i = '0' then
	txcnt <= 0;
elsif rising_edge(clk_i) then
	if (txcnt_ce = '1') then
		if (txcnt = TX_TIME) then
			txcnt <= 0;
		else
			txcnt <= txcnt + 1;
		end if;
	end if;
end if;
end process tx_counter;

--------- MOCK TRANSMITTER_FSM ---------
TX_FSM: process(clk_i, nrst_i) begin
if nrst_i = '0' then
	state <= tx_idle;

elsif clk_i'event and clk_i = '1' then
	case state is
	when tx_idle => 
		if send_i = '1' then
			state <= tx_count;
		end if;
	when tx_count => 
		if (txcnt = TX_TIME) then
			state <= tx_trigger;
		end if;
	when tx_trigger => 
		state <= tx_idle;
	when others => 
		state <= tx_idle;
	end case;
end if;
end process;

-- Output functions
busy_o <= txcnt_ce;
trigger_rx_o <= '1' when (state = tx_trigger) 
	and (tx_data_i = ACK or tx_data_i = NAK)
	else '0';

end;
