# Build stage
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Upgrade system packages to fix vulnerabilities
RUN apk update && apk upgrade --no-cache

# Copy built application from build stage
COPY --from=build /app/dist .

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
