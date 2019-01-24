--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:29:31 11/15/2018
-- Design Name:   
-- Module Name:   C:/Users/Kevin/Desktop/QBLink/QBLink/QBLink_TB.vhd
-- Project Name:  QBlink
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: QBlink
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY QBLink_TB IS
END QBLink_TB;
 
ARCHITECTURE behavior OF QBLink_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT QBlink
    PORT(
         sstClk : IN  std_logic;
         rst : IN  std_logic;
         rawSerialOut : OUT  std_logic;
         rawSerialIn : IN  std_logic;
         localWordIn : IN  std_logic_vector(31 downto 0);
         localWordInValid : IN  std_logic;
         localWordOut : OUT  std_logic_vector(31 downto 0);
         localWordOutValid : OUT  std_logic;
         localWordOutReq : IN  std_logic;
         trgLinkSynced : OUT  std_logic;
         serialClkLocked : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal sstClk : std_logic := '0';
   signal rst : std_logic := '0';
   signal rawSerialIn : std_logic := '0';
   signal localWordIn : std_logic_vector(31 downto 0) := (others => '0');
   signal localWordInValid : std_logic := '0';
   signal localWordOutReq : std_logic := '0';

 	--Outputs
   signal rawSerialOut : std_logic;
   signal localWordOut : std_logic_vector(31 downto 0);
   signal localWordOutValid : std_logic;
   signal trgLinkSynced : std_logic;
   signal serialClkLocked : std_logic;
	
	--training partner:
	signal Trst : std_logic :='0';
	signal TlocalWordIn : std_logic_vector(31 downto 0):= (others => '0');
	signal TlocalWordInValid : std_logic := '0';
   signal TlocalWordOutValid : std_logic;
   signal TlocalWordOutReq : std_logic := '0';
   signal TtrgLinkSynced : std_logic;
   signal TserialClkLocked : std_logic;
	signal TtargetReg : std_logic_vector(31 downto 0) := (others => '0');
	signal TregCnt : integer := 0;
   -- Clock period definitions
   constant sstClk_period : time := 40 ns; --25 MHz clock
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: QBlink PORT MAP (
          sstClk => sstClk,
          rst => rst,
          rawSerialOut => rawSerialOut,
          rawSerialIn => rawSerialIn,
          localWordIn => localWordIn,
          localWordInValid => localWordInValid,
          localWordOut => localWordOut,
          localWordOutValid => localWordOutValid,
          localWordOutReq => localWordOutReq,
          trgLinkSynced => trgLinkSynced,
          serialClkLocked => serialClkLocked
        );
	trainpart_QBLINK: QBlink PORT MAP(
			 sstClk => sstClk,
          rst => Trst,
          rawSerialOut => rawSerialIn, --connect the serial input of uut to training partner output
          rawSerialIn => rawserialOut, --connect the serial output of the uut to training partner input
          localWordIn => TlocalWordIn, -- testbench will load Ttargetreg onto training partner wordIn
          localWordInValid => TlocalWordInValid, --testbench enables listening to word inputs
          localWordOut => Ttargetreg, --feed collected command from uut to testbench register
          localWordOutValid => TlocalWordOutValid,   
          localWordOutReq => TlocalWordOutReq,
          trgLinkSynced => TtrgLinkSynced,
          serialClkLocked => TserialClkLocked
	);

   -- Clock process definitions
   sstClk_process :process
   begin
		sstClk <= '0';
		wait for sstClk_period/2;
		sstClk <= '1';
		wait for sstClk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for sstClk_period*10;
		wait on trgLinkSynced;
	---	wait until sstClk'event and sstClk = '1';
      localWordIn <= x"DEADBEEF";
		localWordInValid <= '0';
		--wait until sstClk'event and sstClk = '1';
		localWordInValid <= '1';
		TlocalWordOutReq <= '1';
		wait on Ttargetreg;
		TlocalWordIn <= Ttargetreg;
		--wait until sstClk'event and sstClk = '1';
		TlocalWordInValid <= '1';
		localWordOutReq <= '1';
		wait;
		
   end process;

END;
