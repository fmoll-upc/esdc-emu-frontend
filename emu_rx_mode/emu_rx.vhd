--Emulator of RX mode environment 
--Author: F. Moll
--Version 0.9 1/11/2026

library ieee;
use ieee.std_logic_1164.all;

entity emu_rx is
generic(
	MAX_CNT : integer range 0 to 7 := 3;
	BIT_SIZE : integer := 8);

port( clk_i, nrst_i : in std_logic;
	   -- controller inputs
	   rx_on_i   : in std_logic;
	   finish_i   : in std_logic;
	   -- transceiver inputs
	   send_i   : in std_logic;
	   read_clear_i   : in std_logic;
	   -- timer inputs
	   start_i   : in std_logic;
	   stop_i   : in std_logic;
	   -- queue inputs
	   wr_req_i   : in std_logic;
	   save_point_i   : in std_logic;
	   rest_point_i   : in std_logic;
	   -- data to send selection
	   sel_data_i   : in std_logic_vector(1 downto 0);
	   -- transceiver outputs
	   rx_busy_o : out std_logic;
	   tx_busy_o : out std_logic;
	   rx_new_o : out std_logic;
	   byte_rcvd_o : out std_logic_vector(BIT_SIZE-1 downto 0);  
	   -- timer output
	   timeout_o : out std_logic;
	   -- to send data (debug)
	   data_send_o : out std_logic_vector(BIT_SIZE-1 downto 0); 
	   -- queue input data (debug)
	   ptr_o : out integer range 0 to 15
);
end emu_rx;

architecture main of emu_rx is

constant ACK : std_logic_vector(7 downto 0):= X"06";
constant NAK : std_logic_vector(7 downto 0):= X"15";
constant STX : std_logic_vector(7 downto 0):= X"02";
constant EOT : std_logic_vector(7 downto 0):= X"04";

signal data_sel :  std_logic_vector(BIT_SIZE-1 downto 0);
signal data_queue :  std_logic_vector(BIT_SIZE-1 downto 0);
signal trigger_rx : std_logic;
signal trigger_rx_int : std_logic;

-- corresponding to mock_tx_module.vhd entity
component mock_tx_module_rx is
	generic(TX_TIME : integer range 0 to 31 := 15;
		BIT_SIZE : integer := 8);
	port(clk_i, nrst_i : in std_logic;
	   tx_data_i : in std_logic_vector(BIT_SIZE-1 downto 0);  
	   send_i   : in std_logic;
	   trigger_rx_o : out std_logic;
	   busy_o : out std_logic	
	);
end component mock_tx_module_rx;

-- corresponding to mock_rx_module.vhd entity
component mock_rx_module_rx is
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
end component mock_rx_module_rx;

-- corresponding to mock_s_queue.vhd entity
component mock_r_queue is
	generic(MBITS : integer :=8);
	port(
		clk_i, nrst_i : in std_logic;
		wr_req_i : in std_logic;
		save_point_i : in std_logic;
		rest_point_i : in std_logic;
		ptr_o : out integer range 0 to 15
		--data_o : out std_logic_vector(MBITS-1 downto 0)
	);
end component mock_r_queue;

-- corresponding to timer.vhd entity
component timer is
	generic(TIMEOUT : integer range 0 to 127 := 8);
	port(clk_i, nrst_i : in std_logic;
	   start_i : in std_logic;
	   stop_i : in std_logic;
	   timeout_o  : out std_logic
	);
end component timer;


begin

-- data to send MUX
data_sel <= 
	STX when sel_data_i = "00" else
	data_queue when sel_data_i = "01" else
	ACK when sel_data_i = "10" else
	NAK when sel_data_i = "11" else
	NAK; -- default case

tx_inst: mock_tx_module_rx 
	generic map(
		TX_TIME => 15,
		BIT_SIZE => BIT_SIZE
	)
	port map (
		clk_i => clk_i, nrst_i => nrst_i, 
		tx_data_i => data_sel,
		send_i => send_i,
		trigger_rx_o => trigger_rx_int,
		busy_o => tx_busy_o
	);
-- reception mode activated by rx_on_i OR TX trigger
trigger_rx <= '1' when (rx_on_i = '1' or (trigger_rx_int = '1' and finish_i='0') 
	or (wr_req_i = '1' and byte_rcvd_o /= EOT)) else '0';

rx_inst: mock_rx_module_rx 
	generic map(
		RX_DELAY => 4,
		RX_TIME => 15,
		BIT_SIZE => BIT_SIZE
	)
	port map (
		clk_i => clk_i, nrst_i => nrst_i, 
		trigger_rx_i => trigger_rx,
		read_clear_i => read_clear_i,
		rx_data_o => byte_rcvd_o,
		rx_new_o => rx_new_o,
		busy_o => rx_busy_o
	);

queue_inst: mock_r_queue 
	generic map(
		MBITS => BIT_SIZE
	)
	port map (
		clk_i => clk_i, nrst_i => nrst_i, 
		wr_req_i => wr_req_i,
		save_point_i => save_point_i,
		rest_point_i => rest_point_i,
		ptr_o => ptr_o
	);
	
timer_inst: timer 
	generic map(
		TIMEOUT => 26
	)
	port map (
		clk_i => clk_i, nrst_i => nrst_i, 
		start_i => start_i,
		stop_i => stop_i,
		timeout_o => timeout_o
	);

data_send_o <= data_sel;
--data_queue_o <= data_queue;

end architecture main;
