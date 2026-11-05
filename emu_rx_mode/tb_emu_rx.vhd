library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_emu_rx is
    -- Un testbench no sol tenir ni generics ni ports
end entity tb_emu_rx;

architecture stimulus of tb_emu_rx is

    -- 1. Constants de la simulacio
    constant CLK_PERIOD : time := 20 ns; -- Rellotge de 50 MHz
    constant MAX_CNT    : integer := 3;
    constant BIT_SIZE   : integer := 8;

    -- 2. Senyals d'interconnexió (UUT)
    signal clk_i        : std_logic := '0';
    signal nrst_i       : std_logic := '0';
    
    -- control_main inputs
    signal rx_on_i       : std_logic := '0';
    signal finish_i      : std_logic := '0';
    
    -- Transceiver inputs
    signal send_i       : std_logic := '0';
    signal read_clear_i : std_logic := '0';
    
    -- Timer inputs
    signal start_i      : std_logic := '0';
    signal stop_i       : std_logic := '0';
    
    -- Queue inputs
    signal wr_req_i     : std_logic := '0';
    signal save_point_i : std_logic := '0';
    signal rest_point_i : std_logic := '0';
    
    -- Data selection
    signal sel_data_i   : std_logic_vector(1 downto 0) := "10";
    
    -- Transceiver outputs
    signal rx_busy_o    : std_logic;
    signal tx_busy_o    : std_logic;
    signal rx_new_o     : std_logic;
    signal byte_rcvd_o  : std_logic_vector(BIT_SIZE-1 downto 0);
    
    -- Timer output
    signal timeout_o    : std_logic;
    
    -- Data outputs (debug)
    signal data_send_o  : std_logic_vector(BIT_SIZE-1 downto 0);
    signal ptr_o        : integer range 0 to 15;

    -- Senyal per aturar el generador de rellotge al final de la simulacio
    signal sim_finished : boolean := false;

begin

    -- 3. Instanciacio de la Unitat Sota Test (UUT)
    uut: entity work.emu_rx
        generic map (
            MAX_CNT  => MAX_CNT,
            BIT_SIZE => BIT_SIZE
        )
        port map (
            clk_i        => clk_i,
            nrst_i       => nrst_i,
            rx_on_i        => rx_on_i,
            finish_i     => finish_i,
            send_i       => send_i,
            read_clear_i => read_clear_i,
            start_i      => start_i,
            stop_i       => stop_i,
            wr_req_i     => wr_req_i,
            save_point_i => save_point_i,
            rest_point_i => rest_point_i,
            sel_data_i   => sel_data_i,
            rx_busy_o    => rx_busy_o,
            tx_busy_o    => tx_busy_o,
            rx_new_o     => rx_new_o,
            byte_rcvd_o  => byte_rcvd_o,
            timeout_o    => timeout_o,
            data_send_o  => data_send_o,
            ptr_o        => ptr_o
        );

    -- 4. Generacio del senyal de Rellotge (clk_i)
    clk_process : process
    begin
        while not sim_finished loop
            clk_i <= '0';
            wait for CLK_PERIOD / 2;
            clk_i <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process clk_process;

    -- 5. Proces de Estimuls (Assignacio d'entrades en temps arbitraris)
    stim_proc: process
    begin
        -- --- INICIALITZACIO I RESET ---
        nrst_i <= '0'; -- Reset actiu a nivell baix
        wait for 10 ns;
        nrst_i <= '1'; -- Desactivem el reset
        wait for 10 ns;

        -- Inici 
        rx_on_i <= '1';
        wait for CLK_PERIOD;
        rx_on_i <= '0';

        -- Clear new_read
        wait for 20 * CLK_PERIOD;
        read_clear_i <= '1';
        wait for CLK_PERIOD;
        read_clear_i <= '0';
        
        -- Peticio d'enviament (ACK)
        wait for 2*CLK_PERIOD;
        send_i <= '1';
        wait for CLK_PERIOD;
        send_i <= '0';

        -- Activar temporitzador
        wait for 15 * CLK_PERIOD;
        start_i <= '1';
        --rx_on_i <= '1';
        wait for CLK_PERIOD;
        start_i <= '0';
        --rx_on_i <= '0';
        
        -- Clear new_read stop timer
        wait for 20 * CLK_PERIOD;
        read_clear_i <= '1';
        stop_i <= '1';
        wait for CLK_PERIOD;
        read_clear_i <= '0';
        stop_i <= '0';
        
        -- write new_val
        wait for CLK_PERIOD;
        wr_req_i <= '1';
        start_i <= '1';
        wait for CLK_PERIOD;
        wr_req_i <= '0';
        start_i <= '0';
        
        -- Clear new_read stop timer
        wait for 20 * CLK_PERIOD;
        read_clear_i <= '1';
        stop_i <= '1';
        wait for CLK_PERIOD;
        read_clear_i <= '0';
        stop_i <= '0';
        
        -- write new_val
        wait for CLK_PERIOD;
        wr_req_i <= '1';
        start_i <= '1';
        wait for CLK_PERIOD;
        wr_req_i <= '0';
        start_i <= '0';
        
        -- Clear new_read stop timer
        wait for 20 * CLK_PERIOD;
        read_clear_i <= '1';
        stop_i <= '1';
        wait for CLK_PERIOD;
        read_clear_i <= '0';
        stop_i <= '0';
        
        -- write new_val
        wait for CLK_PERIOD;
        wr_req_i <= '1';
        start_i <= '1';
        wait for CLK_PERIOD;
        wr_req_i <= '0';
        start_i <= '0';
        
        -- Clear new_read stop timer
        wait for 20 * CLK_PERIOD;
        read_clear_i <= '1';
        stop_i <= '1';
        wait for CLK_PERIOD;
        read_clear_i <= '0';
        stop_i <= '0';
        
        -- write new_val
        wait for CLK_PERIOD;
        wr_req_i <= '1';
        start_i <= '1';
        wait for CLK_PERIOD;
        wr_req_i <= '0';
        start_i <= '0';
        
        -- Clear new_read stop timer
        wait for 20 * CLK_PERIOD;
        read_clear_i <= '1';
        stop_i <= '1';
        wait for CLK_PERIOD;
        read_clear_i <= '0';
        stop_i <= '0';
        
        -- write new_val
        wait for CLK_PERIOD;
        wr_req_i <= '1';
        start_i <= '1';
        wait for CLK_PERIOD;
        wr_req_i <= '0';
        start_i <= '0';
        
        -- Clear new_read stop timer
        wait for 20 * CLK_PERIOD;
        read_clear_i <= '1';
        stop_i <= '1';
        wait for CLK_PERIOD;
        read_clear_i <= '0';
        stop_i <= '0';
        
        -- write new_val start timer
        wait for CLK_PERIOD;
        wr_req_i <= '1';
        start_i <= '1';
        wait for CLK_PERIOD;
        wr_req_i <= '0';
        start_i <= '0';
        
        -- Clear new_read stop timer
        wait for 20 * CLK_PERIOD;
        read_clear_i <= '1';
        stop_i <= '1';
        wait for CLK_PERIOD;
        read_clear_i <= '0';
        stop_i <= '0';
        
        -- write new_val start timer
        wait for CLK_PERIOD;
        wr_req_i <= '1';
        start_i <= '1';
        wait for CLK_PERIOD;
        wr_req_i <= '0';
        start_i <= '0';
        
        -- Clear new_read stop timer
        wait for 20 * CLK_PERIOD;
        read_clear_i <= '1';
        stop_i <= '1';
        wait for CLK_PERIOD;
        read_clear_i <= '0';
        stop_i <= '0';

        -- write new_val 
        wait for CLK_PERIOD;
        wr_req_i <= '1';
        wait for CLK_PERIOD;
        wr_req_i <= '0';

        -- Peticio d'enviament (ACK)
        wait for 2*CLK_PERIOD;
        send_i <= '1';
        wait for CLK_PERIOD;
        send_i <= '0';

        -- Final de proces
        wait for 15*CLK_PERIOD;
        finish_i <= '1';
        wait for CLK_PERIOD;
        finish_i <= '0';

        
        -- --- FINAL DE LA SIMULACIO ---
        wait for 400 ns;
        sim_finished <= true; -- Atura la generacio del rellotge
        assert false report "Simulacio finalitzada correctament." severity note;
        wait;
    end process stim_proc;

end architecture stimulus;
