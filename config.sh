#!/bin/bash
# Copy this file to "config.sh" and modify it to suit your needs
export IONO_CONFIG="./config/rb1311_prn.ini"
# export IONO_CONFIG="./config/rb1311_barker.ini"
# export IONO_CONFIG="./config/rb1311_nick.ini"
# export IONO_CONFIG_OBLIQUE="./config/rb1311_prn.ini"
export IONO_CONFIG_OBLIQUE="./config/rb1311_barker.ini"

export PYTHONPATH="/gnuradio/gr3.10/local/lib/python3.10/dist-packages:/usr/local/lib/python3/dist-packages/"

# to get the following to work as a non-root user add:
#
# ionosonde_user ALL = NOPASSWD: /sbin/sysctl -w net.core.?mem_max*
#
# to /etc/sudoers.d/ionosonde_user or /etc/sudoers
#
sudo sysctl -w net.core.rmem_max=500000000
sudo sysctl -w net.core.wmem_max=25000000

