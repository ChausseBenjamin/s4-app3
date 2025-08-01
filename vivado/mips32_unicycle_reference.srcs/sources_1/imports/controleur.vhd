---------------------------------------------------------------------------------------------
--
--	Universit� de Sherbrooke 
--  D�partement de g�nie �lectrique et g�nie informatique
--
--	S4i - APP4 
--	
--
--	Auteur: 		Marc-Andr� T�trault
--					Daniel Dalle
--					S�bastien Roy
-- 
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPS32_package.all;

entity controleur is
Port (
    i_Op          	: in std_logic_vector(5 downto 0);
    i_funct_field 	: in std_logic_vector(5 downto 0);
    
    o_RegDst    	: out std_logic;
    o_Branch    	: out std_logic;
    o_MemtoReg  	: out std_logic;
    o_AluFunct  	: out std_logic_vector (3 downto 0);
    o_MemRead   	: out std_logic;
    o_MemWrite  	: out std_logic;
    o_ALUSrc    	: out std_logic;
    o_RegWrite  	: out std_logic;
	
	-- Sorties supp. vs 4.17
    o_Jump 			: out std_logic;
	o_jump_register : out std_logic;
	o_jump_link 	: out std_logic;
	o_alu_mult      : out std_logic;
	o_mflo          : out std_logic;
	o_mfhi          : out std_logic;
	o_SignExtend 	: out std_logic;
	
	-- SIMD stuff.
	o_op_is_simd    : out std_logic; -- Indique que ce qui doit se passer est en fonction d'operation SIMD. Active le controlleur de SIMD.
	o_v_MemRead     : out std_logic; -- Dit a la cache qu'elle doit lire en mode large. Permet aussi la logique de decision entre si c'est donnees de cache qui vont dans le registre ou le resultat du core SIMD.
	o_v_MemWrite    : out std_logic; -- Dit a la cache qu'elle doit ecrite en mode large
	o_v_RegDst      : out std_logic; -- Drive le MUX pour selectionner entre RD et RT. (registre destination)
	o_v_RegWrite    : out std_logic  -- Dit au registre de vecteurs qu'il doit ecraser le registre destination avec les donnees en entrees.
    );
end controleur;

architecture Behavioral of controleur is

    signal s_R_funct_decode   : std_logic_vector(3 downto 0);

begin

    -- Contr�les pour les diff�rents types d'instructions
    -- 
    process( i_Op, s_R_funct_decode )
    begin
        
        case i_Op is
			-- pour tous les types R
            when OP_Rtype => 
                o_AluFunct <= s_R_funct_decode;
			when OP_ADDI => 
				o_AluFunct <= ALU_ADD;
			when OP_ADDIU =>
				o_AluFunct <= ALU_ADD;
			when OP_ORI => 
				o_AluFunct <= ALU_OR;
			when OP_LUI => 
				o_AluFunct <= ALU_SLL16;
			when OP_BEQ => 
				o_AluFunct <= ALU_SUB;
			when OP_JAL =>
				o_AluFunct <= ALU_NULL;
			when OP_SW => 
				o_AluFunct <= ALU_ADD;
			when OP_LW => 
				o_AluFunct <= ALU_ADD;
            -- when OP_??? =>   -- autres cas?
            -- SIMD CODES. A noter que Vtype reutilise tout les Rtype!
            when OP_Vtype =>
                o_AluFunct <= s_R_funct_decode;
            when OP_MINV =>
                o_AluFunct <= ALU_NULL; -- L'ALU fait rien pour le type min.
            when OP_SWV =>
                o_AluFunct <= ALU_ADD;  -- Copier du type SW normal. Peut-etre que c'est pertinent, peut-etre pas.
            when OP_LWV =>
                o_AluFunct <= ALU_ADD;  -- Copier du type LW normal. Peut-etre que c'est pertinent, peut-etre pas. 
			-- sinon
            when others =>
				o_AluFunct <= (others => '0');
        end case;
    end process; 
    
    -- Commande � l'ALU pour les instructions "R". Devrait aussi fonctionner pour les types V.
    process(i_funct_field)
    begin
        case i_funct_field is
            when ALUF_AND => 
                s_R_funct_decode <= ALU_AND;
            when ALUF_OR => 
                s_R_funct_decode <= ALU_OR;
            when ALUF_NOR =>
                s_R_funct_decode <= ALU_NOR;
            when ALUF_ADD => 
                s_R_funct_decode <= ALU_ADD;
            when ALUF_SUB => 
                s_R_funct_decode <= ALU_SUB;                
            when ALUF_SLL => 
                s_R_funct_decode <= ALU_SLL;  
            when ALUF_SRL => 
                s_R_funct_decode <= ALU_SRL; 
            when ALUF_ADDU => 
                s_R_funct_decode <= ALU_ADD;
            when ALUF_SLT => 
                s_R_funct_decode <= ALU_SLT; 
            when ALUF_SLTU => 
                s_R_funct_decode <= ALU_SLTU; 
            when ALUF_MULTU => 
                s_R_funct_decode <= ALU_MULTU; 
            when ALUF_MFHI => 
                s_R_funct_decode <= ALU_NULL; 
            when ALUF_MFLO => 
                s_R_funct_decode <= ALU_NULL; 
            -- � compl�ter au besoin avec d'autres instructions
            when others =>
                s_R_funct_decode <= ALU_NULL;
         end case;
    end process;
    
    -- Identifier si l'operation actuel est un type SIMD ou pas.
    o_op_is_simd <= '1' when ((i_Op = OP_Vtype) or
                             (i_Op = Op_MINV)  or
                             (i_Op = Op_LWV)   or
                             (i_Op = Op_SWV))
                    else '0'; 
	
    o_RegWrite		<= '1' when i_Op = OP_Rtype or 
								i_Op = OP_ADDI or 
								i_Op = OP_ADDIU or 
								i_Op = OP_ORI or 
								i_Op = OP_LUI or 
								i_Op = OP_LW or 
								i_Op = OP_JAL or
								i_Op = OP_MINV      -- Minv ecrit dans un registre standard.
						else '0';
						-- Il faudra ajouter le opcode de MINV si ce dernier ecrit dans un vecteur standard.
						-- Si on fait ca, il faut un MUX a la sortie des ALU et une sortie de plus pour dire quel ALU ecrit dans ce registre la.
    
    -- Sert a dire au banc de registre de vecteur, qu'il doivent ecraser le registre de destination avec les donnees en entree.
    o_v_RegWrite    <= '1' when i_Op = OP_Vtype or -- v_type pareil que r_type. Ces fonctions doivent ecrite a une destination.
                                i_Op = OP_LWV      -- load un vecteur ecrase un registre de vecteur.
                       else '0';                   -- minv ecrit dans un registre standard, donc pas inclue ici.
	
	-- Selection des registres de destinations --
	o_RegDst 		<= '1' when i_Op = OP_Rtype else '0'; -- Quand c'est '1', c'est rd qui est utilise. Sinon c'est RT.
	o_v_RegDst      <= '1' when i_Op = OP_Vtype else '0'; -- On doit switch entre rt et rd pour le v type, car il est essentiellement pareil que le r type.
	
	
	o_ALUSrc 		<= '0' when i_Op = OP_Rtype or
								i_Op = OP_BEQ
						else '1';
	o_Branch 		<= '1' when i_Op = OP_BEQ   else '0';
	
	o_MemRead 		<= '1' when i_Op = OP_LW else '0';
	o_v_MemRead     <= '1' when i_Op = OP_LWV else '0'; -- Pareil que le signal normal.
	
	o_MemWrite 		<= '1' when i_Op = OP_SW else '0';
	o_v_MemWrite    <= '1' when i_Op = OP_SWV else '0'; -- Pareil que le signal normal.
	
	o_MemtoReg 		<= '1' when i_Op = OP_LW else '0';
	o_SignExtend	<= '1' when i_OP = OP_ADDI or
	                           i_OP = OP_BEQ 
	                     else '0';
	
	
	o_Jump	 		<= '1' when i_Op = OP_J or 
	                            i_Op = OP_JAL 
						else '0';
				
				
	o_jump_link 	<= '1' when i_Op = OP_JAL else '0';
	o_jump_register <= '1' when i_Op = OP_Rtype and 
								i_funct_field = ALUF_JR 
						else '0';
	
	o_alu_mult      <= '1' when i_op = OP_Rtype and i_funct_field = ALUF_MULTU else '0';
	o_mflo          <= '1' when i_op = OP_Rtype and i_funct_field = ALUF_MFLO else '0';
	o_mfhi          <= '1' when i_op = OP_Rtype and i_funct_field = ALUF_MFHI else '0';

end Behavioral;
