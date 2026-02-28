#!/bin/bash
# AQUAMIND - Deployment Script
# Usage: bash deploy.sh [up|down|logs|restart|clean]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="AQUAMIND"
DOCKER_COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env"
EXAMPLE_ENV_FILE=".env.example"

# Functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        echo "Please install Docker Desktop from https://www.docker.com/products/docker-desktop"
        exit 1
    fi
    print_success "Docker installed"
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed"
        exit 1
    fi
    print_success "Docker Compose installed"
    
    # Check Docker daemon
    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running"
        echo "Please start Docker Desktop"
        exit 1
    fi
    print_success "Docker daemon is running"
    
    # Check .env file
    if [ ! -f "$ENV_FILE" ]; then
        if [ -f "$EXAMPLE_ENV_FILE" ]; then
            print_warning ".env file not found, creating from .env.example"
            cp "$EXAMPLE_ENV_FILE" "$ENV_FILE"
            print_success ".env file created"
        else
            print_error ".env.example not found"
            exit 1
        fi
    fi
    print_success ".env file exists"
}

deploy_up() {
    print_header "Starting AQUAMIND Services"
    
    check_prerequisites
    
    echo -e "${BLUE}Pulling latest images...${NC}"
    docker-compose pull
    
    echo -e "${BLUE}Starting containers (this may take 30-40 seconds)...${NC}"
    docker-compose up -d
    
    sleep 5
    
    # Check services status
    print_header "Service Status"
    docker-compose ps
    
    print_header "Access Points"
    echo -e "${GREEN}Frontend:  http://localhost:3000${NC}"
    echo -e "${GREEN}Backend:   http://localhost:8000/docs${NC}"
    echo -e "${GREEN}Grafana:   http://localhost:3001 (admin/aquamind)${NC}"
    echo -e "${GREEN}Prometheus: http://localhost:9090${NC}"
    
    print_success "AQUAMIND deployed successfully!"
}

deploy_down() {
    print_header "Stopping AQUAMIND Services"
    
    docker-compose down
    print_success "All services stopped"
}

deploy_restart() {
    print_header "Restarting AQUAMIND Services"
    
    docker-compose restart
    sleep 3
    docker-compose ps
    print_success "Services restarted"
}

deploy_logs() {
    print_header "Streaming Service Logs"
    echo "Press Ctrl+C to stop"
    echo ""
    
    if [ -n "$1" ] && [ "$1" != "logs" ]; then
        docker-compose logs -f "$1"
    else
        docker-compose logs -f
    fi
}

deploy_status() {
    print_header "Service Status"
    docker-compose ps
    
    print_header "Resource Usage"
    docker stats --no-stream
}

deploy_clean() {
    print_header "Cleaning AQUAMIND Resources"
    
    print_warning "This will REMOVE all containers and volumes"
    read -p "Are you sure? (y/N) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose down -v
        print_success "All resources cleaned"
        
        print_warning "Note: PostgreSQL data has been deleted"
        print_warning "Run './deploy.sh up' to recreate everything"
    else
        print_warning "Cleanup cancelled"
    fi
}

deploy_health_check() {
    print_header "Health Check"
    
    services=("backend" "frontend" "postgres" "redis")
    
    for service in "${services[@]}"; do
        if docker-compose ps | grep -q "$service.*Up"; then
            print_success "$service is running"
        else
            print_error "$service is NOT running"
        fi
    done
    
    # Check backend API
    echo ""
    echo -e "${BLUE}Testing Backend API...${NC}"
    if curl -s http://localhost:8000/health | grep -q '"status":"healthy"'; then
        print_success "Backend API is healthy"
    else
        print_error "Backend API is not responding"
    fi
    
    # Check frontend
    echo ""
    echo -e "${BLUE}Testing Frontend...${NC}"
    if curl -s http://localhost:3000 | grep -q "AQUAMIND\|React"; then
        print_success "Frontend is responding"
    else
        print_error "Frontend is not responding"
    fi
}

deploy_backup() {
    print_header "Backing Up Database"
    
    BACKUP_DIR="./backups"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/aquamind_backup_$TIMESTAMP.sql"
    
    mkdir -p "$BACKUP_DIR"
    
    docker-compose exec -T postgres pg_dump -U aquamind aquamind > "$BACKUP_FILE"
    
    print_success "Database backed up to $BACKUP_FILE"
}

deploy_restore() {
    print_header "Restoring Database"
    
    if [ -z "$1" ]; then
        print_error "Backup file not specified"
        echo "Usage: ./deploy.sh restore <backup-file.sql>"
        echo "Available backups:"
        ls -1 ./backups/ 2>/dev/null || echo "No backups found"
        exit 1
    fi
    
    if [ ! -f "$1" ]; then
        print_error "Backup file not found: $1"
        exit 1
    fi
    
    print_warning "This will overwrite the current database"
    read -p "Continue? (y/N) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose exec -T postgres psql -U aquamind aquamind < "$1"
        print_success "Database restored from $1"
    fi
}

# Main
case "${1:-help}" in
    up)
        deploy_up
        ;;
    down|stop)
        deploy_down
        ;;
    logs)
        deploy_logs "$2"
        ;;
    restart)
        deploy_restart
        ;;
    status)
        deploy_status
        ;;
    health)
        deploy_health_check
        ;;
    clean)
        deploy_clean
        ;;
    backup)
        deploy_backup
        ;;
    restore)
        deploy_restore "$2"
        ;;
    help|--help|-h)
        cat << EOF
${BLUE}AQUAMIND Deployment Script${NC}

${GREEN}Usage:${NC}
  bash deploy.sh [COMMAND] [OPTIONS]

${GREEN}Commands:${NC}
  up              Start all services
  down|stop       Stop all services
  restart         Restart all services
  logs [service]  Stream service logs (backend, frontend, postgres, redis)
  status          Show service status and resource usage
  health          Run health checks on all services
  clean           Remove all containers and volumes (destructive!)
  backup          Backup PostgreSQL database
  restore <file>  Restore PostgreSQL database from backup
  help            Show this help message

${GREEN}Examples:${NC}
  bash deploy.sh up              # Start AQUAMIND
  bash deploy.sh logs backend    # View backend logs
  bash deploy.sh health          # Check system health
  bash deploy.sh backup          # Backup database
  bash deploy.sh down            # Stop services

${GREEN}Quick Start:${NC}
  1. bash deploy.sh up
  2. Open http://localhost:3000
  3. bash deploy.sh down (when done)

${YELLOW}Requirements:${NC}
  - Docker Desktop installed and running
  - .env file configured (copy from .env.example)
  - Ports 3000, 8000, 5432, 6379 available

EOF
        ;;
    *)
        print_error "Unknown command: $1"
        echo "Run 'bash deploy.sh help' for usage information"
        exit 1
        ;;
esac
