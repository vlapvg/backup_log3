#!/bin/bash

# Настройка реплики для MySQL для replica сервера

set -e  # Выход при ошибке

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Настройка MySQL Slave для репликации ===${NC}"

# Проверка прав
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Ошибка: Скрипт должен запускаться с правами root${NC}"
    exit 1
fi

# Проверка установки MySQL
if ! systemctl is-active --quiet mysql; then
    echo -e "${YELLOW}Предупреждение: MySQL служба не запущена${NC}"
    read -p "Запустить MySQL? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        systemctl start mysql
    else
        echo -e "${RED}MySQL должен быть запущен для настройки репликации${NC}"
        exit 1
    fi
fi

# Параметры подключения к мастеру
MASTER_HOST="192.168.1.133"
REPL_USER="repl"
REPL_PASSWORD="oTUSlave#2020"

echo "Проверка подключения к мастеру $MASTER_HOST..."
if ! ping -c 1 -W 2 $MASTER_HOST &> /dev/null; then
    echo -e "${RED}Ошибка: Нет подключения к мастеру $MASTER_HOST${NC}"
    exit 1
fi

echo "Настройка репликации..."
mysql -e "CHANGE REPLICATION SOURCE TO \
    SOURCE_HOST='$MASTER_HOST', \
    SOURCE_USER='$REPL_USER', \
    SOURCE_PASSWORD='$REPL_PASSWORD', \
    SOURCE_AUTO_POSITION = 1, \
    GET_SOURCE_PUBLIC_KEY = 1;"

if [ $? -ne 0 ]; then
    echo -e "${RED}Ошибка при настройке репликации${NC}"
    exit 1
fi

echo "Запуск реплики..."
mysql -e "START REPLICA;"

echo "Проверка статуса репликации..."
sleep 2  # Даем время на старт

slave_status=$(mysql -e "SHOW REPLICA STATUS\G")

# Проверка ключевых параметров
if echo "$slave_status" | grep -q "Replica_IO_Running: Yes" && \
   echo "$slave_status" | grep -q "Replica_SQL_Running: Yes"; then
    echo -e "\n${GREEN}Репликация успешно запущена!${NC}"
    echo -e "${GREEN}IO Thread: Running${NC}"
    echo -e "${GREEN}SQL Thread: Running${NC}"
else
    echo -e "\n${YELLOW}Статус репликации требует проверки:${NC}"
    echo "$slave_status" | grep -E "(Replica_IO_Running|Replica_SQL_Running|Last_IO_Error|Last_SQL_Error)"
fi

echo -e "\n${GREEN}=== Настройка реплики завершена ===${NC}"
