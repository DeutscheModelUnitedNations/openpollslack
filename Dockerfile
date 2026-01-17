# ============================================
# Stage 1: Install all dependencies
# ============================================
FROM node:20-alpine AS deps

WORKDIR /app

# Install dependencies only (leverages Docker cache)
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# ============================================
# Stage 2: Production dependencies only
# ============================================
FROM node:20-alpine AS prod-deps

WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production=true && \
    yarn cache clean

# ============================================
# Stage 3: Final runtime image
# ============================================
FROM node:20-alpine AS runtime

# Add labels for container registry
LABEL org.opencontainers.image.source="https://github.com/deutschemodelunitednations/openpollslack"
LABEL org.opencontainers.image.description="DMUN-Poll - Polling app for Slack"
LABEL org.opencontainers.image.licenses="GPL-3.0-or-later"

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create app directory
WORKDIR /app

# Copy production dependencies from prod-deps stage
COPY --from=prod-deps /app/node_modules ./node_modules

# Copy application source
COPY package.json ./
COPY index.js ./
COPY utils ./utils
COPY assets ./assets
COPY index.html ./
COPY privacy ./privacy
COPY tos ./tos
COPY scripts ./scripts
COPY config/default.json.dist ./config/default.json.dist
COPY config/custom-environment-variables.json ./config/custom-environment-variables.json

# Create default config from dist (can be overridden by env vars or volume mount)
RUN cp config/default.json.dist config/default.json

# Set ownership to node user
RUN chown -R node:node /app

# Switch to non-root user
USER node

# Expose the application port
EXPOSE 5000

# Health check using the /ping endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:5000/ping || exit 1

# Use dumb-init as entrypoint for proper signal handling
ENTRYPOINT ["dumb-init", "--"]

# Start the application
CMD ["node", "index.js"]
