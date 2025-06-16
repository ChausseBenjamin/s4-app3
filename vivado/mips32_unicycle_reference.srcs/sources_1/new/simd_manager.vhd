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
    Port ( i_reg_data_RS1   : in STD_LOGIC_VECTOR (127 downto 0);   -- rs lu du banc de registre
           i_reg_data_RS2   : in STD_LOGIC_VECTOR (127 downto 0);   -- rt lu du banc de registre
           i_reg_data_Dest  : in STD_LOGIC_VECTOR (127 downto 0);   -- registre de destination, lu du banc de registre.
           i_opcode         : in STD_LOGIC_VECTOR (5 downto 0);     -- Opcode, pour savoir les instructions simd.
           i_alu_funct      : in STD_LOGIC_VECTOR (3 downto 0);     -- Utiliser lorsque opcode = v_type. Pour que l'ALU parallel sache quoi faire.
           i_shamt          : in STD_LOGIC_VECTOR (4 downto 0);     -- Passer directement a ALU.
           i_enable         : in STD_LOGIC;                         -- Enables le process SIMD. si false. Enabled lorsqu'un instruction simd est detecte par le controlleur
           o_result_is_word : out STD_LOGIC;                        -- Si true, alors le manager a produit un resultat sur un seul mot. Il doit etre mis dans un registre standard non vectoriel.
           o_result         : out STD_LOGIC_VECTOR (127 downto 0);  -- Resultat (vecteur). Si resultat = mots, il est mis dans le LSB (0) 
           o_multRes        : out STD_LOGIC_VECTOR (255 downto 0)); -- multRes, viens direct de l'ALU.
end simd_manager;

architecture Behavioral of simd_manager is

begin


end Behavioral;
