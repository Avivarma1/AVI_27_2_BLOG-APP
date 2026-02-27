# Frontend Dockerfile

# Stage 1: Build
FROM node:18-alpine AS build

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Stage 2: Production image
FROM nginx:alpine

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built files from build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Create non-root user with different GID to avoid conflict
RUN addgroup -g 1001 -S nginx_user && \
    adduser -S nginx_user -u 1001 -G nginx_user

# Change ownership
RUN chown -R nginx_user:nginx_user /usr/share/nginx/html && \
    chown -R nginx_user:nginx_user /etc/nginx

USER nginx_user

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
