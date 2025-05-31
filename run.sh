#!/bin/bash
echo "🔍 Checking & Updating libraries..."
echo "🔁 Since this is the first time, it will take a while to install. Please wait..."
install_node18() {
    sudo apt purge -y nodejs npm > /dev/null 2>&1
    sudo apt autoremove -y > /dev/null 2>&1
    sudo apt update > /dev/null 2>&1
    sudo apt install -y curl ca-certificates > /dev/null 2>&1
    if [ ! -f /etc/ssl/certs/ca-certificates.crt ]; then
        sudo apt install --reinstall ca-certificates -y > /dev/null 2>&1
        sudo update-ca-certificates > /dev/null 2>&1
    fi
    if ! curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - > /dev/null 2>&1; then
        echo "❌ Error while downloading Node.js!"
        exit 1
    fi
    sudo apt install -y nodejs > /dev/null 2>&1
}
if ! command -v node &> /dev/null; then
    install_node18
else
    NODE_VERSION=$(node -v | cut -d 'v' -f 2)
    NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d '.' -f 1)
    if [ "$NODE_MAJOR" -ne 18 ]; then
        install_node18
    fi
fi
if ! command -v cmake &> /dev/null; then
    sudo apt update > /dev/null 2>&1
    sudo apt install -y cmake > /dev/null 2>&1
fi
required_packages=(build-essential python3 make g++ git)
missing_packages=()
for pkg in "${required_packages[@]}"; do
    dpkg -s "$pkg" &> /dev/null || missing_packages+=("$pkg")
done
if [ ${#missing_packages[@]} -ne 0 ]; then
    sudo apt update > /dev/null 2>&1
    sudo apt install -y "${missing_packages[@]}" > /dev/null 2>&1
fi

# Kiểm tra & cài đặt node-gyp
if ! command -v node-gyp &> /dev/null; then
    npm install -g node-gyp > /dev/null 2>&1
fi
if ! command -v npm &> /dev/null; then
    sudo apt install -y npm > /dev/null 2>&1
else
    sudo npm install -g npm@latest > /dev/null 2>&1
fi
[ ! -f package.json ] && npm init -y > /dev/null 2>&1
packages=("bedrock-protocol" "readline-sync" "node-machine-id")
for pkg in "${packages[@]}"; do
    npm install "$pkg@latest" > /dev/null 2>&1
done
echo "🚀 Running Minecraft Bedrock bot..."
node --no-warnings index.js