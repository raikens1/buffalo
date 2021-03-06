#' ARGUMENTS:
#' rho (float) describes angle between propensity and prognostic model
#' p (int) number of covariates - must be at least 2
#' nsim (int) number of simulations

source("basic_sim_functions.R")
source("fullmatch_sim_functions.R")
source("pairmatch_sim_functions.R")
source("HTE_sim_functions.R")

out_file <- "HTE_results_"

# get user arguments
args <- commandArgs(trailingOnly=TRUE)

# parse args
rho <- as.numeric(args[1])
p <- as.numeric(args[2])
nsim <- as.numeric(args[3])

# defaults
true_mu <- "X1/3 - 3"
sigma <- 1
true_tau <- "1 + 0.25 * X1"
ks <- 1:5
N <- 2000
full <- F
prop_model <- formula(t ~ X1 + X2 + X3 + X4 + X5 + X6 + X7 + X8 + X9 + X10) 
prog_model <- formula(y ~ X1 + X2 + X3 + X4 + X5 + X6 + X7 + X8 + X9 + X10)

run_sim <- function(rho = 0.1, p = 10, nsim = 10,
                    out_file = "test_", true_mu = "X1/3 - 3", 
                    ks = 1:10, sigma = 1, true_tau = "1 + rnorm(N, sd = 0.25)",
                    N = 2000, prog_model, prop_model,
                    full = FALSE) {
  t1 <- proc.time()
  
  message("********************")
  message("Simulation parameters:")
  message(paste("N:", N))
  message(paste("Rho:", rho))
  message(paste("p:",p))
  message(paste("nsim:", nsim))
  message(paste("true_mu:", true_mu))
  message(paste("sigma:", sigma))
  message(paste("true_tau:", true_tau))
  message(paste("full:", full))
  message("********************")
  
  # simulate
  if (full){
    exit("fullmatching with HTE estimation is not yet supported")
  } else {
    results <- replicate(nsim,
                         simulate_pairmatch(generate_data_HTE(N=N, rho=rho, p = p,
                                                              true_mu = true_mu,
                                                              sigma = sigma, 
                                                              true_tau = true_tau),
                                            prop_model = prop_model,
                                            prog_model = prog_model,
                                            verbose = TRUE, ks = ks, HTE = T),
                         simplify = FALSE) %>% 
      bind_rows()
  }
  
  message("********************")
  message("Simulations complete:")
  message("********************")
  
  # write to file
  if (!is.null(out_file)){
    write.csv(results, file = paste0(out_file, rho*10, "_", p, "_", nsim), row.names = FALSE)
    message(paste("output file:", paste0(out_file, rho*10, "_", p, "_", nsim)))
  } else {
    message("Results not saved to file.")
  }
  message("Time elapsed:")
  message(print(proc.time() - t1))
  message("********************")
  
  if (is.null(out_file)){
    return(results)
    } else{
      return(1)
    }

}

run_sim(rho = rho, p = p, nsim = nsim, 
        out_file = out_file, true_mu = true_mu,
        sigma = sigma, true_tau = true_tau, ks = ks, N = N,
        prog_model = prog_model, prop_model = prop_model,
        full = full)