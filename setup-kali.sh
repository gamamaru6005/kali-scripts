#!/bin/bash

##### NOTE: RUN THIS FROM A TERMINAL WIHIN A GUI SESSION (WINE DEPS) ####

echo 'Setting a new root password...'
passwd

read -p "Let's set a new hostname: " HOSTNAME
echo "Setting the hostname to $HOSTNAME - kali sounds shady in logs..."
echo $HOSTNAME > /etc/hostname
hostname $HOSTNAME

echo 'Installing the discovery scripts, which also updates the distro...'
git clone https://github.com/leebaird/discover.git /opt/discover
cd /opt/discover && ./update.sh
# cd /opt                                                                                             # optional
# wget https://neo4j.com/artifact.php?name=neo4j-community-3.2.5-unix.tar.gz -O ./neo4j.tar.gz        # optional
# tar -xf ./neo4j.tar.gz                                                                              # optional
# rm -f ./neo4j.tar.gz                                                                                # optional

echo 'Configuring Veil framework...'
# Note: already installed in the discovery script above. If not, you can run:
# git clone https://github.com/Veil-Framework/Veil.git /opt/Veil
cd /opt/Veil/setup
./setup.sh -c

echo 'Preparing Metasploit...'
systemctl enable postgresql; systemctl start postgresql
msfdb init
echo exit | msfconsole                                                 # sets up the needed .msf4 folder
echo "spool /root/msf_console.log" > /root/.msf4/msfconsole.rc         # enables logging of all msf activity

echo 'Setting up Docker...'
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
echo "deb https://download.docker.com/linux/debian stretch stable" >> /etc/apt/sources.list 
apt update
apt install docker-ce -y

# Set directory to store custom scripts
mkdir /root/scripts

echo 'cloning some good repos from github...'
git clone https://github.com/danielmiessler/SecLists.git /opt/SecLists
git clone https://github.com/jhaddix/domain; /opt/enumall
git clone https://github.com/wireghoul/graudit.git /opt/graudit
git clone https://github.com/Dionach/CMSmap /opt/CMSmap
git clone https://github.com/MooseDojo/praedasploit /opt/praedasploit
git clone https://github.com/tcstool/NoSQLMap.git /opt/NoSQLMap
git clone https://github.com/pentestgeek/phishing-frenzy.git /var/www/phishing-frenzy
git clone https://github.com/macubergeek/gitlist.git /opt/gitlist
git clone https://github.com/DanMcInerney/net-creds.git /opt/net-creds
git clone https://github.com/mattifestation/PowerSploit.git /opt/PowerSploit
cd /opt/PowerSploit && wget https://raw.githubusercontent.com/obscuresec/random/master/StartListener.py && wget https://raw.githubusercontent.com/darkoperator/powershell_scripts/master/ps_encoder.py
git clone https://github.com/samratashok/nishang /opt/nishang

echo 'installing tools with easy installs...'
apt install wifiphisher -y
gem install aquatone

echo 'Installing HTTPScreenShot...'
apt install python-selenium -y
git clone https://github.com/breenmachine/httpscreenshot.git /opt/httpscreenshot
cd /opt/httpscreenshot
chmod 700 install-dependencies.sh && ./install-dependencies.sh

echo 'Installing some messy requirements for smbexec...'
cd /tmp
wget https://github.com/libyal/libesedb/releases/download/20170121/libesedb-experimental-20170121.tar.gz
tar -xzvf ./libesedb-experimental-20170121.tar.gz
cd libesedb-20170121
CFLAGS="-g -O2 -Wall -fgnu89-inline" ./configure --enable-static-executables
make
mv esedbtools /opt/esedbtools

echo 'Installing smbexec...'
git clone https://github.com/brav0hax/smbexec.git /opt/smbexec
wget https://github.com/interference-security/ntds-tools/raw/master/ntdsxtract_v1_0.zip -O /tmp/ntds.zip
unzip /tmp/ntds.zip -d /tmp/
mv "/tmp/NTDSXtract 1.0" /opt/NTDSXtract
apt-get install automake autoconf autopoint gcc-mingw-w64-x86-64 libtool pkg-config
echo 1 | /opt/smbexec/install.sh

echo 'installing gitrob...'
apt install libpq-dev -y
git clone https://github.com/michenriksen/gitrob.git /opt/gitrob
gem install bundler
runuser -l postgres -c 'createuser -s gitrob --pwprompt'
runuser -l postgres -c 'createdb -O gitrob gitrob'
cd /opt/gitrob/bin
gem install gitrob

echo 'installing BeEF'
cd /opt/
wget https://raw.githubusercontent.com/beefproject/beef/a6a7536e/install-beef
chmod 700 ./install-beef
echo y | ./install-beef
rm -f ./install-beef

echo 'Getting DSHashes script...'
cd /tmp
wget https://storage.googleapis.com/google-code-archive-source/v2/code.google.com/ptscripts/source-archive.zip
unzip ./source-archive.zip
mkdir /opt/NTDSXtract
cp /tmp/ptscripts/trunk/dshashes.py /opt/NTDSXtract/

echo 'installing spiderfoot...'
wget http://sourceforge.net/projects/spiderfoot/files/spiderfoot-2.3.0-src.tar.gz/download -O /tmp/spider.tar.gz
tar xzvf /tmp/spider.tar.gz -C /opt/
pip install lxml
pip install netaddr
pip install M2Crypto
pip install cherrypy
pip install mako
rm -f /tmp/spider.tar.gz

echo 'Installing a flash decompiler...'
cd /tmp
wget https://www.free-decompiler.com/flash/download/ffdec_10.0.0.deb
apt install ./ffdec_10.0.0.deb -y
rm -f ./ffdec_10.0.0.deb
mkdir /opt/flash-stuff; cd /opt/flash-stuff
wget https://fpdownload.macromedia.com/get/flashplayer/updaters/27/playerglobal27_0.swc

echo 'Getting some scripts from the Hackers Playbook'
git clone https://github.com/cheetz/Easy-P.git /opt/easy-p
git clone https://github.com/cheetz/Password_Plus_One /opt/password_plus_one
git clone https://github.com/cheetz/PowerShell_Popup /opt/powershell_popup
git clone https://github.com/cheetz/icmpshock /opt/icmpshock
git clone https://github.com/cheetz/brutescrape /opt/brutescrape
git clone https://www.github.com/cheetz/reddit_xss /opt/reddit_xss

echo 'Getting some of my forked versions...'                                      # If you're not me, fork from original
git clone https://github.com/initstring/PowerSploit.git /opt/forked_powersploit
git clone https://github.com/initstring/PowerTools.git /opt/forked_powertools
git clone https://github.com/initstring/nishang.git /opt/forked_nishang
