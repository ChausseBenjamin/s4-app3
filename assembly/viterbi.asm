.data

# Only the first metric is used as a test for brevity
metric_0_0: .word 4,5,3,2 # First metric, first row
metric_0_1: .word 0,3,5,4 # First metric, second row
metric_0_2: .word 4,3,3,2 # ...
metric_0_3: .word 2,5,5,2

# With 3 input vectors and the first metrics 4x4 matrix,
# a total of 12 test cases can be verified (3*4)
input_1: .word 0,0,0,0
input_2: .word 2,0,2,2
input_3: .word 4,2,4,0

base_vec: .word 250,250,250,250

so:       .word 0,0,0,0

.globl main
.globl acs
.globl calc_survivor

main:
  # $t0 stores location of the next test scenario
  # increments after each test is complete
  sw $t0, t_setup_1

# The same test is continuously run with different inpuot values
# This label assumes a setup was previously run to prepare the
# input data at the appropriate locations
run_test:
  j calc_survivor

# Anything that must gets executed after a test run (print statements,
# assertions, etc...) are run here before moving on to the next test
post_test: #TODO: Print some shit


# Each t_setup call here merely prepares a test for execution
# Once ready with the appropriate input data (metrics and input),
# run_test gets executed
t_setup_1:  # input_1 X metrics[0]
  la $t0, t_setup_2 # where to jump after the test completes
  lwv $z0, input_1
  lwv $z1, metric_0_0
  j run_test

t_setup_2:  # input_1 X metrics[1]
  la $t0, t_setup_2
  lwv $z0, input_1
  lwv $z1, metric_0_1
  j run_test

t_setup_3:  # input_1 X metrics[2]
  la $t0, t_setup_2
  lwv $z0, input_1
  lwv $z1, metric_0_2
  j run_test

t_setup_4:  # input_1 X metrics[3]
  la $t0, t_setup_2
  lwv $z0, input_1
  lwv $z1, metric_0_3
  j run_test

t_setup_5:  # input_2 X metrics[0]
  la $t0, t_setup_2
  lwv $z0, input_2
  lwv $z1, metric_0_0
  j run_test

t_setup_6:  # input_2 X metrics[1]
  la $t0, t_setup_2
  lwv $z0, input_2
  lwv $z1, metric_0_1
  j run_test

t_setup_7:  # input_2 X metrics[2]
  la $t0, t_setup_2
  lwv $z0, input_2
  lwv $z1, metric_0_2
  j run_test

t_setup_8:  # input_2 X metrics[3]
  la $t0, t_setup_2
  lwv $z0, input_2
  lwv $z1, metric_0_3
  j run_test

t_setup_9:  # input_3 X metrics[0]
  la $t0, t_setup_2
  lwv $z0, input_3
  lwv $z1, metric_0_0
  j run_test

t_setup_10: # input_3 X metrics[1]
  la $t0, t_setup_2
  lwv $z0, input_3
  lwv $z1, metric_0_1
  j run_test

t_setup_11: # input_3 X metrics[2]
  la $t0, t_setup_2
  lwv $z0, input_3
  lwv $z1, metric_0_2
  j run_test

t_setup_12: # input_3 X metrics[3]
  la $t0, end # Last test complete, go to the end of the program next
  lwv $z0, input_3
  lwv $z1, metric_0_3
  j run_test


calc_survivor:
  la   $t3, base_vec   # Load address of base_vec
  lwv  $z2, 0($t3)     # Load base_vec into $z0
  j    acs             # Jump to acs

acs: #TODO: write this function
  addv $z2, $z0, $z1
  # Go here if there is no need to overwrite the vector value
  # with 250
  skip_overwrite:

end:
  li $v0, 10
  syscall
