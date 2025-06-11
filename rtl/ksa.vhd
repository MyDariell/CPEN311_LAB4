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
	signal clk, reset_n : std_logic;
    signal address      : STD_LOGIC_VECTOR (7 downto 0);
    signal data_in      : STD_LOGIC_VECTOR (7 downto 0);
    signal wren         : std_logic; 
    signal ram_initializer_finished : std_logic; 

    signal secret_key   : STD_LOGIC_VECTOR (23 downto 0);



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
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
    END COMPONENT;

	COMPONENT RamInitializer IS 
	PORT 
	(
        clock       : IN STD_LOGIC;
        reset       : IN STD_LOGIC; 
        wren        : OUT STD_LOGIC;
        address     : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        data        : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        finished    : OUT STD_LOGIC
	);
	END COMPONENT; 


begin
    clk <= CLOCK_50;
    reset_n <= KEY(3);

    secret_key (23 DOWNTO 10) <= (others => '0'); -- set upper bits to be 0 -- for task 2 
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
                q       => open 
            );
    
    RamInitializer_inst: RamInitializer 
            port map (
                clock       => clk,
                reset       => '0', --open 
                wren        => wren,
                address     => address,
                data        => data_in, 
                finished    => ram_initializer_finished
            );

end RTL;


