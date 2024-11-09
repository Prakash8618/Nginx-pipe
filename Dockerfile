# Use the official NGINX base image
FROM nginx:latest

# Copy the packaged HTML files from the Maven target directory to NGINX's HTML directory
COPY target/my-nginx-webapp*.war /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start NGINX server
CMD ["nginx", "-g", "daemon off;"]
