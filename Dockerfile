FROM mcr.microsoft.com/windows/servercore:1803 as installer

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';$ProgressPreference='silentlyContinue';"]


RUN Invoke-WebRequest -OutFile nodejs.zip -UseBasicParsing "https://nodejs.org/dist/v18.20.2/node-v18.20.2-win-x64.zip";expand-archive nodejs.zip 

FROM mcr.microsoft.com/windows/nanoserver:1803
WORKDIR "C:\nodejs\node-v18.20.2-win-x64"
COPY --from=installer "C:\nodejs\node-v18.20.2-win-x64" .
#RUN icacls . /grant Everyone:(OI)(CI)F /T
RUN SETX PATH "C:\nodejs\node-v18.20.2-win-x64"
RUN npm config set registry https://registry.npmjs.org/
# Create app directory
# this is the location where you will be inside the container
WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
# copying packages first helps take advantage of docker layers
COPY package*.json ./

RUN npm install
# If you are building your code for production
# RUN npm ci --only=production
COPY . .
# Make this port accessible from outside the container
# Necessary for your browser to send HTTP requests to your Node app
EXPOSE 8080

# Command to run when the container is ready
# Separate arguments as separate values in the array
CMD ["node", "server.js"]
#CMD [ "npm", "run", "start"]