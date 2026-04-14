# GestorTareas

Sistema web de gestión de proyectos y tareas desarrollado con **ASP.NET Web Forms**, **C#** y **SQL Server 2019**.

---

## Tabla de contenidos

- [Descripción](#descripción)
- [Stack tecnológico](#stack-tecnológico)
- [Arquitectura](#arquitectura)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Base de datos](#base-de-datos)
- [Requisitos previos](#requisitos-previos)
- [Clonar el repositorio](#clonar-el-repositorio)
- [Configurar la base de datos](#configurar-la-base-de-datos)
- [Configurar la cadena de conexión](#configurar-la-cadena-de-conexión)
- [Levantar el proyecto](#levantar-el-proyecto)
- [Usuario administrador por defecto](#usuario-administrador-por-defecto)
- [Funcionalidades](#funcionalidades)

---

## Descripción

GestorTareas permite a los equipos de trabajo crear proyectos, añadir y asignar tareas, registrar comentarios por tarea y hacer seguimiento del progreso. Incluye autenticación por cookies, reportes con ReportViewer y una interfaz construida 100% con HTML puro y jQuery, sin controles ASP.NET.

---

## Stack tecnológico

| Componente | Tecnología |
|---|---|
| Backend | ASP.NET Web Forms + C# (.NET 4.7.2) |
| IDE | Visual Studio 2015 o superior |
| Base de datos | SQL Server 2019 / LocalDB |
| Acceso a datos | ADO.NET — sin ORM |
| Frontend | HTML5 + jQuery 1.12.4 + jQuery UI 1.12.1 |
| Comunicación JS↔C# | ScriptManager + PageMethods (WebMethod) |
| Reportes | Microsoft ReportViewer 10.x + RDLC |
| Tipografía | Google Fonts (Rajdhani + Source Sans 3) |

---

## Arquitectura

El proyecto implementa una arquitectura **N-Tier en 4 capas** dentro de un único proyecto ASP.NET Web Application, con separación por carpetas:

```
Presentación (WebApp)
       ↓
Lógica de negocio (Logica)
       ↓
Acceso a datos (AccesoDatos)
       ↓
Objetos / Entidades (Objectos)
       ↓
SQL Server 2019
```

### Capa de presentación — `WebApp/`

Páginas `.aspx` con code-behind `.aspx.cs`. Toda la interfaz de usuario está construida con HTML puro, jQuery y jQuery UI — **sin controles ASP.NET en los formularios**.

La comunicación con el servidor se realiza mediante `PageMethods` (métodos C# estáticos decorados con `[WebMethod]`) que jQuery llama de forma asíncrona sin recargar la página.

### Capa de lógica de negocio — `Logica/`

Clases BLL que actúan de intermediarias entre la presentación y el acceso a datos. Aplican validaciones y reglas de negocio antes de llamar al DAL:

- `SesionBLL` — hash SHA-256, cookie `GTSesion` (HttpOnly, 30 min), verificación de sesión.
- `UsuarioBLL` — valida contraseña (8+ chars, mayúscula, número, especial), edad (10–100 años).
- `ProyectoBLL` — valida FechaFin ≥ FechaInicio, bloquea eliminación con tareas En Progreso.
- `TareaBLL` — verifica usuario asignado activo, controla transición de estados.

### Capa de acceso a datos — `AccesoDatos/`

Clases DAL que usan ADO.NET (`SqlConnection`, `SqlCommand`, `SqlDataReader`) para ejecutar Stored Procedures. **Nunca se construye SQL dinámico desde C#.**

- `Conexion` — centraliza la cadena de conexión leída desde `Web.config`.
- `UsuarioDAL`, `ProyectoDAL`, `TareaDAL`, `CatalogoDAL`.

### Capa de objetos — `Objectos/`

Plain Old C# Objects (POCO) sin lógica. Sirven de contenedores de datos entre capas y son serializables a JSON para los PageMethods.

- `UsuarioObj`, `ProyectoObj`, `TareaObj`, `ComentarioObj`, `CatalogoObj`.

---

## Estructura del proyecto

```
Gestion_Tareas/
│
├── AccesoDatos/
│   ├── Conexion.cs
│   ├── CatalogoDAL.cs
│   ├── UsuarioDAL.cs
│   ├── ProyectoDAL.cs
│   └── TareaDAL.cs
│
├── Logica/
│   ├── SesionBLL.cs
│   ├── UsuarioBLL.cs
│   ├── ProyectoBLL.cs
│   └── TareaBLL.cs
│
├── Objectos/
│   ├── CatalogoObj.cs
│   ├── ComentarioObj.cs
│   ├── UsuarioObj.cs
│   ├── ProyectoObj.cs
│   └── TareaObj.cs
│
├── WebApp/
│   ├── Login.aspx / Login.aspx.cs
│   ├── Default.aspx / Default.aspx.cs
│   │
│   ├── Usuarios/
│   │   ├── ListaUsuarios.aspx / .cs
│   │   └── FormUsuario.aspx / .cs
│   │
│   ├── Proyectos/
│   │   ├── ListaProyectos.aspx / .cs
│   │   └── FormProyecto.aspx / .cs
│   │
│   ├── Tareas/
│   │   ├── ListaTareas.aspx / .cs
│   │   └── FormTarea.aspx / .cs
│   │
│   ├── Reportes/
│   │   ├── ReporteUsuarios.aspx / .cs
│   │   └── ReporteUsuarios.rdlc
│   │
│   ├── Scripts/
│   │   └── app.js
│   │
│   └── Styles/
│       └── site.css
│
├── Web.config
├── packages.config
└── Gestion_Tareas.csproj
```

---

## Base de datos

La base de datos `GestorTareas` contiene:

**Tablas de catálogo:** `Genero`, `EstadoCivil`, `Rol`, `EstadoTarea`, `EstadoProyecto`

**Tablas principales:** `Usuario`, `Proyecto`, `Tarea`, `Comentario`

**Stored Procedures (22):** todo el acceso a datos se realiza exclusivamente a través de SPs parametrizados — `sp_InsertarUsuario`, `sp_ConsultarProyectos`, `sp_AsignarTarea`, `sp_InsertarComentario`, entre otros.

**Seguridad:**
- Las contraseñas se almacenan como hash SHA-256 — nunca en texto plano.
- La eliminación es siempre lógica (`Activo = 0` en usuarios, estado Suspendido/Cancelada en proyectos y tareas).

---

## Requisitos previos

Antes de clonar y ejecutar el proyecto asegúrate de tener instalado:

- [Visual Studio 2015 o superior](https://visualstudio.microsoft.com/) con la carga de trabajo **ASP.NET y desarrollo web**
- [SQL Server 2019](https://www.microsoft.com/es-es/sql-server/sql-server-downloads) o SQL Server Express / LocalDB
- [SQL Server Management Studio (SSMS)](https://learn.microsoft.com/es-es/sql/ssms/download-sql-server-management-studio-ssms)
- .NET Framework 4.7.2 (incluido en Visual Studio)
- Git

---

## Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/GestorTareas.git
cd GestorTareas
```

O desde Visual Studio: **File → Clone Repository** → pega la URL del repositorio.

---

## Configurar la base de datos

1. Abre **SQL Server Management Studio** y conéctate a tu instancia de SQL Server.

2. Ejecuta el script de base de datos ubicado en la raíz del repositorio:

```
database.sql
```

Este script crea automáticamente:
- La base de datos `GestorTareas`
- Todas las tablas con sus relaciones y restricciones
- Los 22 Stored Procedures
- Los datos iniciales de catálogos (géneros, roles, estados)
- El usuario administrador por defecto

Para ejecutarlo desde SSMS: **File → Open → File** → selecciona `database.sql` → presiona **F5** o el botón Execute.

---

## Configurar la cadena de conexión

Abre el archivo `Web.config` en la raíz del proyecto y actualiza la cadena de conexión según tu entorno:

```xml
<connectionStrings>
  <add name="GestorTareas"
       connectionString="Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=GestorTareas;Integrated Security=True;"
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

**Valores comunes de `Data Source` según tu instalación:**

| Escenario | Valor |
|---|---|
| SQL Server LocalDB (por defecto en VS) | `(localdb)\MSSQLLocalDB` |
| SQL Server Express | `.\SQLEXPRESS` |
| SQL Server local instancia por defecto | `.` o `localhost` |
| SQL Server remoto | `IP_o_nombre_servidor` |

Si usas autenticación SQL (usuario y contraseña) en lugar de Windows Authentication:

```xml
connectionString="Data Source=.;Initial Catalog=GestorTareas;User Id=sa;Password=TuPassword;"
```

---

## Levantar el proyecto

1. Abre la solución en Visual Studio haciendo doble clic en `Gestion_Tareas.slnx` o desde **File → Open → Project/Solution**.

2. Restaura los paquetes NuGet: click derecho sobre la solución → **Restore NuGet Packages**.

3. Establece `Gestion_Tareas` como proyecto de inicio: click derecho sobre el proyecto → **Set as StartUp Project**.

4. Presiona **F5** para compilar y ejecutar en modo debug.

5. El navegador abrirá automáticamente `Login.aspx`.

> **Nota:** Si aparece un error de ReportViewer al abrir el reporte, verifica que el handler esté registrado en `Web.config`:
> ```xml
> <system.webServer>
>   <handlers>
>     <add name="ReportViewerWebControlHandler"
>          preCondition="integratedMode" verb="*"
>          path="Reserved.ReportViewerWebControl.axd"
>          type="Microsoft.Reporting.WebForms.HttpHandler, Microsoft.ReportViewer.WebForms, Version=10.0.40219.1, Culture=neutral, PublicKeyToken=89845dcd8080cc91" />
>   </handlers>
> </system.webServer>
> ```

---

## Usuario administrador por defecto

El script de base de datos crea un usuario administrador inicial:

| Campo | Valor |
|---|---|
| Login | `admin` |
| Contraseña | `Admin123!` |
| Rol | Administrador |

> Se recomienda cambiar la contraseña después del primer inicio de sesión.

---

## Funcionalidades

- **Autenticación** con cookie `GTSesion` (HttpOnly, expiración configurable). Todas las páginas verifican sesión en `Page_Load` y redirigen a login si no existe.
- **CRUD completo** de Usuarios, Proyectos y Tareas.
- **Catálogos desde BD** — Género, Estado Civil, Rol, Estado de Tarea y Estado de Proyecto se cargan dinámicamente desde la base de datos.
- **Calendario** jQuery UI Datepicker en campos de fecha (formato dd/mm/yyyy).
- **Tooltips** jQuery UI Tooltip en todos los campos de los formularios.
- **Filtros** en todos los listados (nombre, cédula, rol, estado, proyecto, etc.).
- **Sistema de comentarios** por tarea — agregar y visualizar comentarios desde el formulario o un diálogo inline.
- **Asignación de tareas** a usuarios activos con validación de estado.
- **Eliminación lógica** — los registros nunca se borran físicamente.
- **ReportViewer** con lista de usuarios filtrada (exportable a PDF, Excel y Word).
- **Diseño** tema oscuro con variables CSS, badges de estado y navbar responsivo.
