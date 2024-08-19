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

# Check if the custom lines are already present
if ! grep -q "define('WP_HOME', 'http://localhost:${WORDPRESS_PORT}');" /var/www/html/wp-config.php; then
    # Insert custom lines before the specific line
    sed -i "/\/\* That's all, stop editing! Happy publishing. \*\//i \\
    define('WP_HOME', 'http://localhost:${WORDPRESS_PORT}');\\n\
    define('WP_SITEURL', 'http://localhost:${WORDPRESS_PORT}');\\n\
    define('REMOTE_MEDIA_URL', 'https://${WORDPRESS_URL}');\\n\
    \\n\
    ob_start('ob_replace_home_url');\\n\
    function ob_replace_home_url(\$content)\\n\
    {\\n\
        \$home_urls = array(\\n\
            'https://${WORDPRESS_URL}',\\n\
            'http://${WORDPRESS_URL}',\\n\
        );\\n\
        \\n\
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
