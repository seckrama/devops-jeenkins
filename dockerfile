# Utiliser l'image Node.js officielle
FROM node:18-alpine

# Créer le répertoire de travail
WORKDIR /app

# Copier package.json et package-lock.json
COPY package*.json ./

# Installer les dépendances
RUN npm install

CMD ["npm", "start"]


# Copier le reste du code
COPY . .

# Exposer le port 3000
EXPOSE 3000

# Démarrer l'application
CMD ["npm", "start"]