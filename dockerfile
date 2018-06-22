FROM syslog-base:latest

# Copy the main script
COPY cb_defense_syslog.py /

# Copy over a conf file
COPY root/etc/cb/integrations/cb-defense-syslog/cb-defense-syslog.conf.example /vol/cb-defense-syslog.conf

# Add crontab file in the cron directory
COPY vol/crontab /etc/cron.d/cb-defense-syslog

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/cb-defense-syslog

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

RUN mkdir /vol/store

# Run the command on container startup
# CMD cron && tail -f /var/log/cron.log

CMD ["cron", "-f"]
