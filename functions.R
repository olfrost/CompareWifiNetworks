ufnWifiAction <- function(action, profile = NULL) {
  
  if(is.null(profile) & action == "connect") {
    warning("Bad combination of paramaters.")
    return(NULL)
  }
  
  # Generate command and print.
  command <- ifelse(
    test = is.null(profile), 
    yes = sprintf("netsh wlan %s", action),
    no = sprintf("netsh wlan %s %s", action, profile)
  )
  
  cat(paste("Running the following command: ", command, "\r\n"))
  
  # Run command.
  output <- system(command, intern = TRUE)
  
  return(output)
  
}

ufnWifiPing <- function(noPings, timeout = pingTimeout, site = host, location, network) {
  
  # Printing:
  cat("Pinging...please wait...\r\n")
  
  # Get ping data.
  command = paste("ping -w", timeout, "-n", noPings, site)
  data = system(command, intern = TRUE)
  
  # Output to user.
  cat("Data collected:\r\n")
  cat(paste0(data, "\r\n", collapse = "\r\n"))
  
  # Clean the output and get the last row only for summary stats:
  lastRowInd = noPings + 7
  bytesSentRowInd = 2
  packetsLostInd = noPings + 5
  
  lastRow = strsplit(trimws(data[lastRowInd]), ", ")[[1]]
  packetsLost = strsplit(trimws(data[packetsLostInd]), ", ")[[1]]
  
  df = data.frame(
    Minimum = ufnClean(gsub("Minimum = ", "", lastRow[1])),
    Maximum = ufnClean(gsub("Maximum = ", "", lastRow[2])),
    Average = ufnClean(gsub("Average = ", "", lastRow[3])),
    PacketsLost = ufnClean(gsub("\\(.+\\).$", "", gsub("Lost = ", "", packetsLost[3]))),
    Pings = noPings, 
    Website = site, 
    Location = location,
    Network = network
  )
  
  # Return the final table.
  return(df)
  
}

ufnSwitchNetworks <- function(to){
  
  # Disconnect.
  ufnWifiAction("disconnect")
  
  # Decide which network to join.
  if(to == wifiRouter) {
    output = ufnWifiAction(action = "connect", profile = wifiRouter)
  } else {
    output = ufnWifiAction(action = "connect", profile = wifiExtender)
  }
  
  return(output)
  
}

ufnTest <- function(noPings = noPings, location) {
  
  # Variables from outer scope without passing as params. Naughty me.
  # Sleep for 5 seconds in between to give it time to reconnect.
  ufnSwitchNetworks(wifiExtender); print("Sleeping for 5 seconds:"); Sys.sleep(5);
  extender = ufnWifiPing(noPings = noPings, location = location, network = wifiExtender)
  
  ufnSwitchNetworks(wifiRouter); print("Sleeping for 5 seconds:"); Sys.sleep(5);
  router = ufnWifiPing(noPings = noPings, location = location, network = wifiRouter)
  
  return(rbind(router, extender))
  
}

ufnApplyAll <- function(x){
  
  # Prompt user.
  # This will wait for your signal before carrying on into the next room.
  # Sadly it can't walk for you.
  promptUser = readline(prompt = "Are you ready, geez? (Y/N):")
  
  if(tolower(promptUser) %in% c("yes", "ye", "y", "yep", "ya", "yarp", "k", "kk", "yeah")) {
    
    # Better error handling needed here, really.
    return(ufnTest(noPings = noPings, location = x))
    
  } else {
    
    return(data.frame())
    
  }
}

ufnClean <- function(x){
  return(as.numeric(trimws(gsub("ms", "", x))))
}