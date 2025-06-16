---------------------------------------------------------------------------------------------
--
--	Université de Sherbrooke 
--  Département de génie électrique et génie informatique
--
--	S4i - APP4 
--	
--
--	Auteurs: 		Marc-André Tétrault
--					Daniel Dalle
--					Sébastien Roy
-- 
---------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPS32_package.all;


entity mips_datapath_unicycle is
Port ( 
	clk 			: in std_logic;
	reset 			: in std_logic;

	i_alu_funct   	: in std_logic_vector(3 downto 0);
	i_RegWrite    	: in std_logic;
	i_RegDst      	: in std_logic;
	i_MemtoReg    	: in std_logic;
	i_branch      	: in std_logic;
	i_ALUSrc      	: in std_logic;
	i_MemRead 		: in std_logic;
	i_MemWrite	  	: in std_logic;

	i_jump   	  	: in std_logic;
	i_jump_register : in std_logic;
	i_jump_link   	: in std_logic;
	i_alu_mult      : in std_logic;
	i_mflo          : in std_logic;
	i_mfhi          : in std_logic;
	i_SignExtend 	: in std_logic;
	
	i_op_is_simd    : out std_logic; -- Voir controlleur.vhd pour l'explication de ces signaux la.
	i_v_MemRead     : out std_logic; 
	i_v_MemWrite    : out std_logic; 
	i_v_RegDst      : out std_logic; 
	i_v_RegWrite    : out std_logic;  

	o_Instruction 	: out std_logic_vector (31 downto 0);
	o_PC		 	: out std_logic_vector (31 downto 0)
);
end mips_datapath_unicycle;

architecture Behavioral of mips_datapath_unicycle is


component MemInstructions is
    Port ( i_addresse : in std_logic_vector (31 downto 0);
           o_instruction : out std_logic_vector (31 downto 0));
end component;

--component MemDonnees is
--Port ( 
--	clk : in std_logic;
--	reset : in std_logic;
--	i_MemRead 	: in std_logic;
--	i_MemWrite : in std_logic;
--    i_Addresse : in std_logic_vector (31 downto 0);
--	i_WriteData : in std_logic_vector (31 downto 0);
--    o_ReadData : out std_logic_vector (31 downto 0)
--);
--end component;

    component simd_manager is
    Port (  i_reg_data_RS1   : in STD_LOGIC_VECTOR (127 downto 0);   -- rs lu du banc de registre
            i_reg_data_RS2   : in STD_LOGIC_VECTOR (127 downto 0);   -- rt lu du banc de registre
            i_opcode         : in STD_LOGIC_VECTOR (5 downto 0);     -- Opcode, pour savoir les instructions simd.
            i_alu_funct      : in STD_LOGIC_VECTOR (3 downto 0);     -- Utiliser lorsque opcode = v_type. Pour que l'ALU parallel sache quoi faire.
            i_shamt          : in STD_LOGIC_VECTOR (4 downto 0);     -- Passer directement a ALU.
            i_enable         : in STD_LOGIC;                         -- Enables le process SIMD. si false. Enabled lorsqu'un instruction simd est detecte par le controlleur
            o_result_is_word : out STD_LOGIC;                        -- Si true, alors le manager a produit un resultat sur un seul mot. Il doit etre mis dans un registre standard non vectoriel.
            o_result         : out STD_LOGIC_VECTOR (127 downto 0);  -- Resultat (vecteur). Si resultat = mots, il est mis dans le LSB (0) 
            o_multRes        : out STD_LOGIC_VECTOR (255 downto 0);  -- multRes, viens direct de l'ALU.
            o_zero           : out STD_LOGIC_VECTOR (3 downto 0));
    end component;


    component MemDonneesWideDual is
    Port ( 
	   clk 		      : in std_logic;                         -- Pareil que l'ancienne memoire
	   reset 		  : in std_logic;                         -- Pareil que l'ancienne memoire
	   i_MemRead	  : in std_logic;                         -- Pareil que l'ancienne memoire. Cependant, ce n'est pas implementer a l'interne!
	   i_MemWrite 	  : in std_logic;                         -- Dit d'ecrite writedata a i_address. write wide prend le dessus si les deux sont a 1.
       i_Addresse     : in std_logic_vector (31 downto 0);    -- Address ou aller ecrite les donnees.
	   i_WriteData    : in std_logic_vector (31 downto 0);    -- Mot a ecrire en mode ecriture pas wide.
       o_ReadData     : out std_logic_vector (31 downto 0);   -- Donne lu a l'index donnee.
	
	   -- ports pour accès à large bus, adresse partagée
	   i_MemReadWide   : in std_logic;                        -- Quand a 1, le processus est fait sur 4 mots consecutif. A pas besoin de memwrite a 1 pour fonctionner.
	   i_MemWriteWide  : in std_logic;                        -- Prend le dessus sur memWrite. Change tout le processus pour que ce soit sur 4 mots consecutif.
	   i_WriteDataWide : in std_logic_vector (127 downto 0);  -- Donne a ecrire dans les 4 addresses consecutif, debutant par i_addresse.
       o_ReadDataWide  : out std_logic_vector (127 downto 0)  -- 4 mots consecutif a partir de i_addresse. Toujours donnees meme sans i_MemReadWide
    );
    end component;

	component BancRegistres is
	Port ( 
		clk : in std_logic;
		reset : in std_logic;
		i_RS1 : in std_logic_vector (4 downto 0);
		i_RS2 : in std_logic_vector (4 downto 0);
		i_Wr_DAT : in std_logic_vector (31 downto 0);
		i_WDest : in std_logic_vector (4 downto 0);
		i_WE : in std_logic;
		o_RS1_DAT : out std_logic_vector (31 downto 0);
		o_RS2_DAT : out std_logic_vector (31 downto 0)
		);
	end component;
	
	component registres_z is -- the same thing as BancRegistres, mais pour des vecteurs de 4 mots.
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           -- Writing Data (synchronous)
           i_WE : in STD_LOGIC;
           i_Wr_DAT : in STD_LOGIC_VECTOR (127 downto 0);
           i_WDest : in STD_LOGIC_VECTOR (4 downto 0);
           -- Reading Data (async)
           i_RS1 : in STD_LOGIC_VECTOR (4 downto 0);
           i_RS2 : in STD_LOGIC_VECTOR (4 downto 0);  
           o_RS1_DAT : out STD_LOGIC_VECTOR (127 downto 0); 
           o_RS2_DAT : out STD_LOGIC_VECTOR (127 downto 0));
    end component;

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

	constant c_Registre31		 : std_logic_vector(4 downto 0) := "11111";
	signal s_zero        : std_logic;
	
    signal s_WriteRegDest_muxout   : std_logic_vector(4 downto 0);
    signal s_v_WriteRegDest_muxout : std_logic_vector(4 downto 0);
	
    signal r_PC                    : std_logic_vector(31 downto 0);
    signal s_PC_Suivant            : std_logic_vector(31 downto 0);
    signal s_adresse_PC_plus_4     : std_logic_vector(31 downto 0);
    signal s_adresse_jump          : std_logic_vector(31 downto 0);
    signal s_adresse_branche       : std_logic_vector(31 downto 0);
    
    signal s_Instruction : std_logic_vector(31 downto 0);

    signal s_opcode      : std_logic_vector( 5 downto 0);
    signal s_RS          : std_logic_vector( 4 downto 0);
    signal s_RT          : std_logic_vector( 4 downto 0);
    signal s_RD          : std_logic_vector( 4 downto 0);
    signal s_shamt       : std_logic_vector( 4 downto 0);
    signal s_instr_funct : std_logic_vector( 5 downto 0);
    signal s_imm16       : std_logic_vector(15 downto 0);
    signal s_jump_field  : std_logic_vector(25 downto 0);
    signal s_reg_data1        : std_logic_vector(31 downto 0);
    signal s_reg_data2        : std_logic_vector(31 downto 0);
    signal s_AluResult             : std_logic_vector(31 downto 0);
    signal s_AluMultResult          : std_logic_vector(63 downto 0);
    
    signal s_Data2Reg_muxout       : std_logic_vector(31 downto 0);
    
    signal s_imm_extended          : std_logic_vector(31 downto 0);
    signal s_imm_extended_shifted  : std_logic_vector(31 downto 0);
	
    signal s_Reg_Wr_Data           : std_logic_vector(31 downto 0);
    signal s_MemoryReadData        : std_logic_vector(31 downto 0);
    signal s_AluB_data             : std_logic_vector(31 downto 0);
    
    signal s_v_MemoryReadData      : std_logic_vector(127 downto 0); -- Donnees vectorielle lu de la cache de donnees.
    signal s_v_DataToWriteInCache  : std_logic_vector(127 downto 0);
    signal s_v_DataToWriteInRegs   : std_logic_vector(127 downto 0);
    
    signal s_v_reg_data1           : std_logic_vector(127 downto 0); -- Sortie de banc de registres identique a registres normaux, mais vectoriel.
    signal s_v_reg_data2           : std_logic_vector(127 downto 0);
    
    signal s_result_is_word        : std_logic;
    signal s_simd_manager_output   : std_logic_vector(127 downto 0);
    
    -- registres spéciaux pour la multiplication
    signal r_HI             : std_logic_vector(31 downto 0);
    signal r_LO             : std_logic_vector(31 downto 0);
	

begin

o_PC	<= r_PC; -- permet au synthétiseur de sortir de la logique. Sinon, il enlève tout...

------------------------------------------------------------------------
-- simplification des noms de signaux et transformation des types
------------------------------------------------------------------------
s_opcode        <= s_Instruction(31 downto 26);
s_RS            <= s_Instruction(25 downto 21);
s_RT            <= s_Instruction(20 downto 16);
s_RD            <= s_Instruction(15 downto 11);
s_shamt         <= s_Instruction(10 downto  6);
s_instr_funct   <= s_Instruction( 5 downto  0);
s_imm16         <= s_Instruction(15 downto  0);
s_jump_field	<= s_Instruction(25 downto  0);
------------------------------------------------------------------------


------------------------------------------------------------------------
-- Compteur de programme et mise à jour de valeur
------------------------------------------------------------------------
process(clk)
begin
    if(clk'event and clk = '1') then
        if(reset = '1') then
            r_PC <= X"00400000";
        else
            r_PC <= s_PC_Suivant;
        end if;
    end if;
end process;

s_adresse_PC_plus_4				<= std_logic_vector(unsigned(r_PC) + 4);
s_adresse_jump					<= s_adresse_PC_plus_4(31 downto 28) & s_jump_field & "00";
s_imm_extended_shifted			<= s_imm_extended(29 downto 0) & "00";
s_adresse_branche				<= std_logic_vector(unsigned(s_imm_extended_shifted) + unsigned(s_adresse_PC_plus_4));

-- note, "i_jump_register" n'est pas dans les figures de COD5
s_PC_Suivant		<= s_adresse_jump when i_jump = '1' else
                       s_reg_data1 when i_jump_register = '1' else
					   s_adresse_branche when (i_branch = '1' and s_zero = '1') else
					   s_adresse_PC_plus_4;
					   

------------------------------------------------------------------------
-- Mémoire d'instructions
------------------------------------------------------------------------
inst_MemInstr: MemInstructions
Port map ( 
	i_addresse => r_PC,
    o_instruction => s_Instruction
    );

-- branchement vers le décodeur d'instructions
o_instruction <= s_Instruction;
	
------------------------------------------------------------------------
-- Banc de Registres
------------------------------------------------------------------------
-- Multiplexeur pour le registre en écriture
s_WriteRegDest_muxout <= c_Registre31 when i_jump_link = '1' else 
                         s_rt         when i_RegDst = '0' else 
						 s_rd;
       
inst_Registres: BancRegistres 
port map ( 
	clk          => clk,
	reset        => reset,
	i_RS1        => s_rs,                  -- Source universel peut importe le type de donnees. Addresse vers un registre de 1 mot.
	i_RS2        => s_rt,                  -- Source 2.
	i_Wr_DAT     => s_Data2Reg_muxout,     -- Donnees a ecrire dans le registre. Peut etre resultat ALU, ou jumps (adr+4), ou multiplications.
	i_WDest      => s_WriteRegDest_muxout, -- Registre ou le wr_dat est ecrit. (rd ou rt)
	i_WE         => i_RegWrite,            -- Event qui dit: go, ecrit wr_dat dans wdest.
	o_RS1_DAT    => s_reg_data1,           -- donnees de rs. Toujours output.
	o_RS2_DAT    => s_reg_data2            -- donnees de rt. Toujoutrs output.
	);
	

------------------------------------------------------------------------
-- ALU (instance, extension de signe et mux d'entrée pour les immédiats)
------------------------------------------------------------------------
-- extension de signe
s_imm_extended <= std_logic_vector(resize(  signed(s_imm16),32)) when i_SignExtend = '1' else -- extension de signe à 32 bits
				  std_logic_vector(resize(unsigned(s_imm16),32)); 

-- Mux pour immédiats
s_AluB_data <= s_reg_data2 when i_ALUSrc = '0' else s_imm_extended;

inst_Alu: alu 
port map( 
	i_a         => s_reg_data1,
	i_b         => s_AluB_data,
	i_alu_funct => i_alu_funct,
	i_shamt     => s_shamt,
	o_result    => s_AluResult,
	o_multRes   => s_AluMultResult,
	o_zero      => s_zero
	);

------------------------------------------------------------------------
-- Mémoire de données
------------------------------------------------------------------------
--inst_MemDonnees : MemDonnees
--Port map( 
--	clk 		=> clk,
--	reset 		=> reset,
--	i_MemRead	=> i_MemRead,
--	i_MemWrite	=> i_MemWrite,
--    i_Addresse	=> s_AluResult,
--	i_WriteData => s_reg_data2,
--    o_ReadData	=> s_MemoryReadData
--	);

inst_MemDonnees_Thicc : MemDonneesWideDual
    Port map ( 
	   clk 		       => clk,
	   reset 		   => reset,
	   i_MemRead	   => i_MemRead,
	   i_MemWrite 	   => i_MemWrite,
       i_Addresse      => s_AluResult,      -- To understand
	   i_WriteData     => s_reg_data2,      -- Sortie 2 des banc de registres standard.
       o_ReadData      => s_MemoryReadData, -- Donnee a i_addresse, toujours output. Mis dans banc registre si RegWrite est mis a 1. Muxed with other data tho.
	
	   i_MemReadWide   => i_v_MemRead,
	   i_MemWriteWide  => i_v_MemWrite,
	   i_WriteDataWide => s_v_DataToWriteInCache, -- vecteur a stocker dans la cache.
       o_ReadDataWide  => s_v_MemoryReadData
    );

------------------------------------------------------------------------
-- Mux d'écriture vers le banc de registres
------------------------------------------------------------------------

s_Data2Reg_muxout    <= s_adresse_PC_plus_4 when i_jump_link = '1' else
					    r_HI                when i_mfhi = '1' else 
					    r_LO                when i_mflo = '1' else
					    s_AluResult         when i_MemtoReg = '0' else 
						s_MemoryReadData;

------------------------------------------------------------------------
-- Registres spéciaux pour la multiplication
------------------------------------------------------------------------				
process(clk)
begin
    if(clk'event and clk = '1') then
        if(i_alu_mult = '1') then
            r_HI <= s_AluMultResult(63 downto 32);
            r_LO <= s_AluMultResult(31 downto 0);
        end if;
    end if;
end process;

------------------------------------------------------------------------
-- SIMD stuff.
------------------------------------------------------------------------


banc_registre_de_vecteurs : registres_z -- the same thing as BancRegistres, mais pour des vecteurs de 4 mots.
    Port map ( 
        clk         => clk,
        reset       => reset,
        i_WE        => i_v_RegWrite,
        i_Wr_DAT    => s_v_DataToWriteInRegs,
        i_WDest     => s_v_WriteRegDest_muxout,

        i_RS1       => s_rs,
        i_RS2       => s_rt,  
        o_RS1_DAT   => s_v_reg_data1, 
        o_RS2_DAT   => s_v_reg_data2
    );
    
gestionnaire_dinstructions_simd : simd_manager
    Port map ( 
            i_reg_data_RS1    => s_v_reg_data1,
            i_reg_data_RS2    => s_v_reg_data2,
            i_opcode          => s_opcode,
            i_alu_funct       => s_instr_funct,
            i_shamt           => s_shamt,
            i_enable          => i_op_is_simd,
            o_result_is_word  => s_result_is_word,
            o_result          => s_simd_manager_output,
            o_multRes         => open,
            o_zero            => open
    );
        
end Behavioral;
