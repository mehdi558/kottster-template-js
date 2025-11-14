# --- BUILD STAGE ---
FROM node:22-alpine AS builder

WORKDIR /app

# Install git + tini
RUN apk add --no-cache git

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy app source
COPY . .

# Build front + server
RUN npm run build

# --- RUNTIME STAGE ---
FROM node:22-alpine

WORKDIR /app

# Copy built app
COPY --from=builder /app /app

# Install tini
RUN apk add --no-cache tini

# Expose ports
EXPOSE 5480 5481

# Environment
ENV PORT=5480
ENV DEV_API_SERVER_PORT=5481
ENV VITE_DOCKER_MODE=true

# Copy scripts
COPY scripts/dev.sh /dev.sh
COPY scripts/prod.sh /prod.sh
RUN chmod +x /dev.sh /prod.sh

ENTRYPOINT ["/sbin/tini", "--"]

# Start production server
CMD ["/dev.sh"]
