# Development Dockerfile
FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ALL dependencies (including dev dependencies for nest CLI)
RUN npm install

# Copy source code
COPY . .

# Expose port
EXPOSE 3000

# Start development server with watch mode
CMD ["npm", "run", "start:dev"]

