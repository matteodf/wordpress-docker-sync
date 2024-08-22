#!/bin/bash
set -e

# Load environment variables from .env file if not already set
export $(grep -v '^#' /usr/local/bin/.env | xargs)

# Run the original entrypoint
docker-entrypoint.sh apache2-foreground &

# Wait for WordPress to be fully set up
while ! [ -f /var/www/html/wp-config.php ]; do
    sleep 1
done

# Define the lines to be added or updated
wp_home_line="define('WP_HOME', 'http://localhost:${WORDPRESS_PORT}');"
wp_siteurl_line="define('WP_SITEURL', 'http://localhost:${WORDPRESS_PORT}');"
remote_media_url_line="define('REMOTE_MEDIA_URL', 'https://${WORDPRESS_URL}');"

# Replace the lines if they exist, otherwise add them
sed -i.bak -e "/define('WP_HOME',/c\\
${wp_home_line}" \
-e "/define('WP_SITEURL',/c\\
${wp_siteurl_line}" \
-e "/define('REMOTE_MEDIA_URL',/c\\
${remote_media_url_line}" /var/www/html/wp-config.php


# Check if the custom function is already present
if grep -q "function ob_replace_home_url" /var/www/html/wp-config.php; then
    # If the function is present, replace the WORDPRESS_URL in the home_urls array
    sed -i "/function ob_replace_home_url/,/return \\$content;/s|'http[s]*://[^']*'|'http://${WORDPRESS_URL}'|g" /var/www/html/wp-config.php
else
    # Insert custom function before the specific line if it's not present
    sed -i "/\/\* That's all, stop editing! Happy publishing. \*\//i \\
    ob_start('ob_replace_home_url');\\n\
    function ob_replace_home_url(\$content)\\n\
    {\\n\
        \$home_urls = array(\\n\
            'https://${WORDPRESS_URL}',\\n\
            'http://${WORDPRESS_URL}',\\n\
        );\\n\
        \\n\
        \$remote_media_url = REMOTE_MEDIA_URL;\\n\
        \\n\
        foreach (\$home_urls as \$home_url) {\\n\
            \$content = preg_replace_callback(\\n\
                \"~\$home_url/(?!wp-content/uploads)~\",\\n\
                function (\$matches) use (\$remote_media_url) {\\n\
                    return str_replace(\$matches[0], WP_HOME, \$matches[0]);\\n\
                },\\n\
                \$content\\n\
            );\\n\
        }\\n\
        \\n\
        return \$content;\\n\
    }\\n\
    " /var/www/html/wp-config.php
fi

# Keep the container running
wait
