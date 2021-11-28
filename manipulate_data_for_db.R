library(dplyr)
#READ IN DATA#

dat <- read.csv('C:/Users/Andrew/Documents/Georgia Tech/ISYE6242/6242data/Jon_Lester_pitch_probs.csv')

dat$pitcher = "Jon Lester"
dat$balls = dat$b_count
dat$strikes = dat$s_count
dat$runner1 = as.integer(as.logical(dat$on_1b))
dat$runner2 = as.integer(as.logical(dat$on_2b))
dat$runner3 = as.integer(as.logical(dat$on_3b))

dat$previouspitch = dat$prev_pitch_class

updated_dat <- dat  %>% select(pitcher, balls, strikes, outs, runner1, runner2, runner3, model,
                               fastball, offspeed, breaking, 
                               previouspitch)



left_joined <- left_join(updated_dat, full_frame, by = c("balls" = "b_count", "strikes" = "s_count", "outs" = "outs", "runner1" = "runner1", "runner2" = "runner2", "runner3" = "runner3"))


final<- left_joined  %>% select(pitcher, balls, strikes, outs, runner1, runner2, runner3, model,
                               fastball, offspeed, breaking, location_1, location_2, location_3, location_4,
                               location_5, location_6, location_7, location_8, location_9,
                               previouspitch)


write.csv(final, 'C:/Users/Andrew/Documents/Georgia Tech/ISYE6242/6242data/test_load.csv')

library(RMariaDB)
# 
# 
# db_name <- "stats_main"
# db_user <- "admin"
# db_password <- "cSe6242!"
# db_host <- "baseball.cfape4saa0af.us-east-1.rds.amazonaws.com"
# db_port <- 3306
# 
# con <- dbConnect(
#   MariaDB(),
#   dbname = db_name,
#   username = db_user,
#   password = db_password,
#   host = db_host,
#   port = db_port
# )
# 
# 
# for (i in 1:nrow(updated_dat)) {
  con <- dbConnect(
    MariaDB(),
    dbname = db_name,
    username = db_user,
    password = db_password,
    host = db_host,
    port = db_port
  )
  dbSendQuery(con, 'set character set "utf8"')
  dbSendQuery(con, 'SET NAMES utf8')
  query <- paste0("INSERT INTO predictions VALUES(99999,'Test',1,2,3,4,5,6,'words',.75,.88,.99,1,2,3,4,5,6,7,8,9,99)")
  print(query)
  RMariaDB::dbSendQuery(con, query)
  dbDisconnect(con)
#   
# }