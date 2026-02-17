# Strapi v5 recommended Node LTS 
FROM node:18-alpine

WORKDIR /app

# Required build tools
RUN apk add --no-cache \
  python3 \
  make \
  g++

# Copy dependency files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy app source
COPY . .

# Build admin panel
RUN npm run build

# Expose Strapi port
EXPOSE 1337

# Start Strapi
CMD ["npm", "run", "start"]
