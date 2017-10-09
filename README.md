# R language
## Compare two WiFi networks on a Windows machine.

### Purpose
Provides R code that compares the relative speeds of two competing WiFi networks on a Windows machine. . Written for fun more than anything else.

### Background
This script was written to compare the **ping** performance of a standard home WiFi connection and the equivalent supplied from the same router via a signal extender. It can be used to compare two standard WiFi networks though.

### Assumptions

- You have the log in credentials to your network saved locally. The script will connect and reconnect to WiFi networks using `netsh wlan` for you. 
- You are *somewhat* controlling for confounding variables like network traffic.

Use `netsh wlan show profiles` to see all of the networks you have used on your local machine. Add `key=clear` to see the respective WiFi passwords saved on your machine in plain text!

### Misc

This was written in between making dinner and washing up, so there are many ways it can be improved in terms of the R syntax, the design of the experiment and the range of tools used. I also considered using `wmic`, for instance:

`wmic NIC where NetEnabled=true get Name, Speed`

But I couldn't seem to get enough variability out of it. I'm also aware there are libraries like `network`, but again, that's not fun.

## How to use it.

Install dependencies:

```r
install.packages("data.table")
```

Set your input variables:

```r
wifiRouter <- "Router"
wifiExtender <- "Extender"

loci <- c("Lounge", "Kitchen", "Stairs")
host <- "www.google.com" # or just ip.

noPings <- 150
```

Get useful functions:

```r
source("functions.r")
```

Run the `lapply` command and answer the prompt in between each location:

```r
dfList <- lapply(loci, ufnApplyAll)
```

Collect the results.

### Sample output

While the names have been the changed, the data is real. It seems my extender experiences more dropouts that its routed counterpart, and also has a higher average ping time to Google. Luckily it's barely noticable!

Minimum|Maximum|Average|PacketsLost|Pings|Website|Location|Network
-------|-------|-------|-------|-------|-------|-------|-------
7|116|17|1|150|www.google.com|Lounge|Router
10|391|31|10|150|www.google.com|Lounge|Extender
6|126|19|0|150|www.google.com|Kitchen|Router
11|364|35|5|150|www.google.com|Kitchen|Extender
7|133|16|1|150|www.google.com|Stairs|Router
12|338|32|11|150|www.google.com|Stairs|Extender

All of the ping data is printed to the user in the script, so if you feel like extracting the rest then go for it.

### Fun stuff

If you want a proper HTML report of your WiFi stats, run this on a command prompt as an administrator:

`netsh wlan show wlanreport`