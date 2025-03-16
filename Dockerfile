# Build stage
FROM node:20-alpine AS build
WORKDIR /app

# Install dependencies with frozen lockfile for security
COPY package*.json ./
RUN npm ci --omit=dev

# Copy source files and build
COPY . .
RUN npm run build

# Production stage
FROM nginx:1.25.3-alpine  # Use a specific version to prevent unexpected updates
WORKDIR /usr/share/nginx/html

# Ensure the system is up to date before installing anything
RUN apk update && apk upgrade --no-cache

# Copy built application from build stage
COPY --from=build /app/dist .

# Optional: Add security-related headers via nginx config
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose HTTP port
EXPOSE 80

# Set non-root user for security
RUN addgroup -S nginx && adduser -S nginx -G nginx
USER nginx

# Start Nginx in foreground mode
CMD ["nginx", "-g", "daemon off;"]
