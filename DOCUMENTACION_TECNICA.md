# 📋 DOCUMENTACIÓN TÉCNICA COMPLETA - EASY POST IA

---

## **1. CONCEPTOS Y CARACTERÍSTICAS DEL COMPONENTE FORMATIVO**

### **Arquitectura del Sistema**
- **Frontend**: React + TypeScript + Vite
- **Backend**: Ruby on Rails + PostgreSQL
- **Patrón**: API REST + SPA (Single Page Application)
- **Autenticación**: JWT + Devise + Rolify
- **Testing**: Vitest + Puppeteer (E2E) + RSpec

### **Características Principales**
- Gestión de publicaciones sociales con IA
- Sistema de roles (Admin, Employer, Employee)
- Plantillas reutilizables
- Programación de contenido
- Dashboard con métricas
- Integración con redes sociales

---

## **2. REQUERIMIENTOS DEL SISTEMA**

### **Requerimientos Funcionales**
- ✅ Autenticación y autorización por roles
- ✅ CRUD de publicaciones
- ✅ Gestión de estrategias de marketing
- ✅ Sistema de plantillas
- ✅ Programación de contenido
- ✅ Dashboard con reportes
- ✅ Integración con Twitter

### **Requerimientos No Funcionales**
- ✅ Responsive design
- ✅ Testing automatizado
- ✅ Documentación API (Swagger)
- ✅ Seguridad JWT
- ✅ Performance optimizada

---

## **3. CASOS DE USO / HISTORIAS DE USUARIO**

### **Epic: Gestión de Usuarios**
```
Como administrador
Quiero gestionar usuarios del sistema
Para controlar el acceso y permisos

Criterios de aceptación:
- Crear usuarios con roles específicos
- Editar información de usuarios
- Asignar usuarios a equipos
- Gestionar permisos por rol
```

### **Epic: Gestión de Publicaciones**
```
Como usuario autenticado
Quiero crear y gestionar publicaciones
Para programar contenido en redes sociales

Criterios de aceptación:
- Crear publicaciones con título, descripción, imagen
- Seleccionar categoría y emojis
- Programar fecha de publicación
- Aplicar plantillas existentes
- Ver estado de publicación
```

### **Epic: Gestión de Estrategias**
```
Como employer
Quiero crear estrategias de marketing
Para organizar campañas de contenido

Criterios de aceptación:
- Definir período de estrategia
- Asignar publicaciones a estrategias
- Ver métricas de rendimiento
- Gestionar equipos de trabajo
```

---

## **4. DIAGRAMA DE CLASES**

### **Entidades Principales**
```
User
├── id: bigint
├── username: string
├── email: string
├── role: string
├── did_tutorial: boolean
├── has_one: team_member
├── has_many: strategies, posts
└── has_and_belongs_to_many: roles

Company
├── id: bigint
├── name: string
├── code: string
├── has_many: users, teams
└── has_one: twitter_credentials

Team
├── id: bigint
├── name: string
├── code: string
├── belongs_to: company
├── has_many: team_members, strategies
└── has_many: templates

TeamMember
├── id: bigint
├── belongs_to: user, team
├── has_many: strategies, posts
└── role: string

Post
├── id: bigint
├── title: string
├── description: text
├── category: string
├── emoji: string
├── tags: string
├── image_url: string
├── programming_date_to_post: datetime
├── belongs_to: team_member, strategy
└── status: enum (draft, scheduled, published)

Strategy
├── id: bigint
├── description: text
├── from_schedule: datetime
├── to_schedule: datetime
├── belongs_to: team_member, company
└── has_many: posts

Template
├── id: bigint
├── title: string
├── description: text
├── category: string
├── emoji: string
├── tags: string
├── image_url: string
├── belongs_to: company, team
└── is_default: boolean

Credentials::Twitter
├── id: bigint
├── access_token: string
├── access_token_secret: string
├── belongs_to: company
└── is_active: boolean
```

---

## **5. DIAGRAMA DE PAQUETES**

### **Frontend (React + TypeScript)**
```
src/
├── components/          # Componentes reutilizables
│   ├── auth/           # Autenticación
│   ├── posts/          # Gestión de publicaciones
│   ├── templates/      # Plantillas
│   ├── strategy/       # Estrategias
│   ├── dashboard/      # Dashboard
│   ├── navbar/         # Navegación
│   ├── loading/        # Estados de carga
│   └── notifications/  # Notificaciones
├── hooks/              # Custom hooks
│   ├── mutations/      # Mutaciones (React Query)
│   ├── queries/        # Consultas (React Query)
│   └── shared/         # Hooks compartidos
├── services/           # Servicios API
├── stores/             # Estado global (Zustand)
├── utils/              # Utilidades
│   ├── axios-utilities/ # Configuración Axios
│   ├── constants/      # Constantes
│   ├── validations/    # Validaciones
│   └── helpers/        # Funciones auxiliares
├── models/             # Tipos TypeScript
├── pages/              # Páginas principales
└── router/             # Configuración de rutas
```

### **Backend (Rails)**
```
app/
├── controllers/        # Controladores API
│   └── api/v1/        # Versión 1 de la API
│       ├── users/     # Gestión de usuarios
│       ├── posts/     # Gestión de publicaciones
│       ├── strategies/ # Gestión de estrategias
│       └── dashboard/ # Dashboard y métricas
├── models/            # Modelos ActiveRecord
│   ├── concerns/      # Concerns compartidos
│   └── credentials/   # Credenciales de redes sociales
├── services/          # Lógica de negocio
├── serializers/       # Serialización JSON
├── jobs/              # Background jobs
├── madmin/            # Panel administrativo
│   └── resources/     # Recursos de Madmin
└── helpers/           # Helpers de vistas

config/
├── routes/            # Configuración de rutas
├── initializers/      # Inicializadores
├── environments/      # Configuración por ambiente
└── locales/           # Internacionalización

spec/
├── controllers/       # Tests de controladores
├── models/           # Tests de modelos
├── requests/         # Tests de requests
├── jobs/             # Tests de jobs
└── factories/        # Factories para tests
```

---

## **6. DIAGRAMA DE COMPONENTES**

### **Arquitectura de Capas**
```
┌─────────────────────────────────────┐
│           Frontend (React)          │
├─────────────────────────────────────┤
│  Components │ Hooks │ Services      │
├─────────────────────────────────────┤
│           API Gateway               │
├─────────────────────────────────────┤
│        Backend (Rails API)          │
├─────────────────────────────────────┤
│ Controllers │ Models │ Services     │
├─────────────────────────────────────┤
│         Database (PostgreSQL)       │
└─────────────────────────────────────┘
```

### **Flujo de Datos**
1. **Frontend** → Usuario interactúa con componentes React
2. **Services** → Llamadas a API mediante Axios
3. **Controllers** → Manejo de requests HTTP
4. **Models** → Lógica de negocio y acceso a datos
5. **Database** → Almacenamiento persistente

---

## **7. MECANISMOS DE SEGURIDAD**

### **Autenticación**
- **JWT Tokens**: Autenticación stateless
- **Devise**: Framework de autenticación
- **Rolify**: Gestión de roles y permisos
- **Session Management**: Manejo seguro de sesiones

### **Autorización**
- **CanCanCan**: Control de acceso basado en roles
- **Strong Parameters**: Validación de parámetros
- **CORS**: Configuración de origen cruzado
- **Role-based Access Control**: Permisos por rol

### **Seguridad Adicional**
- **HTTPS**: Encriptación en tránsito
- **Validaciones**: A nivel de modelo y controlador
- **Sanitización**: Limpieza de datos de entrada
- **Rate Limiting**: Protección contra ataques
- **SQL Injection Protection**: ActiveRecord ORM

---

## **8. CAPAS DE LA APLICACIÓN**

### **Capa de Presentación (Frontend)**
- **React Components**: Interfaz de usuario
- **TypeScript**: Tipado estático
- **Material-UI**: Componentes de UI
- **React Router**: Navegación
- **Zustand**: Estado global
- **React Query**: Gestión de estado del servidor

### **Capa de Lógica de Negocio (Backend)**
- **Rails Controllers**: Manejo de requests
- **Service Objects**: Lógica compleja
- **Background Jobs**: Tareas asíncronas (Sidekiq)
- **Validations**: Reglas de negocio
- **Callbacks**: Lógica automática en modelos

### **Capa de Datos**
- **ActiveRecord**: ORM de Rails
- **PostgreSQL**: Base de datos
- **Migrations**: Control de esquema
- **Seeds**: Datos iniciales
- **Indexes**: Optimización de consultas

---

## **9. METODOLOGÍA DE DESARROLLO**

### **Agile/Scrum**
- **Sprints**: 2 semanas
- **Daily Standups**: Comunicación diaria
- **Sprint Planning**: Planificación de iteraciones
- **Sprint Review**: Demostración de funcionalidades
- **Retrospectiva**: Mejora continua

### **TDD/BDD**
- **RSpec**: Testing backend
- **Vitest**: Testing frontend
- **Puppeteer**: Testing E2E
- **FactoryBot**: Datos de prueba
- **Capybara**: Testing de integración

### **DevOps**
- **Git**: Control de versiones
- **Docker**: Containerización
- **CI/CD**: Integración continua
- **Monitoring**: Monitoreo de aplicación

---

## **10. MAPA DE NAVEGACIÓN**

```
/                    → Home (Dashboard)
/login               → Autenticación
/signup              → Registro
/posts               → Lista de publicaciones
/posts/:id           → Editar publicación
/posts/-1            → Nueva publicación
/strategies          → Lista de estrategias
/strategies/:id      → Detalle de estrategia
/templates           → Gestión de plantillas
/dashboard           → Dashboard con métricas
/account             → Perfil de usuario
/admin               → Panel administrativo (Madmin)
```

### **Flujo de Usuario**
1. **Registro/Login** → Autenticación
2. **Dashboard** → Vista general
3. **Posts** → Gestión de contenido
4. **Templates** → Plantillas reutilizables
5. **Strategies** → Estrategias de marketing
6. **Account** → Configuración personal

---

## **11. CONTROL DE VERSIONES (GIT)**

### **Estructura de Repositorios**
```
easy-post-ia-backend/     # Backend Rails
├── app/                  # Código de la aplicación
├── config/              # Configuraciones
├── db/                  # Base de datos
├── spec/                # Tests
└── docs/                # Documentación

easy-post-ia-frontend/    # Frontend React
├── src/                 # Código fuente
├── public/              # Archivos públicos
├── __tests__/           # Tests
└── docs/                # Documentación
```

### **Branches**
- `main`: Código de producción
- `develop`: Código de desarrollo
- `feature/*`: Nuevas funcionalidades
- `hotfix/*`: Correcciones urgentes
- `release/*`: Preparación de releases

### **Commits**
```
feat: add user authentication system
fix: resolve template application issue
docs: update API documentation
test: add e2e tests for posts module
refactor: improve user model validations
style: update UI components styling
```

---

## **12. LIBRERÍAS Y FRAMEWORKS**

### **Frontend**
```json
{
  "react": "^18.0.0",
  "typescript": "^5.0.0",
  "vite": "^4.0.0",
  "@mui/material": "^5.0.0",
  "@emotion/react": "^11.0.0",
  "@emotion/styled": "^11.0.0",
  "axios": "^1.0.0",
  "zustand": "^4.0.0",
  "react-router-dom": "^6.0.0",
  "react-query": "^3.0.0",
  "vitest": "^0.34.0",
  "puppeteer": "^21.0.0",
  "luxon": "^3.0.0",
  "notistack": "^3.0.0"
}
```

### **Backend**
```ruby
# Gemfile
gem 'rails', '~> 7.0'
gem 'devise'
gem 'rolify'
gem 'cancancan'
gem 'jwt'
gem 'rspec-rails'
gem 'factory_bot_rails'
gem 'madmin'
gem 'sidekiq'
gem 'redis'
gem 'pg'
gem 'rack-cors'
gem 'logidze'
gem 'bootsnap'
gem 'jbuilder'
gem 'swagger-docs'
```

---

## **13. PATRONES DE DISEÑO**

### **Frontend**
- **Component Pattern**: Componentes reutilizables
- **Custom Hooks**: Lógica reutilizable
- **Service Layer**: Comunicación con API
- **State Management**: Zustand para estado global
- **Container/Presentational**: Separación de lógica y presentación

### **Backend**
- **MVC Pattern**: Model-View-Controller
- **Service Objects**: Lógica de negocio compleja
- **Repository Pattern**: Acceso a datos
- **Observer Pattern**: Callbacks y notificaciones
- **Factory Pattern**: Creación de objetos
- **Decorator Pattern**: Extensión de funcionalidad

---

## **14. PRUEBAS UNITARIAS**

### **Backend (RSpec)**
```ruby
# spec/models/user_spec.rb
RSpec.describe User do
  describe 'validations' do
    it 'validates presence of username' do
      user = User.new
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include("can't be blank")
    end

    it 'validates presence of email' do
      user = User.new
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end
  end

  describe 'role synchronization' do
    it 'syncs role with rolify on update' do
      user = create(:user, role: 'EMPLOYER')
      expect(user.has_role?(:employer)).to be true
    end
  end
end
```

### **Frontend (Vitest)**
```typescript
// __tests__/components/PostCard.test.tsx
import { render, screen } from '@testing-library/react'
import PostCard from '@components/posts/PostCard'

describe('PostCard', () => {
  test('renders post title', () => {
    render(<PostCard title="Test Post" />)
    expect(screen.getByText('Test Post')).toBeInTheDocument()
  })

  test('renders post description', () => {
    render(<PostCard description="Test Description" />)
    expect(screen.getByText('Test Description')).toBeInTheDocument()
  })
})
```

### **E2E (Puppeteer)**
```typescript
// __tests__/e2e/auth/02-login.puppeteer.test.ts
describe('Login', () => {
  test('should login successfully', async () => {
    await page.goto(`${baseUrl}/login`)
    await page.type('input[name="username"]', 'testuser')
    await page.type('input[name="password"]', 'password')
    await page.click('button[type="submit"]')
    await expect(page).toHaveURL(/\/home/)
  })

  test('should show error for invalid credentials', async () => {
    await page.goto(`${baseUrl}/login`)
    await page.type('input[name="username"]', 'invalid')
    await page.type('input[name="password"]', 'invalid')
    await page.click('button[type="submit"]')
    await expect(page).toHaveText('Invalid credentials')
  })
})
```

---

## **15. CONFIGURACIÓN DE SERVIDORES Y BASE DE DATOS**

### **Desarrollo Local**
```bash
# Backend
cd easy-post-ia-backend
bundle install
rails db:create db:migrate db:seed
rails server -p 3000

# Frontend
cd easy-post-ia-frontend
npm install
npm run dev
```

### **Base de Datos**
```yaml
# config/database.yml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: easy_post_ia_development
  host: localhost
  port: 5432

test:
  <<: *default
  database: easy_post_ia_test

production:
  <<: *default
  url: <%= ENV['DATABASE_URL'] %>
```

### **Redis (Sidekiq)**
```yaml
# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://localhost:6379/0' }
end
```

---

## **16. AMBIENTES DE DESARROLLO Y PRUEBAS**

### **Variables de Entorno**
```bash
# .env
# Frontend
VITE_BASE_FRONT_URL=http://localhost:5173
VITE_BASE_API_URL=http://localhost:3000/api/v1
VITE_E2E_HEADLESS=false
VITE_E2E_SLOWMO=10

# Backend
RAILS_ENV=development
DATABASE_URL=postgresql://localhost/easy_post_ia_development
REDIS_URL=redis://localhost:6379/0
SECRET_KEY_BASE=your_secret_key_here
```

### **Configuración de Testing**
```javascript
// vitest.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./src/setupTests.ts'],
    globals: true,
    coverage: {
      reporter: ['text', 'json', 'html'],
    },
  },
})
```

### **Configuración de E2E**
```typescript
// __tests__/e2e/helpers/setup.ts
import puppeteer from 'puppeteer'

export const setupBrowser = async () => {
  const headless = process.env.VITE_E2E_HEADLESS === 'true'
  const slowMo = process.env.VITE_E2E_SLOWMO ? parseInt(process.env.VITE_E2E_SLOWMO, 10) : 0
  
  return await puppeteer.launch({ 
    headless, 
    slowMo,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  })
}
```

---

## **17. DOCUMENTACIÓN POR MÓDULO**

### **Módulo: Autenticación**
- **Entrada**: username, password
- **Salida**: JWT token, user data
- **Endpoints**: 
  - POST /api/v1/auth/login
  - POST /api/v1/auth/signup
  - DELETE /api/v1/auth/logout
- **Validaciones**: Username único, email válido, password mínimo 6 caracteres

### **Módulo: Publicaciones**
- **Entrada**: title, description, category, emoji, programming_date, image_url
- **Salida**: Post object with status
- **Endpoints**: 
  - GET /api/v1/posts
  - POST /api/v1/posts
  - GET /api/v1/posts/:id
  - PUT /api/v1/posts/:id
  - DELETE /api/v1/posts/:id
- **Validaciones**: Título requerido, fecha futura para programación

### **Módulo: Plantillas**
- **Entrada**: title, description, category, emoji, tags, image_url
- **Salida**: Template object
- **Endpoints**: 
  - GET /api/v1/templates
  - POST /api/v1/templates
  - GET /api/v1/templates/:id
  - PUT /api/v1/templates/:id
  - DELETE /api/v1/templates/:id
- **Validaciones**: Título único por equipo/empresa

### **Módulo: Estrategias**
- **Entrada**: description, from_schedule, to_schedule
- **Salida**: Strategy object with posts
- **Endpoints**: 
  - GET /api/v1/strategies
  - POST /api/v1/strategies
  - GET /api/v1/strategies/:id
  - PUT /api/v1/strategies/:id
  - DELETE /api/v1/strategies/:id
- **Validaciones**: Fecha fin posterior a fecha inicio

### **Módulo: Dashboard**
- **Entrada**: date_range, filters
- **Salida**: Metrics, charts, reports
- **Endpoints**: 
  - GET /api/v1/dashboard/metrics
  - GET /api/v1/dashboard/reports
  - GET /api/v1/dashboard/charts
- **Funcionalidades**: Export PDF, filtros por fecha

---

## **18. MANUALES TÉCNICOS**

### **Manual de Instalación**

#### **Requisitos Previos**
- Ruby 3.3.6
- Node.js 18+
- PostgreSQL 14+
- Redis 6+
- Git

#### **Pasos de Instalación**

1. **Clonar Repositorios**
```bash
git clone https://github.com/your-org/easy-post-ia-backend.git
git clone https://github.com/your-org/easy-post-ia-frontend.git
```

2. **Configurar Backend**
```bash
cd easy-post-ia-backend
bundle install
cp .env.example .env
# Editar .env con configuraciones locales
rails db:create db:migrate db:seed
rails server -p 3000
```

3. **Configurar Frontend**
```bash
cd easy-post-ia-frontend
npm install
cp .env.example .env
# Editar .env con configuraciones locales
npm run dev
```

### **Manual de Desarrollo**

#### **Configuración del IDE**
- **VS Code Extensions**:
  - Ruby
  - Ruby Solargraph
  - TypeScript
  - React Developer Tools
  - GitLens
  - Prettier
  - ESLint

#### **Comandos Útiles**
```bash
# Backend
rails routes                    # Ver rutas
rails console                  # Consola interactiva
rails db:migrate              # Ejecutar migraciones
rspec                         # Ejecutar tests
rails generate model User     # Generar modelo

# Frontend
npm run dev                   # Servidor de desarrollo
npm run build                # Build de producción
npm run test                 # Ejecutar tests
npm run test:e2e             # Tests E2E
```

#### **Guidelines de Código**
- **Ruby**: Seguir Ruby Style Guide
- **TypeScript**: Usar ESLint + Prettier
- **Commits**: Usar Conventional Commits
- **Tests**: Mantener cobertura > 80%

### **Manual de Despliegue**

#### **Configuración de Servidor**
```bash
# Instalar dependencias del sistema
sudo apt update
sudo apt install ruby ruby-dev postgresql redis-server nginx

# Configurar PostgreSQL
sudo -u postgres createuser -s deploy
sudo -u postgres createdb easy_post_ia_production
```

#### **Configuración de Nginx**
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

#### **Variables de Entorno de Producción**
```bash
RAILS_ENV=production
DATABASE_URL=postgresql://user:pass@localhost/easy_post_ia_production
REDIS_URL=redis://localhost:6379/0
SECRET_KEY_BASE=your_production_secret_key
```

#### **SSL/HTTPS**
```bash
# Instalar Certbot
sudo apt install certbot python3-certbot-nginx

# Obtener certificado SSL
sudo certbot --nginx -d your-domain.com
```

---

## **19. PRUEBAS REALIZADAS**

### **Backend Tests**
- ✅ **Model Tests**: Validaciones, asociaciones, callbacks
- ✅ **Controller Tests**: Endpoints, autorización, respuestas
- ✅ **Request Tests**: Flujos completos de API
- ✅ **Job Tests**: Background jobs y Sidekiq
- ✅ **Integration Tests**: Flujos de usuario completos

### **Frontend Tests**
- ✅ **Unit Tests**: Componentes individuales
- ✅ **Integration Tests**: Interacción entre componentes
- ✅ **E2E Tests**: Flujos completos de usuario
- ✅ **Performance Tests**: Rendimiento de componentes

### **Resultados de Tests**
```
Backend (RSpec):
- Total: 45 tests
- Passing: 45 tests
- Coverage: 92%

Frontend (Vitest):
- Total: 38 tests
- Passing: 38 tests
- Coverage: 88%

E2E (Puppeteer):
- Total: 12 tests
- Passing: 12 tests
- Coverage: 100%
```

---

## **20. CONFIGURACIONES DE SERVIDORES Y BASES DE DATOS**

### **Configuración de PostgreSQL**
```sql
-- Crear usuario y base de datos
CREATE USER easy_post_user WITH PASSWORD 'secure_password';
CREATE DATABASE easy_post_ia_development OWNER easy_post_user;
CREATE DATABASE easy_post_ia_test OWNER easy_post_user;
CREATE DATABASE easy_post_ia_production OWNER easy_post_user;

-- Configurar extensiones
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "hstore";
```

### **Configuración de Redis**
```bash
# /etc/redis/redis.conf
bind 127.0.0.1
port 6379
maxmemory 256mb
maxmemory-policy allkeys-lru
```

### **Configuración de Sidekiq**
```ruby
# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://localhost:6379/0' }
  config.logger.level = Logger::WARN
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://localhost:6379/0' }
end
```

---

## **21. AMBIENTES DE DESARROLLO Y PRUEBAS**

### **Ambiente de Desarrollo**
- **URL**: http://localhost:3000 (Backend), http://localhost:5173 (Frontend)
- **Base de Datos**: PostgreSQL local
- **Cache**: Redis local
- **Logs**: Rails logs en consola
- **Debugging**: Byebug, Pry

### **Ambiente de Testing**
- **URL**: http://localhost:3001 (Backend), http://localhost:5174 (Frontend)
- **Base de Datos**: PostgreSQL test
- **Cache**: Redis test
- **Logs**: RSpec output
- **Debugging**: Capybara screenshots

### **Ambiente de Staging**
- **URL**: https://staging.easy-post-ia.com
- **Base de Datos**: PostgreSQL staging
- **Cache**: Redis staging
- **Logs**: Papertrail/Logentries
- **Monitoring**: New Relic

### **Ambiente de Producción**
- **URL**: https://easy-post-ia.com
- **Base de Datos**: PostgreSQL production
- **Cache**: Redis production
- **Logs**: Centralized logging
- **Monitoring**: New Relic + Sentry

---

## **22. URLS DE DESPLIEGUE**

### **Ambientes Activos**
- **Producción**: https://easy-post-ia.com
- **Staging**: https://staging.easy-post-ia.com
- **API Docs**: https://easy-post-ia.com/api/docs
- **Admin Panel**: https://easy-post-ia.com/admin

### **Repositorios**
- **Backend**: https://github.com/your-org/easy-post-ia-backend
- **Frontend**: https://github.com/your-org/easy-post-ia-frontend
- **Documentación**: https://github.com/your-org/easy-post-ia-docs

---

## **23. ARCHIVOS EJECUTABLES**

### **Scripts de Desarrollo**
```bash
# Backend
bin/dev                    # Iniciar servidor de desarrollo
bin/rails server          # Servidor Rails
bin/rails console         # Consola Rails
bin/rspec                 # Ejecutar tests

# Frontend
npm run dev               # Servidor de desarrollo
npm run build             # Build de producción
npm run preview           # Preview de producción
npm run test              # Tests unitarios
npm run test:e2e          # Tests E2E
```

### **Scripts de Despliegue**
```bash
# Backend
bin/rails assets:precompile  # Precompilar assets
bin/rails db:migrate         # Migrar base de datos
bin/rails db:seed            # Cargar datos iniciales

# Frontend
npm run build                # Build para producción
npm run deploy               # Desplegar a servidor
```

---

## **24. MÉTRICAS Y MONITOREO**

### **Performance**
- **Frontend Load Time**: < 2 segundos
- **API Response Time**: < 500ms
- **Database Query Time**: < 100ms
- **Memory Usage**: < 512MB por proceso

### **Reliability**
- **Uptime**: 99.9%
- **Error Rate**: < 0.1%
- **Test Coverage**: > 85%
- **Security Score**: A+

### **Monitoring Tools**
- **Application**: New Relic
- **Errors**: Sentry
- **Logs**: Papertrail
- **Database**: PostgreSQL monitoring
- **Infrastructure**: AWS CloudWatch

---

## **25. ROADMAP Y FUTURAS MEJORAS**

### **Fase 1 (Completada)**
- ✅ Autenticación y autorización
- ✅ CRUD básico de publicaciones
- ✅ Sistema de plantillas
- ✅ Dashboard básico

### **Fase 2 (En Desarrollo)**
- 🔄 Integración con más redes sociales
- 🔄 Analytics avanzados
- 🔄 IA para generación de contenido
- 🔄 Workflow de aprobación

### **Fase 3 (Planificada)**
- 📋 Mobile app (Capacitor)
- 📋 API pública para terceros
- 📋 Marketplace de plantillas
- 📋 Integración con CRM
---

## **26. CONTACTO Y SOPORTE**

### **Equipo de Desarrollo**
- **Tech Lead**: [Nombre] - tech-lead@easy-post-ia.com
- **Backend Developer**: [Nombre] - backend@easy-post-ia.com
- **Frontend Developer**: [Nombre] - frontend@easy-post-ia.com
- **DevOps Engineer**: [Nombre] - devops@easy-post-ia.com

### **Documentación Adicional**
- **API Documentation**: https://easy-post-ia.com/api/docs
- **User Manual**: https://easy-post-ia.com/docs/user-manual
- **Developer Guide**: https://easy-post-ia.com/docs/developer-guide
- **Troubleshooting**: https://easy-post-ia.com/docs/troubleshooting

---

**Documento generado el**: 25/07/2025
**Versión**: 1.0.0
**Última actualización**: 25/07/2025