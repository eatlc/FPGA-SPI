library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity tb_spi_master is
generic (
	c_clkfreq 		: integer := 100_000_000;
	c_sclkfreq 		: integer := 1_000_000;
	c_cpol			: std_logic := '0';
	c_cpha			: std_logic := '0'
);
end tb_spi_master;

architecture Behavioral of tb_spi_master is



component spi_master is
generic (
	c_clkfreq 		: integer := 100_000_000;
	c_sclkfreq 		: integer := 1_000_000;
	c_cpol			: std_logic := '0';
	c_cpha			: std_logic := '0'
);
Port ( 
	clk_i 			: in  std_logic;
	en_i 			: in  std_logic;
	mosi_data_i 	: in  std_logic_vector (7 downto 0);
	miso_data_o 	: out std_logic_vector (7 downto 0);
	data_ready_o 	: out std_logic;
	cs_o 			: out std_logic;
	sclk_o 			: out std_logic;
	mosi_o 			: out std_logic;
	miso_i 			: in  std_logic
);
end component;

--Signal-----------------------------------
signal 	clk_i 			: std_logic:='0';
signal 	en_i 			: std_logic:='0';
signal 	mosi_data_i 	: std_logic_vector (7 downto 0):=(others=>'0');
signal 	miso_data_o 	: std_logic_vector (7 downto 0);
signal 	data_ready_o 	: std_logic;
signal 	cs_o 			: std_logic;
signal 	sclk_o 			: std_logic;
signal 	mosi_o 			: std_logic;
signal 	miso_i 			: std_logic:='0';

constant clk_i_period 	: time := 10 ns;
constant sckPeriod 		: time := 1000 ns;
 
signal SPISIGNAL 		: std_logic_vector(7 downto 0) := (others => '0');
signal spiWrite 		: std_logic := '0';
signal spiWriteDone 	: std_logic := '0';   



---------------------------------------------------

begin
inst_spi: spi_master
generic map(
	c_clkfreq 		=> c_clkfreq    ,
	c_sclkfreq 		=> c_sclkfreq   ,
	c_cpol			=> c_cpol		,
	c_cpha			=> c_cpha		
)
Port map( 
	clk_i 			=> clk_i 		       ,
	en_i 			=> en_i 		       ,
	mosi_data_i 	=> mosi_data_i         ,
	miso_data_o 	=> miso_data_o         ,
	data_ready_o 	=> data_ready_o        ,
	cs_o 			=> cs_o 		       ,
	sclk_o 			=> sclk_o 		       ,
	mosi_o 			=> mosi_o 		       ,
	miso_i 			=> miso_i 		
);


clk_i_process :process
begin
	clk_i <= '0';
	wait for clk_i_period/2;
	clk_i <= '1';
	wait for clk_i_period/2;
end process;



SPIWRITE_P: process begin

	wait until rising_edge(spiWrite);

		-- for cpol = 1 cpha = 1
	-- for cpol = 0 cpha = 0
 
	miso_i <= SPISIGNAL(7);
	wait until falling_edge(sclk_o);
	miso_i <= SPISIGNAL(6);
	wait until falling_edge(sclk_o);
	miso_i <= SPISIGNAL(5);
	wait until falling_edge(sclk_o);
	miso_i <= SPISIGNAL(4);
	wait until falling_edge(sclk_o);
	miso_i <= SPISIGNAL(3);
	wait until falling_edge(sclk_o);
	miso_i <= SPISIGNAL(2);
	wait until falling_edge(sclk_o);
	miso_i <= SPISIGNAL(1);
	wait until falling_edge(sclk_o);
	miso_i <= SPISIGNAL(0);

	spiWriteDone    <= '1';
	wait for 1 ps;
	spiWriteDone    <= '0';

end process;


stim_proc: process
begin		
  -- hold reset state for 100 ns.
  wait for 100 ns;	
 
  wait for clk_i_period*10;
 
  -- insert stimulus here 
 
----------------------------------------------------------------
--	-- CPOL,CPHA = 00
	en_i 		<= '1';  
 
	-- write 0xA7, read 0xB2
	mosi_data_i	<= x"A7";
	wait until falling_edge(cs_o);
	SPISIGNAL <= x"B2";
	spiWrite    <= '1';
	wait until rising_edge(spiWriteDone);
	spiWrite    <= '0';
 
	-- write 0xB8, read 0xC3
	wait until rising_edge(data_ready_o);
	mosi_data_i	<= x"B8";	
	wait until falling_edge(sclk_o);
	SPISIGNAL <= x"C3";
	spiWrite    <= '1';
	wait until rising_edge(spiWriteDone);
	spiWrite    <= '0';
	en_i 		<= '0';  

 
	wait for sckPeriod*4;
 
	assert false
	report "SIM DONE"
	severity failure;
	
end process;

end Behavioral;
