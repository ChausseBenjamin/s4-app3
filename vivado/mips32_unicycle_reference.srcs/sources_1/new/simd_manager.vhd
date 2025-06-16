----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/16/2025 03:35:51 PM
-- Design Name: 
-- Module Name: simd_manager - Behavioral
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

entity simd_manager is
    Port ( i_reg_data_RS1   : in STD_LOGIC_VECTOR (127 downto 0);
           i_reg_data_RS2   : in STD_LOGIC_VECTOR (127 downto 0);
           i_reg_data_Dest  : in STD_LOGIC_VECTOR (127 downto 0);
           i_opcode         : in STD_LOGIC_VECTOR (5 downto 0);
           i_alu_funct      : in STD_LOGIC_VECTOR (3 downto 0);
           i_shamt          : in STD_LOGIC_VECTOR (4 downto 0);
           i_enable         : in STD_LOGIC;
           o_result_is_word : out STD_LOGIC;
           o_result         : out STD_LOGIC_VECTOR (127 downto 0);
           o_multRes        : out STD_LOGIC_VECTOR (255 downto 0));
end simd_manager;

architecture Behavioral of simd_manager is

begin


end Behavioral;
