library(data.table)

# 0. Make script dynamic. -------------------------------------------------
wifiRouter <- "Router"
wifiExtender <- "Extender"

loci <- c("Lounge", "Kitchen", "Stairs")
host <- "www.google.com" # or just ip.

noPings <- 150
pingTimeout <- 500 # ms

# 1. Source functions. ----------------------------------------------------
source("functions.r")

# 2. Start testing. -------------------------------------------------------
dfList <- lapply(loci, ufnApplyAll)
df <- data.table::rbindlist(dfList)

# 3. Extra stuff ----------------------------------------------------------
df$PercentageLoss <- df$PacketsLost / df$Pings

# 4. All done. ------------------------------------------------------------
View(df)




