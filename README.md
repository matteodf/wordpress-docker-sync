# WordPress Docker Sync

## Overview

**WordPress Docker Sync** is a Docker-based setup designed to enhance your WordPress development workflow, offering a better environment for local WordPress development that synchronizes with your online staging environment, improving efficiency and reducing waste of time.

## Prerequisites

- **Docker** and **Docker Compose** installed on your machine.
- A basic understanding of Docker and WordPress configuration.

## Getting Started

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/matteodf/wordpress-docker-sync.git
   cd wordpress-docker-sync
   ```

2. **Configure the Environment**:

   Copy the `.env.sample` file to `.env`:

   ```bash
   cp .env.sample .env
   ```

   This file contains the port number you would like to use for your WordPress instance.

   Copy the `.env.your-name.sample` file to `.env.your-name`:

   ```bash
   cp .env.your-name.sample .env.your-name
   ```

   Update the `.env.your-name` file with your WordPress and database settings.

3. **Make the script executable**:

   ```bash
   chmod +x change-url.sh
   ```

4. **Start the Docker Container**:

   ```bash
   docker compose up your-name
   ```

   This command initiates the WordPress container as per the configuration in `docker-compose.yml`.

5. **Access Your WordPress Site**:
   Open your browser and navigate to `http://localhost:<DOCKER_PORT>`.

Note: remember to change 'your-name' to the name of your service.

## File Synchronization and Environment Management

- The `./wordpress` directory on your host machine is mounted to `/var/www/html` within the container, ensuring any changes made locally are immediately reflected in the WordPress instance.
- This setup also allows for the creation of multiple environments by duplicating services in the `docker-compose.yml` file and using distinct `.env` configurations.

## Custom URL Handling

The `change-url.sh` script automates the updating of the WordPress URL configuration to match your local environment. It modifies the `wp-config.php` file to correctly set `WP_HOME` and `WP_SITEURL`, ensuring smooth operation when working across different environments.

## Environment Variables

### .env

- `DOCKER_PORT`: The port on which your WordPress instance will be accessible.

### .env.your-name

- `WORDPRESS_DB_NAME`: The name of your WordPress database.
- `WORDPRESS_TABLE_PREFIX`: The prefix for your WordPress database tables.
- `WORDPRESS_DB_HOST`: The database host.
- `WORDPRESS_DB_USER`: The database user.
- `WORDPRESS_DB_PASSWORD`: The password for the database user.
- `WORDPRESS_URL`: The base URL of the WordPress site, usually the staging environment.

## Advanced Usage

### Managing Multiple Environments

To manage multiple environments, duplicate the service definitions in `docker-compose.yml` and create corresponding `.env.your-other-name` files with database credentials. This method ensures that each environment operates independently while sharing the same Docker infrastructure.

### Handling Media Files

To prevent issues with media files when switching between local and staging environments, the `change-url.sh` script replaces staging URLs with local URLs, except for files in the `wp-content/uploads` directory. For enhanced media management, consider using [this small plugin](https://github.com/matteodf/custom-media-replacer) to block media uploads on your local server, ensuring all uploads happen on the staging server.

### Plugin and Theme Synchronization

While this setup simplifies environment management, it's important to manually ensure that necessary plugins and themes are installed and activated in both local and staging environments to avoid inconsistencies.

## More Information

You can find more information on my blog post at [https://matteodefilippis.com/blog/speed-up-wordpress-docker/](https://matteodefilippis.com/blog/speed-up-wordpress-docker/)

## License

This project is licensed under the [GNU General Public License v3](https://www.gnu.org/licenses/gpl-3.0).

## Contributing

Contributions, issues, and feature requests are welcome! Feel free to check out the [issues page](https://github.com/matteodf/wordpress-docker-sync/issues).
