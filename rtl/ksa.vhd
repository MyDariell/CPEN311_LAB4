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
    signal address              : STD_LOGIC_VECTOR (7 downto 0);    --address passed into s_memory
    signal data_in              : STD_LOGIC_VECTOR (7 downto 0);    --data passed into s_memory 
    signal wren                 : std_logic;                        --wren passed into s_memory 
    
    signal start_a              : std_logic;                        --output from Main_controller
    signal start_b              : std_logic;                        --output from Main_controller

    signal address_out_a        : STD_LOGIC_VECTOR (7 downto 0);    --output address from DecryptLoopA
    signal address_out_b        : STD_LOGIC_VECTOR (7 downto 0);    --output address from DecryptLoopB
    
    signal loop_A_finished      : std_logic;                        --output finished from DecryptLoopA
    signal loop_B_finished      : std_logic;                        --output finished from DecryptLoopA

    signal loop_A_finished_pulse: std_logic;                        --finished pulse from edge detect for A
    signal loop_B_finished_pulse: std_logic;                        --finished pulse from edge detect for B

    signal data_in_b            : STD_LOGIC_VECTOR (7 downto 0);    --input data into DecryptLoopB

    signal data_out_a           : STD_LOGIC_VECTOR (7 downto 0);    --output data from DecryptLoopA
    signal data_out_b           : STD_LOGIC_VECTOR (7 downto 0);    --output data from DecryptLoopB

    signal secret_key           : STD_LOGIC_VECTOR (23 downto 0);

    signal wren_a               :STD_LOGIC;                         --output wren from DecryptLoopA
    signal wren_b               :STD_LOGIC;                         --output wren from DecryptLoopB
    signal wren_c               :STD_LOGIC;                         --output wren from DecryptLoopC

    signal ram_out              :STD_LOGIC_VECTOR (7 downto 0);     --output data from s_ram 


	COMPONENT SevenSegmentDisplayDecoder IS
    PORT
    (
        ssOut : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        nIn : IN STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
    END COMPONENT;

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

    COMPONENT edge_detector IS 
    PORT 
    (
        async_sig       :   IN STD_LOGIC;
        outclk          :   IN STD_LOGIC;
        out_sync_sig    :   OUT STD_LOGIC
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

    COMPONENT main_controller IS
    PORT (
        clk             : IN  STD_LOGIC;
        start           : IN  STD_LOGIC;
        reset           : IN  STD_LOGIC;
        mem_in          : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
        input_data_a    : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
        input_data_b    : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
        input_data_c    : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
        input_address_a : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
        input_address_b : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
        input_address_c : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
        finished_a      : IN  STD_LOGIC;
        finished_b      : IN  STD_LOGIC;
        finished_c      : IN  STD_LOGIC;
        wren_a          : IN  STD_LOGIC;
        wren_b          : IN  STD_LOGIC;
        wren_c          : IN  STD_LOGIC;

        address_out     : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        data_out        : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        wren_out        : OUT STD_LOGIC;
        received_data_b : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        start_a         : OUT STD_LOGIC;
        start_b         : OUT STD_LOGIC;
        start_c         : OUT STD_LOGIC
    );
    END COMPONENT;



begin
    clk <= CLOCK_50;
    reset_n <= KEY(3);
    start <= '1';

    secret_key (23 DOWNTO 0) <= "000000000000001001001001"; -- set upper bits to be 0 -- for task 2 
    
    --secret_key[0] = 0x0
    --secret_key[1] = 0x2
    --secret_key[ 2] = 0x49
	--00000000 00000010 01001001


    s_memory_inst: s_memory   
            port map (
                address => address,
                clock   => clk,
                data    => data_in, 
                wren    => wren,
                q       => ram_out 
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

    main_controller_inst : main_controller
            PORT MAP (
                clk             => clk,
                start           => start,
                reset           => '0',
                mem_in          => ram_out,
                input_data_a    => data_out_a,
                input_data_b    => data_out_b,
                input_data_c    => (others => '0'),
                input_address_a => address_out_a,
                input_address_b => address_out_b,
                input_address_c => (others => '0'),
                finished_a      => loop_A_finished_pulse,
                finished_b      => loop_B_finished_pulse,
                finished_c      => '0',
                wren_a          => wren_a,
                wren_b          => wren_b,
                wren_c          => wren_c,
                address_out     => address,
                data_out        => data_in,
                wren_out        => wren,
                received_data_b => data_in_b,
                start_a         => start_a,
                start_b         => start_b,
                start_c         => open
            );


end RTL;


