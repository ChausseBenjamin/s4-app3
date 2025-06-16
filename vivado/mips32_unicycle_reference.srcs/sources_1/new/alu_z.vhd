----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/16/2025 02:41:37 PM
-- Design Name: 
-- Module Name: alu_z - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu_z is
    Port ( i_a : in STD_LOGIC_VECTOR (127 downto 0);
           i_b : in STD_LOGIC_VECTOR (127 downto 0);
           i_alu_funct : in STD_LOGIC_VECTOR (3 downto 0);
           i_shamt : in STD_LOGIC_VECTOR (4 downto 0);
           o_result : out STD_LOGIC_VECTOR (127 downto 0);
           o_multRes : out STD_LOGIC_VECTOR (255 downto 0);
           o_zero : out STD_LOGIC_VECTOR (3 downto 0));     -- Necessaire car chaque ALU peut sortire 1 bit o_zero. 
end alu_z;

architecture Behavioral of alu_z is

	component alu is
	Port ( 
		i_a			: in std_logic_vector (31 downto 0);
		i_b			: in std_logic_vector (31 downto 0);
		i_alu_funct	: in std_logic_vector (3 downto 0);
		i_shamt		: in std_logic_vector (4 downto 0);
		o_result	: out std_logic_vector (31 downto 0);
	    o_multRes    : out std_logic_vector (63 downto 0);
		o_zero		: out std_logic
		);
	end component;

begin

    alu_msb : alu
        port map (
            i_a         => i_a(127 downto 96),
            i_b         => i_b(127 downto 96),
            o_result    => o_result(127 downto 96),
            o_multRes   => o_multRes(255 downto 192),
            o_zero      => o_zero(3),
            
            i_alu_funct => i_alu_funct,
            i_shamt     => i_shamt
        );
        
    alu_2 : alu
        port map (
            i_a         => i_a(95 downto 64),
            i_b         => i_b(95 downto 64),
            o_result    => o_result(95 downto 64),
            o_multRes   => o_multRes(191 downto 128),
            o_zero      => o_zero(2),
            
            i_alu_funct => i_alu_funct,
            i_shamt     => i_shamt
        );
        
    alu_1 : alu
        port map (
            i_a         => i_a(63 downto 32),
            i_b         => i_b(63 downto 32),
            o_result    => o_result(63 downto 32),
            o_multRes   => o_multRes(127 downto 64),
            o_zero      => o_zero(1),
            
            i_alu_funct => i_alu_funct,
            i_shamt     => i_shamt
        );
        
    alu_lsb : alu
        port map (
            i_a         => i_a(31 downto 0),
            i_b         => i_b(31 downto 0),
            o_result    => o_result(31 downto 0),
            o_multRes   => o_multRes(63 downto 0),
            o_zero      => o_zero(0),
            
            i_alu_funct => i_alu_funct,
            i_shamt     => i_shamt
        );


end Behavioral;
