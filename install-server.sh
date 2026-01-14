apt install -y  unzip

#Install Temurin
echo "deb [arch=amd64] https://some.repository.url focal main" | sudo tee /etc/apt/sources.list.d/adoptium.list > /dev/null
apt install -y wget apt-transport-https gpg
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null
echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
apt update
apt install temurin-25-jdk temurin-25-jre -y
#CLI folder
mkdir -p /opt/hytale_server/cli
#Downloading CLI
cd /tmp
curl -fL -o hytale-downloader.zip https://downloader.hytale.com/hytale-downloader.zip
unzip -o hytale-downloader.zip -d /opt/hytale_server/cli
rm -f /opt/hytale_server/cli/hytale-downloader-windows-amd64.exe
cd /
chmod +x /opt/hytale_server/cli/hytale-downloader-linux-amd64
./opt/hytale_server/cli/hytale-downloader-linux-amd64 -download-path /opt/hytale_server/game.zip
#enter url in browser

unzip -o /opt/hytale_server/game.zip -d /opt/hytale_server/

java -jar /opt/hytale_server/Server/HytaleServer.jar --assets /opt/hytale_server/Assets.zip


