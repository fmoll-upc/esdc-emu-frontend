--Emulator of TX mode environment 
--Author: F. Moll
--Version 0.9 1/11/2026

library ieee;
use ieee.std_logic_1164.all;

entity emu_tx is
generic(
	MAX_CNT : integer range 0 to 7 := 3;
	BIT_SIZE : integer := 8);

port( clk_i, nrst_i : in std_logic;
	   -- transceiver inputs
	   send_i   : in std_logic;
	   read_clear_i   : in std_logic;
	   -- timer inputs
	   start_i   : in std_logic;
	   stop_i   : in std_logic;
	   --counter inputs
	   ce_cnt_i   : in std_logic;
	   cnt_clear_i   : in std_logic;
	   -- queue inputs
	   rd_req_i   : in std_logic;
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
	   -- counter output
	   cnt_o : out integer range 0 to MAX_CNT;
	   -- selected data to send output
	   data_send_o : out std_logic_vector(BIT_SIZE-1 downto 0); 
	   -- queue output data 
	   data_queue_o : out std_logic_vector(BIT_SIZE-1 downto 0)
);
end emu_tx;

architecture main of emu_tx is

constant ACK : std_logic_vector(7 downto 0):= X"06";
constant NAK : std_logic_vector(7 downto 0):= X"15";
constant STX : std_logic_vector(7 downto 0):= X"02";
constant EOT : std_logic_vector(7 downto 0):= X"04";

signal data_sel :  std_logic_vector(BIT_SIZE-1 downto 0);
signal data_queue :  std_logic_vector(BIT_SIZE-1 downto 0);
signal trigger_rx : std_logic;

-- corresponding to mock_tx_module.vhd entity
component mock_tx_module_tx is
	generic(TX_TIME : integer range 0 to 31 := 15;
		BIT_SIZE : integer := 8);
	port(clk_i, nrst_i : in std_logic;
	   tx_data_i : in std_logic_vector(BIT_SIZE-1 downto 0);  
	   send_i   : in std_logic;
	   trigger_rx_o : out std_logic;
	   busy_o : out std_logic	
	);
end component mock_tx_module_tx;

-- corresponding to mock_rx_module.vhd entity
component mock_rx_module_tx is
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
end component mock_rx_module_tx;

-- corresponding to mock_s_queue.vhd entity
component mock_s_queue is
	generic(MBITS : integer :=8);
	port(
		clk_i, nrst_i : in std_logic;
		rd_req_i : in std_logic;
		save_point_i : in std_logic;
		rest_point_i : in std_logic;
		data_o : out std_logic_vector(MBITS-1 downto 0)
	);
end component mock_s_queue;

-- corresponding to timer.vhd entity
component timer is
	generic(TIMEOUT : integer range 0 to 127 := 8);
	port(clk_i, nrst_i : in std_logic;
	   start_i : in std_logic;
	   stop_i : in std_logic;
	   timeout_o  : out std_logic
	);
end component timer;

-- corresponding to error_counter.vhd entity
component error_counter is
	generic(MAX_COUNT : integer range 0 to 7 := 3);
	port(clk_i, nrst_i : in std_logic;
	   ce_i : in std_logic;
	   clear_i : in std_logic;
	   count_o : out integer range 0 to MAX_COUNT
	);
end component error_counter;


begin

-- data to send MUX
data_sel <= 
	STX when sel_data_i = "00" else
	data_queue when sel_data_i = "01" else
	ACK when sel_data_i = "10" else
	NAK when sel_data_i = "11" else
	NAK; -- default case

tx_inst: mock_tx_module_tx 
	generic map(
		TX_TIME => 15,
		BIT_SIZE => BIT_SIZE
	)
	port map (
		clk_i => clk_i, nrst_i => nrst_i, 
		tx_data_i => data_sel,
		send_i => send_i,
		trigger_rx_o => trigger_rx,
		busy_o => tx_busy_o
	);


rx_inst: mock_rx_module_tx 
	generic map(
		RX_DELAY => 4,
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

queue_inst: mock_s_queue 
	generic map(
		MBITS => BIT_SIZE
	)
	port map (
		clk_i => clk_i, nrst_i => nrst_i, 
		rd_req_i => rd_req_i,
		save_point_i => save_point_i,
		rest_point_i => rest_point_i,
		data_o => data_queue
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

cnt_inst: error_counter 
	generic map(
		MAX_COUNT => 2
	)
	port map (
		clk_i => clk_i, nrst_i => nrst_i, 
		ce_i => ce_cnt_i,
		clear_i => cnt_clear_i,
		count_o => cnt_o
	);

data_send_o <= data_sel;
data_queue_o <= data_queue;

end architecture main;
