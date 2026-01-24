#!/bin/bash

# Inception Project - Complete Setup Script
# Sets up all required directories and containers

echo "========================================="
echo "Inception Project Setup Starting..."
echo "========================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Error checking function
check_error() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Error: $1${NC}"
        exit 1
    fi
}

# 1. Create data directories
echo -e "${YELLOW}1. Creating data directories...${NC}"
mkdir -p /home/aozkaya/data/mariadb
mkdir -p /home/aozkaya/data/wordpress
check_error "Failed to create data directories"
echo -e "${GREEN}✓ Data directories ready${NC}"

# 2. Set file permissions
echo -e "${YELLOW}2. Setting file permissions...${NC}"
chmod 755 /home/aozkaya/data/mariadb
chmod 755 /home/aozkaya/data/wordpress
check_error "Failed to set permissions"
echo -e "${GREEN}✓ Permissions set${NC}"

# 3. Build Docker images
echo -e "${YELLOW}3. Building Docker images (this may take a while)...${NC}"
cd /home/aabdulmecitz/inception
make build
check_error "Docker build failed"
echo -e "${GREEN}✓ Docker images built${NC}"

# 4. Start containers
echo -e "${YELLOW}4. Starting containers...${NC}"
make up
check_error "Failed to start containers"
echo -e "${GREEN}✓ Containers started${NC}"

# 5. Wait for MariaDB to start
echo -e "${YELLOW}5. Waiting for MariaDB to start (max 30 seconds)...${NC}"
COUNTER=0
while [ $COUNTER -lt 30 ]; do
    if docker exec inception-mariadb-1 mariadb -u aozkaya -p'gizlisifre' -e "SELECT 1" wordpress &>/dev/null; then
        echo -e "${GREEN}✓ MariaDB started successfully${NC}"
        break
    fi
    echo "Waiting... ($COUNTER/30)"
    sleep 1
    COUNTER=$((COUNTER + 1))
done

if [ $COUNTER -eq 30 ]; then
    echo -e "${RED}⚠ MariaDB startup timed out${NC}"
fi

# 6. Check WordPress
echo -e "${YELLOW}6. Checking WordPress...${NC}"
sleep 10
if docker logs inception-wordpress-1 | grep -q "WordPress kurulumu tamamlandı"; then
    echo -e "${GREEN}✓ WordPress installed successfully${NC}"
else
    echo -e "${YELLOW}ℹ WordPress starting, check in browser${NC}"
fi

# 7. Completion message
echo ""
echo "========================================="
echo -e "${GREEN}✓ Setup Complete!${NC}"
echo "========================================="
echo ""
echo "📌 Access Addresses:"
echo "   🌐 WordPress: https://aozkaya.42.fr"
echo "   🗄️  MariaDB:   localhost:3306"
echo ""
echo "📝 Admin Credentials:"
echo "   Username: admin"
echo "   Password: adminsifresi"
echo "   Email: admin@student.42.fr"
echo ""
echo "📋 Helper Commands:"
echo "   make up       - Start containers"
echo "   make down     - Stop containers"
echo "   make clean    - Remove containers and images"
echo "   make fclean   - Complete cleanup"
echo "   make re       - Rebuild everything"
echo ""
echo "🐳 Docker Commands:"
echo "   docker compose -p inception -f srcs/docker-compose.yml logs -f"
echo "   docker exec -it inception-nginx-1 bash"
echo "   docker exec -it inception-wordpress-1 bash"
echo "   docker exec -it inception-mariadb-1 bash"
echo ""
echo "========================================="
