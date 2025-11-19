FROM devopsedu/webapp

# Remove Apache's default index.html to prioritize your index.php
RUN rm -f /var/www/html/index.html

# Copy your PHP website files into the container
COPY website/ /var/www/html

# Expose port 80 for web traffic
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]
