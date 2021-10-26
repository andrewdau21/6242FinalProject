#install.packages('RMariaDB')
#install.packages('Rcpp')
library(RMariaDB)


db_name <- "stats_main"
db_user <- "admin"
db_password <- "checkwithandrew"
db_host <- "baseball.cfape4saa0af.us-east-1.rds.amazonaws.com"
db_port <- 3306


conn <- dbConnect(
  MariaDB(),
  dbname = db_name,
  username = db_user,
  password = db_password,
  host = db_host,
  port = db_port
)

rs <- dbSendQuery(conn, "SELECT * FROM test_table")
d1 <- dbFetch(rs, n = 10) # extract data in chunks of 10 rows
dbHasCompleted(rs)
d2 <- dbFetch(rs, n = -1) # extract all remaining data
dbHasCompleted(rs)
dbClearResult(rs)
dbListTables(conn)
# clean up
dbDisconnect(conn)
