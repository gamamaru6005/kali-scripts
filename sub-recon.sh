#!/bin/bash

# This script uses well-known subdomain enumeration tools.
# Wordlist is created on the fly by combining a good list with addiiontal words from target's website.
# Output is formatted in a way I prefer.

########    PLEASE SET UP VARIABLES HERE    ########
OUTDIR=/root/bounties           # We will create subfolders for each domain here
SLDIR=/opt/SecLists             # Download SecLists and place it here
EADIR=/opt/enumall              # Download enumall.py and place it here (make sure to configure it)
########    YAY, ALL DONE WITH VARIABLES    ########

read -p 'Enter TLD for subdomain enumeration (example: uber.com): ' RECON_DOMAIN
read -p 'Enter full URL to scrape a wordlist from (example: https://uber.com/au) ' RECON_URL

# set up the directory structure
mkdir -p $OUTDIR/$RECON_DOMAIN/dns-recon

# change into dir - as output files from enumall go to local dir
cd $OUTDIR/$RECON_DOMAIN/dns-recon

# create a custom wordlist combining a scrape of the full URL plus a nice hefty SecLists file
cewl --depth 1 -m 4 $RECON_URL \
  -w $OUTDIR/$RECON_DOMAIN/cewl-wordlist.txt
cat $SLDIR/Discovery/DNS/sorted_knock_dnsrecon_fierce_recon-ng.txt \
  $OUTDIR/$RECON_DOMAIN/cewl-wordlist.txt \
  > /tmp/wordlist.txt

# run the consolidated recon
python $EADIR/enumall.py $RECON_DOMAIN -w /tmp/wordlist.txt

# try a DNS zone transfer
for i in $(host -t ns $RECON_DOMAIN | cut -d " " -f 4); \
  do host -l $RECON_DOMAIN $i \
  >> $OUTDIR/$RECON_DOMAIN/dns-recon/zone-transfer.txt; \
done

# remove out of scope domains
cat $RECON_DOMAIN.csv | grep $RECON_DOMAIN \
 > $OUTDIR/$RECON_DOMAIN/dns-recon/$RECON_DOMAIN-scope.csv

# make a list of all unique hostnames
cat $RECON_DOMAIN-scope.csv | cut -d '"' -f 2 | sort | uniq -i | grep $RECON_DOMAIN \
  > $OUTDIR/$RECON_DOMAIN/dns-recon/hostnames.txt

# make a list of all unique IP addresses
cat $RECON_DOMAIN-scope.csv | cut -d '"' -f 4 | grep . | sort | uniq -i \
  > $OUTDIR/$RECON_DOMAIN/dns-recon/ip-list.txt

# make a list of IP addresses with DNS count
cat $RECON_DOMAIN-scope.csv | cut -d '"' -f 4 | grep . | sort | uniq -i -c \
  | cut -d ' ' -f 7- \
  > $OUTDIR/$RECON_DOMAIN/dns-recon/ip-count.txt
