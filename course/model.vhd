Library IEEE, work;
Use IEEE.std_logic_1164.all;
Use work.package1.all;
Use IEEE.MATH_REAL.all;

entity model is
	port(clk : in std_logic;
		start_eat : in eat_arr;
		ant : out ant_arr);
end model;

architecture struct of model is

signal next_ant : ant_arr := (0 => MATRIX_SIZE-2, 1 => MATRIX_SIZE-2); -- pos of ant
signal startPos : ant_arr := (0 => MATRIX_SIZE-2, 1 => MATRIX_SIZE-2); -- anthill

signal eat: eat_arr;

-- pheromone initialize
signal pheromone : pheromone_arr := (
	0 => (others => -1),
	MATRIX_SIZE-1 => (others => -1),
	others => (0 => -1, MATRIX_SIZE-1 => -1, others => 0)
	);

signal goHome : std_logic := '0';
signal initialize, eat_ready : std_logic := '0';

begin

	main_process: process(clk)

		variable ant_near : ant_near_arr; -- neighbor cells
		variable best_way : natural range 0 to 7; -- index of the ant_near
		variable equal_count : real range 0.0 to 8.0 := 0.0;

		-- for random
		variable seed1, seed2 : positive;
		variable rand : real;
		variable int_rand : integer range 0 to 7;

	begin

		if(clk'event and clk = '0') then

			if(initialize = '0') then
				eat <= start_eat;
				initialize <= '1';
			elsif(initialize = '1') then

				-- next_ant sequence
				-- 7  6  4
				-- 5 ant 2 
				-- 3  1  0
				ant_near := (
					0 => (next_ant(0) + 1, next_ant(1) + 1),
					1 => (next_ant(0) + 1, next_ant(1)),
					2 => (next_ant(0),     next_ant(1) + 1),
					3 => (next_ant(0) + 1, next_ant(1) - 1),
					4 => (next_ant(0) - 1, next_ant(1) + 1),
					5 => (next_ant(0),     next_ant(1) - 1),
					6 => (next_ant(0) - 1, next_ant(1)),
					7 => (next_ant(0) - 1, next_ant(1) - 1)
					);
				
				-- find first near cell /= -1
				for i in 0 to 7 loop
					if(pheromone(ant_near(i)(0),ant_near(i)(1)) >= 0) then
						best_way := i;
						exit;
					end if;
				end loop;
				equal_count := 0.0;

				if(goHome = '1') then

					-- hit on an anthill
					if(next_ant(0) = startPos(0) and next_ant(1) = startPos(1)) then
						goHome <= '0';

					else
						-- find the best way
						-- get all max values
						for i in 1 to 7 loop
							if(pheromone(ant_near(i)(0),ant_near(i)(1)) > pheromone(ant_near(best_way)(0),ant_near(best_way)(1))) then
								best_way := i;
							end if;
						end loop;

						-- get max values and update equal_count
						for i in 0 to 7 loop
							if(pheromone(ant_near(i)(0),ant_near(i)(1)) = pheromone(ant_near(best_way)(0),ant_near(best_way)(1))) then
								equal_count := equal_count + 1.0;
							end if;
						end loop;

						-- random choose from equals
						UNIFORM(seed1, seed2, rand);
		        		int_rand := INTEGER(TRUNC(rand * equal_count));
		        		for i in 0 to 7 loop
							if(pheromone(ant_near(i)(0),ant_near(i)(1)) = pheromone(ant_near(best_way)(0),ant_near(best_way)(1))) then
								if(int_rand = 0) then
									best_way := i;
									exit;
								else
									int_rand := int_rand - 1;
								end if;
							end if;
						end loop;

						-- decrement previous cell
						if(pheromone(next_ant(0), next_ant(1)) > 0) then
							pheromone(next_ant(0), next_ant(1)) <= pheromone(next_ant(0), next_ant(1)) - 1;
						end if;

						-- update next_state
						next_ant <= (ant_near(best_way)(0), ant_near(best_way)(1));
					end if;

				elsif(goHome = '0') then

					-- hit on food
					if(eat(next_ant(0)-1)(next_ant(1)-1) = '1') then
						goHome <= '1';
						eat(next_ant(0)-1)(next_ant(1)-1) <= '0';

					else
						-- find the best way
						-- get all min values
						for i in 0 to 7 loop
							if((pheromone(ant_near(i)(0),ant_near(i)(1)) <= pheromone(ant_near(best_way)(0),ant_near(best_way)(1))) and (pheromone(ant_near(i)(0),ant_near(i)(1)) /= -1)) then
								best_way := i;
								if(eat(ant_near(i)(0)-1)(ant_near(i)(1)-1) = '1') then
									exit;
								end if;
							end if;
						end loop;

						if(eat(ant_near(best_way)(0)-1)(ant_near(best_way)(1)-1) = '0') then
							-- get all min values and update equal_count
							for i in 0 to 7 loop
								if(pheromone(ant_near(i)(0),ant_near(i)(1)) = pheromone(ant_near(best_way)(0),ant_near(best_way)(1))) then
									equal_count := equal_count + 1.0;
								end if;
							end loop;

							-- random choose from equals
							UNIFORM(seed1, seed2, rand);
			        		int_rand := INTEGER(TRUNC(rand * equal_count));
			        		for i in 0 to 7 loop
								if(pheromone(ant_near(i)(0),ant_near(i)(1)) = pheromone(ant_near(best_way)(0),ant_near(best_way)(1))) then
									if(int_rand = 0) then
										best_way := i;
										exit;
									else
										int_rand := int_rand - 1;
									end if;
								end if;
							end loop;
						end if;

						-- inc two pheromone to cell
						pheromone(next_ant(0), next_ant(1)) <= pheromone(next_ant(0), next_ant(1)) + 2;

						-- update next_state
						next_ant <= (ant_near(best_way)(0), ant_near(best_way)(1));

					end if;
				end if;
			end if;

		elsif(clk'event and clk = '1') then
			if(initialize = '1') then
				ant <= next_ant;
			end if;
		end if;
	end process;
end struct;
