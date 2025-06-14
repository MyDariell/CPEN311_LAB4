library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ksa is
  port(
    CLOCK_50            : in  std_logic;  -- Clock pin
    KEY                 : in  std_logic_vector(3 downto 0);  -- push button switches
    SW                 : in  std_logic_vector(9 downto 0);  -- slider switches
    LEDR : out std_logic_vector(9 downto 0);  -- red lights
    HEX0 : out std_logic_vector(6 downto 0);
    HEX1 : out std_logic_vector(6 downto 0);
    HEX2 : out std_logic_vector(6 downto 0);
    HEX3 : out std_logic_vector(6 downto 0);
    HEX4 : out std_logic_vector(6 downto 0);
    HEX5 : out std_logic_vector(6 downto 0));
end ksa;

architecture rtl of ksa is

    -- clock and reset signals  
    signal start                : std_logic;
	signal clk, reset_n         : std_logic;

    signal address_s              : STD_LOGIC_VECTOR (7 downto 0);    --address passed into s_memory
    signal data_in_s              : STD_LOGIC_VECTOR (7 downto 0);    --data passed into s_memory 
    signal wren_s                 : std_logic;                        --wren passed into s_memory 
    
    signal address_d              : STD_LOGIC_VECTOR (7 downto 0);    --address passed into d_memory
    signal data_in_d              : STD_LOGIC_VECTOR (7 downto 0);    --data passed into d_memory 
    signal wren_d                 : std_logic;                        --wren passed into d_memory 
    
    signal address_e              : STD_LOGIC_VECTOR (7 downto 0);    --address passed into e_memory
    

    signal start_a              : std_logic;                        --output from Main_controller
    signal start_b              : std_logic;                        --output from Main_controller
    signal start_c              : std_logic;                        --output from Main_controller

    signal address_out_a        : STD_LOGIC_VECTOR (7 downto 0);    --output address from DecryptLoopA for sram 
    signal address_out_b        : STD_LOGIC_VECTOR (7 downto 0);    --output address from DecryptLoopB for sram
    signal address_out_c_s        : STD_LOGIC_VECTOR (7 downto 0);    --output address of sram from DecryptLoopC 
    signal address_out_c_d        : STD_LOGIC_VECTOR (7 downto 0);    --output address of dram from DecryptLoopC   
    signal address_out_c_e        : STD_LOGIC_VECTOR (7 downto 0);    --output address of erom from DecryptLoopC  
    
    signal loop_A_finished      : std_logic;                        --output finished from DecryptLoopA
    signal loop_B_finished      : std_logic;                        --output finished from DecryptLoopB
    signal loop_C_finished      : std_logic;                        --output finished from DecryptLoopC

    signal loop_A_finished_pulse: std_logic;                        --finished pulse from edge detect for A
    signal loop_B_finished_pulse: std_logic;                        --finished pulse from edge detect for B
    signal loop_C_finished_pulse: std_logic;                        --finished pulse from edge detect for B

    signal data_in_b              : STD_LOGIC_VECTOR (7 downto 0);    --input data from sram into DecryptLoopB
    signal data_in_c_s            : STD_LOGIC_VECTOR (7 downto 0);    --input data from sram into DecryptLoopC
    signal data_in_c_d            : STD_LOGIC_VECTOR (7 downto 0);    --input data from dram into DecryptLoopC
    signal data_in_c_e            : STD_LOGIC_VECTOR (7 downto 0);    --input data from erom into DecryptLoopC

    signal data_out_a           : STD_LOGIC_VECTOR (7 downto 0);    --output data from DecryptLoopA
    signal data_out_b           : STD_LOGIC_VECTOR (7 downto 0);    --output data from DecryptLoopB
    signal data_out_c_s           : STD_LOGIC_VECTOR (7 downto 0);    --output data from DecryptLoopC for sram 
    signal data_out_c_d           : STD_LOGIC_VECTOR (7 downto 0);    --output data from DecryptLoopB for dram 

    signal secret_key           : STD_LOGIC_VECTOR (23 downto 0);

    signal wren_a               :STD_LOGIC;                         --output wren from DecryptLoopA
    signal wren_b               :STD_LOGIC;                         --output wren from DecryptLoopB
    signal wren_c_s               :STD_LOGIC;                         --output wren from DecryptLoopC for s
    signal wren_c_d               :STD_LOGIC;                         --output wren from DecryptLoopC for d 

    signal sram_out              :STD_LOGIC_VECTOR (7 downto 0);     --output data from s_ram 
    signal dram_out              :STD_LOGIC_VECTOR (7 downto 0);     --output data from d_ram 
    signal erom_out              :STD_LOGIC_VECTOR (7 downto 0);     --output data from e_rom 

	COMPONENT SevenSegmentDisplayDecoder IS
    PORT
    (
        ssOut : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        nIn : IN STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
    END COMPONENT;

    --============================================ Memory Modules =====================================================================
    --S RAM 
    COMPONENT s_memory IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
    END COMPONENT;

    --Decrypted Key RAM
    component d_memory --Not yet instantiated -----------------------
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
    end component;

    --Encrypted Key ROM
    component rom --Not yet instantiated -----------------------
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
    end component;

--============================================ Main Controller =====================================================================

component main_controller
    port (
        clk                : in  std_logic;
        start              : in  std_logic;
        reset              : in  std_logic;
        mem_in_s           : in  std_logic_vector(7 downto 0);
        mem_in_e           : in  std_logic_vector(7 downto 0);
        mem_in_d           : in  std_logic_vector(7 downto 0);
        input_data_a       : in  std_logic_vector(7 downto 0);
        input_data_b       : in  std_logic_vector(7 downto 0);
        input_data_c_d     : in  std_logic_vector(7 downto 0);
        input_data_c_s     : in  std_logic_vector(7 downto 0);
        input_address_a    : in  std_logic_vector(7 downto 0);
        input_address_b    : in  std_logic_vector(7 downto 0);
        input_address_c_e  : in  std_logic_vector(7 downto 0);
        input_address_c_d  : in  std_logic_vector(7 downto 0);
        input_address_c_s  : in  std_logic_vector(7 downto 0);
        finished_a         : in  std_logic;
        finished_b         : in  std_logic;
        finished_c         : in  std_logic;
        wren_a             : in  std_logic;
        wren_b             : in  std_logic;
        wren_c_d           : in  std_logic;
        wren_c_s           : in  std_logic;
        address_out_d      : out std_logic_vector(7 downto 0);
        address_out_e      : out std_logic_vector(7 downto 0);
        address_out_s      : out std_logic_vector(7 downto 0);
        data_out_s         : out std_logic_vector(7 downto 0);
        data_out_d         : out std_logic_vector(7 downto 0);
        wren_s             : out std_logic;
        wren_d             : out std_logic;
        received_data_b    : out std_logic_vector(7 downto 0);
        received_data_c_e  : out std_logic_vector(7 downto 0);
        received_data_c_s  : out std_logic_vector(7 downto 0);
        start_a            : out std_logic;
        start_b            : out std_logic;
        start_c            : out std_logic
    );
end component;


--============================================ Decrypt Loops =====================================================================
	COMPONENT DecryptLoopA IS 
	PORT 
	(
        clock       : IN STD_LOGIC;
        reset       : IN STD_LOGIC; 
        start       : IN STD_LOGIC; 
        wren        : OUT STD_LOGIC;
        address     : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        data        : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        finished    : OUT STD_LOGIC
	);
	END COMPONENT; 


    COMPONENT DecryptLoopB IS
    PORT (
        clk         : IN  STD_LOGIC;
        start       : IN  STD_LOGIC;
        data_in     : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
        secret_key  : IN  STD_LOGIC_VECTOR (23 DOWNTO 0);
        wren        : OUT STD_LOGIC;
        data_out    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        finish      : OUT STD_LOGIC;
        address     : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
    END COMPONENT;

    component DecryptLoopC
    port (
        clk        : in  std_logic;
        start      : in  std_logic;
        data_in_S  : in  std_logic_vector(7 downto 0);
        data_in_E  : in  std_logic_vector(7 downto 0);
        wren_d     : out std_logic;
        wren_s     : out std_logic;
        finished   : out std_logic;
        address_E  : out std_logic_vector(7 downto 0);
        address_D  : out std_logic_vector(7 downto 0);
        address_S  : out std_logic_vector(7 downto 0);
        data_D     : out std_logic_vector(7 downto 0);
        data_S     : out std_logic_vector(7 downto 0)
    );
end component;


   COMPONENT edge_detector IS 
    PORT 
    (
        async_sig       :   IN STD_LOGIC;
        outclk          :   IN STD_LOGIC;
        out_sync_sig    :   OUT STD_LOGIC
    );
    END COMPONENT;


begin
    clk <= CLOCK_50;
    reset_n <= NOT KEY(1);
    start <= NOT KEY(0);
    

    secret_key (23 DOWNTO 0) <= "000000000000001001001001"; -- set upper bits to be 0 -- for task 2 
    
    --secret_key[0] = 0x0
    --secret_key[1] = 0x2
    --secret_key[ 2] = 0x49
	--00000000 00000010 01001001


    s_memory_inst: s_memory   
            port map (
                address => address_s,
                clock   => clk,
                data    => data_in_s, 
                wren    => wren_s,
                q       => sram_out 
            );

    d_memory_inst: d_memory
            port map (
                address => address_d,
                clock   => clk,
                data    => data_in_d,
                wren    => wren_d,
                q       => dram_out
            );

    rom_inst: rom
            port map (
                address =>  address_e,
                clock   =>  clk,
                q       =>  erom_out
            );

    u_DecryptLoopA: DecryptLoopA 
            port map (
                clock       => clk,
                start       => start_a,
                reset       => '0', --open 
                wren        => wren_a,
                address     => address_out_a,
                data        => data_out_a, 
                finished    => loop_A_finished
            );
    
    u_DecryptLoopB : DecryptLoopB
    PORT MAP (
        clk         => clk,
        start       => start_b,
        data_in     => data_in_b,
        secret_key  => secret_key,
        wren        => wren_b,
        data_out    => data_out_b,
        finish      => loop_B_finished,
        address     => address_out_b
    );

    U_DecryptLoopC : DecryptLoopC
    port map (
        clk        => clk,
        start      => start_c,
        data_in_S  => data_in_c_s,
        data_in_E  => data_in_c_e,
        wren_d     => wren_c_d,
        wren_s     => wren_c_s,
        finished   => loop_C_finished,
        address_E  => address_out_c_e,
        address_D  => address_out_c_d,
        address_S  => address_out_c_s,
        data_D     => data_out_c_d,
        data_S     => data_out_c_s
    );


    finished_a_edge: edge_detector 
            port map (
                async_sig       => loop_A_finished, 
                outclk          => clk,
                out_sync_sig    => loop_A_finished_pulse 
            );

    finished_b_edge: edge_detector 
            port map (
                async_sig       => loop_B_finished, 
                outclk          => clk,
                out_sync_sig    => loop_B_finished_pulse
            );
    
    finished_c_edge: edge_detector 
            port map (
                async_sig       => loop_C_finished, 
                outclk          => clk,
                out_sync_sig    => loop_C_finished_pulse
            );

    -- main_controller_inst : main_controller
    --         PORT MAP (
    --             clk             => clk,
    --             start           => start,
    --             reset           => '0',
    --             mem_in          => ram_out,
    --             input_data_a    => data_out_a,
    --             input_data_b    => data_out_b,
    --             input_data_c    => (others => '0'),
    --             input_address_a => address_out_a,
    --             input_address_b => address_out_b,
    --             input_address_c => (others => '0'),
    --             finished_a      => loop_A_finished_pulse,
    --             finished_b      => loop_B_finished_pulse,
    --             finished_c      => '0',
    --             wren_a          => wren_a,
    --             wren_b          => wren_b,
    --             wren_c          => wren_c,
    --             address_out     => address_s,
    --             data_out        => data_in,
    --             wren_out        => wren,
    --             received_data_b => data_in_b,
    --             start_a         => start_a,
    --             start_b         => start_b,
    --             start_c         => open
    --         );

    U_main_controller : main_controller
    port map (
        clk               => clk,
        start             => start,
        reset             => reset_n,
        mem_in_s          => sram_out,
        mem_in_e          => erom_out,
        mem_in_d          => dram_out,
        input_data_a      => data_out_a,
        input_data_b      => data_out_b,
        input_data_c_d    => data_out_c_d,
        input_data_c_s    => data_out_c_s,
        input_address_a   => address_out_a,
        input_address_b   => address_out_b,
        input_address_c_e => address_out_c_e,
        input_address_c_d => address_out_c_d,
        input_address_c_s => address_out_c_s,
        finished_a        => loop_A_finished_pulse,
        finished_b        => loop_B_finished_pulse,
        finished_c        => loop_C_finished_pulse,
        wren_a            => wren_a,
        wren_b            => wren_b,
        wren_c_d          => wren_c_d,
        wren_c_s          => wren_c_s,
        address_out_d     => address_d,
        address_out_e     => address_e,
        address_out_s     => address_s,
        data_out_s        => data_in_s,
        data_out_d        => data_in_d,
        wren_s            => wren_s,
        wren_d            => wren_d,
        received_data_b   => data_in_b,
        received_data_c_e => data_in_c_e,
        received_data_c_s => data_in_c_s,
        start_a           => start_a,
        start_b           => start_b,
        start_c           => start_c
    );

end RTL;


