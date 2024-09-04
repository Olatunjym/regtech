# Use the official Node.js image.
# https://hub.docker.com/_/node
FROM node:16

# Create and set the working directory
WORKDIR /usr/src/app

# Copy the package.json and package-lock.json
COPY package*.json ./

# Install app dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the app on port 8080
EXPOSE 8080

# Start the app
CMD [ "npm", "start" ]
