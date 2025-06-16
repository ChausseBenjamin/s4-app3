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
use work.MIPS32_package.all;

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
           i_reg_data_Dest  : in STD_LOGIC_VECTOR (127 downto 0);   -- registre de destination, lu du banc de registre. Ye la juste au cas ou.
           i_opcode         : in STD_LOGIC_VECTOR (5 downto 0);     -- Opcode, pour savoir les instructions simd.
           i_alu_funct      : in STD_LOGIC_VECTOR (3 downto 0);     -- Utiliser lorsque opcode = v_type. Pour que l'ALU parallel sache quoi faire.
           i_shamt          : in STD_LOGIC_VECTOR (4 downto 0);     -- Passer directement a ALU.
           i_enable         : in STD_LOGIC;                         -- Enables le process SIMD. si false. Enabled lorsqu'un instruction simd est detecte par le controlleur
           o_result_is_word : out STD_LOGIC;                        -- Si true, alors le manager a produit un resultat sur un seul mot. Il doit etre mis dans un registre standard non vectoriel.
           o_result         : out STD_LOGIC_VECTOR (127 downto 0);  -- Resultat (vecteur). Si resultat = mots, il est mis dans le LSB (0) 
           o_multRes        : out STD_LOGIC_VECTOR (255 downto 0);  -- multRes, viens direct de l'ALU.
           o_zero           : out STD_LOGIC_VECTOR (3 downto 0));
end simd_manager;

architecture Behavioral of simd_manager is

    component alu_z is
        Port ( i_a          : in STD_LOGIC_VECTOR (127 downto 0);
               i_b          : in STD_LOGIC_VECTOR (127 downto 0);
               i_alu_funct  : in STD_LOGIC_VECTOR (3 downto 0);
               i_shamt      : in STD_LOGIC_VECTOR (4 downto 0);
               o_result     : out STD_LOGIC_VECTOR (127 downto 0);
               o_multRes    : out STD_LOGIC_VECTOR (255 downto 0);
               o_zero       : out STD_LOGIC_VECTOR (3 downto 0));
    end component;

    signal s_z_alu_output       : std_logic_vector(127 downto 0);
    signal s_special_ops_result : std_logic_vector(127 downto 0);
    
    signal s_a_word_0           : std_logic_vector(31 downto 0);
    signal s_a_word_1           : std_logic_vector(31 downto 0);
    signal s_a_word_2           : std_logic_vector(31 downto 0);
    signal s_a_word_3           : std_logic_vector(31 downto 0);
    
    signal s_b_word_0           : std_logic_vector(31 downto 0);
    signal s_b_word_1           : std_logic_vector(31 downto 0);
    signal s_b_word_2           : std_logic_vector(31 downto 0);
    signal s_b_word_3           : std_logic_vector(31 downto 0);

begin

--------------------------------------------------
-- ALU : Always working.
--------------------------------------------------
vectorial_alu : alu_z
    port map (
        i_a         => i_reg_data_RS1,
        i_b         => i_reg_data_RS2,
        i_alu_funct => i_alu_funct,
        i_shamt     => i_shamt,
        o_result    => s_z_alu_output,
        o_multRes   => o_multRes,
        o_zero      => o_zero
    );
--------------------------------------------------
-- breakdown of vectors into words
--------------------------------------------------
s_a_word_0 <= i_reg_data_RS1(127 downto 96);
s_a_word_1 <= i_reg_data_RS1(95 downto 64);
s_a_word_2 <= i_reg_data_RS1(63 downto 32);
s_a_word_3 <= i_reg_data_RS1(31 downto 0);
    
s_b_word_0 <= i_reg_data_RS2(127 downto 96);
s_b_word_1 <= i_reg_data_RS2(95 downto 64);
s_b_word_2 <= i_reg_data_RS2(63 downto 32);
s_b_word_3 <= i_reg_data_RS2(31 downto 0);
    
--------------------------------------------------
-- Special SIMD stuff
--------------------------------------------------
process(i_opcode, i_reg_data_RS1, i_reg_data_RS2, s_a_word_0, s_a_word_1, s_a_word_2, s_a_word_3, s_b_word_0, s_b_word_1, s_b_word_2, s_b_word_3)
begin
    case(i_opcode) is
        when OP_MINV => -- Trouver le plus petit mots dans le vecteur RS.
                if (s_a_word_0 <= s_a_word_1 and s_a_word_0 <= s_a_word_2 and s_a_word_0 <= s_a_word_3) then
                    s_special_ops_result <= s_a_word_0;
                elsif (s_a_word_1 <= s_a_word_0 and s_a_word_1 <= s_a_word_2 and s_a_word_1 <= s_a_word_3) then
                    s_special_ops_result <= s_a_word_1;
                elsif (s_a_word_2 <= s_a_word_0 and s_a_word_2 <= s_a_word_1 and s_a_word_2 <= s_a_word_3) then
                    s_special_ops_result <= s_a_word_2;
                else
                    s_special_ops_result <= s_a_word_3;
                end if;
                o_result_is_word <= '1';

        when others =>
            s_special_ops_result <= (others => '0');
            o_result_is_word <= '0';
    end case;
end process;

--------------------------------------------------
-- Output selection
--------------------------------------------------
o_result <= s_z_alu_output when (i_opcode = OP_Vtype) else s_special_ops_result;

end Behavioral;
