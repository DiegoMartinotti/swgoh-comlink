# Usar imagen oficial de Node.js
FROM node:18-alpine

# Establecer directorio de trabajo
WORKDIR /app

# Instalar git y dependencias de compilación
RUN apk add --no-cache git python3 make g++ curl

# Clonar el repositorio de swgoh-comlink
RUN git clone https://github.com/swgoh-utils/swgoh-comlink.git .

# Instalar dependencias de Node.js
RUN npm ci --only=production || npm install --production

# Crear usuario no-root para seguridad
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Cambiar propietario de los archivos
RUN chown -R nodejs:nodejs /app

# Cambiar al usuario no-root
USER nodejs

# Puerto por defecto (Railway lo sobrescribirá)
EXPOSE 3000

# Variables de entorno por defecto
ENV NODE_ENV=production \
    PORT=3000 \
    LOG_LEVEL=info \
    APP_NAME=swgoh-comlink

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:${PORT}/health || exit 1

# Comando para iniciar la aplicación
CMD ["node", "server.js"]